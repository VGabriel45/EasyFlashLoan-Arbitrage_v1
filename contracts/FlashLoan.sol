// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IFlashloan.sol";
import "./interfaces/IDODOProxy.sol";
import "./interfaces/IDODOV2.sol";

import "./base/DodoBase.sol";
import "./base/FlashloanValidation.sol";
import "./base/Withdraw.sol";

import "./libraries/RouteUtils.sol";
import "./libraries/Part.sol";

import "./uniswap/v3/ISwapRouter.sol";
import "./uniswap/IUniswapV2Router.sol";

import "@openzeppelin/contracts/utils/math/SignedMath.sol";

import "hardhat/console.sol";

contract Flashloan is IFlashloan, DodoBase, FlashloanValidation, Withdraw {

    using SignedMath for uint256;

    event SentProfit(address recipient, uint256 profit);
    event SwapFinished(address token, uint256 amount);

    uint256 public slippage = 1; // 1%

    /**
     * @dev Initiates a flash loan transaction with DODO protocol.
     * @param params Struct containing parameters for the flash loan.
    */
    function executeFlashloan(
        FlashParams memory params
    ) external checkParams(params) {
        // Encode the callback data to be used in the flash loan execution.
        // This includes sender's address, flash loan pool, loan amount, and routes for token swaps.
        bytes memory data = abi.encode(
            FlashParams({
                flashLoanPool: params.flashLoanPool,
                loanAmount: params.loanAmount,
                routes: params.routes
            })
        );

        address loanToken = RouteUtils.getInitialToken(params.routes[0]); // this can be added inside data UP

        console.log(
            "CONTRACT BALANCE BEFORE BORROW",
            IERC20(loanToken).balanceOf(address(this))
        );

        // Identify the base token of the DODO pool.
        address btoken = IDODO(params.flashLoanPool)._BASE_TOKEN_(); // this can be removed
        console.log(btoken, "BASE TOKEN");

        uint256 baseAmount = IDODO(params.flashLoanPool)._BASE_TOKEN_() == loanToken ? params.loanAmount : 0;
        uint256 quoteAmount = IDODO(params.flashLoanPool)._BASE_TOKEN_() == loanToken ? 0 : params.loanAmount; 

        IDODO(params.flashLoanPool).flashLoan(
            baseAmount,
            quoteAmount,
            address(this),
            data
        );

    }

    function _flashLoanCallBack(
        address,
        uint256,
        uint256,
        bytes calldata data
    ) internal override {
        // Decode the received data to get flash loan details.
        FlashParams memory decoded = abi.decode(data, (FlashParams));
        // Identify the initial loan token from the decoded routes.
        address loanToken = RouteUtils.getInitialToken(decoded.routes[0]);

        // Ensure that the contract has received the loan amount.
        require(IERC20(loanToken).balanceOf(address(this)) >= decoded.loanAmount, "Failed to borrow tokens");
        console.log(IERC20(loanToken).balanceOf(address(this)), "CONTRACT BALANCE AFTER BORROWING");

        // Execute the logic for routing the loan through different swaps.
        routeLoop(decoded.routes, decoded.loanAmount);

        // Log the contract's balance of the loan token after completing the swaps.
        console.log(
            "LOAN_TOKEN CONTRACT BALANCE AFTER BORROW AND SWAP",
            IERC20(loanToken).balanceOf(address(this))
        );

        emit SwapFinished(loanToken, IERC20(loanToken).balanceOf(address(this)));

        require(IERC20(loanToken).balanceOf(address(this)) >= decoded.loanAmount, "Not enough amount to return the loan");

        IERC20(loanToken).transfer(decoded.flashLoanPool, decoded.loanAmount);

        // Log the contract's balance of the loan token after repaying the loan.
        console.log(
            "LOAN_TOKEN CONTRACT BALANCE AFTER REPAY",
            IERC20(loanToken).balanceOf(address(this))
        );

        // Transfer any remaining balance (profit) to the owner of the contract.
        uint256 remained = IERC20(loanToken).balanceOf(address(this));
        IERC20(loanToken).transfer(owner(), remained);

        emit SentProfit(owner(), remained);

        console.log(
            "LOAN_TOKEN CONTRACT BALANCE AFTER REPAY AND TRANSAFER TO OWNER",
            IERC20(loanToken).balanceOf(address(this))
        );
    }

    /**
     * @dev Iterates over an array of routes and executes swaps.
     * @param routes An array of Route structs, each defining a swap path.
     * @param totalAmount The total amount of the loan to be distributed across the routes.
    */
    function routeLoop(Route[] memory routes, uint256 totalAmount) internal checkTotalRoutePart(routes) {
        uint256 length = routes.length;
        for (uint256 i = 0; i < length; ++i) { // cache routes.length for gas optimization // ++i
            // Calculates the amount to be used in the current route based on its part of the total loan.
                // If routes[i].part is 10000 (100%), then the amount to be used is the total amount.
                // This helps if you want to use a percentage of the total amount for this swap and keep the rest for other purposes like other swaps or other defi actions.
            // The partToAmountIn function from the Part library is used for this calculation.
            uint256 amountIn = Part.partToAmountIn(routes[i].part, totalAmount);
            console.log(totalAmount, "LOAN TOKEN AMOUNT TO SWAP");
            hopLoop(routes[i], amountIn);
        }
    }

    /**
    * @dev Processes a single route by iterating over each hop within the route.
    *      Each hop represents a token swap operation using a specific protocol.
    * @param route The Route struct representing a single route for token swaps.
    * @param totalAmount The amount of tokens to be swapped in this route.
    */
    function hopLoop(Route memory route, uint256 totalAmount) internal {
        uint256 amountIn = totalAmount;
        uint256 length = route.hops.length;

        for (uint256 i = 0; i < length; ++i) {
            // Executes the token swap for the current hop and updates the amount for the next hop.
            // The pickProtocol function determines the specific protocol to use for the swap.
            amountIn = pickProtocol(route.hops[i], amountIn);
        }
    }

    function pickProtocol(Hop memory hop, uint256 amountIn) internal returns (uint256 amountOut) {
        // Checks the protocol specified in the hop
        if(hop.protocol == 0){
            // If the protocol is Uniswap V3 (indicated by protocol number 0),
            // executes a swap using Uniswap V3's swap function.
            amountOut = uniswapV3(hop.data, amountIn, hop.path, hop.amountOutMinV3, hop.sqrtPriceLimitX96);
            console.log(amountOut, "AMOUNT OUT RECEIVED FROM PROTOCOL");
        } else if(hop.protocol < 8) {
            // If the protocol is Uniswap V2 or similar (protocols 1-7),
            // executes a swap using Uniswap V2's swap function.
            console.log("IN UNISWAP V2 SWAP");
            amountOut = uniswapV2(hop.data, amountIn, hop.path);
            console.log(amountOut, "AMOUNT OUT RECEIVED FROM PROTOCOL");
        } else {
            // For other protocols (protocol number 8 and above),
            // executes a swap using DODO V2's swap function.
            amountOut = dodoV2Swap(hop.data, amountIn, hop.path);
            console.log(amountOut, "AMOUNT OUT RECEIVED FROM PROTOCOL");
        }
    }

    function uniswapV3(
        bytes memory data,
        uint256 amountIn,
        address[] memory path,
        uint256 amountOutMinV3,
        uint160 sqrtPriceLimitX96
    ) internal returns (uint256 amountOut) {
        (address router, uint24 fee) = abi.decode(data, (address, uint24));

        ISwapRouter swapRouter = ISwapRouter(router);

        approveToken(path[0], address(swapRouter), amountIn);

        amountOut = swapRouter.exactInputSingle(
            ISwapRouter.ExactInputSingleParams({
                tokenIn: path[0],
                tokenOut: path[1],
                fee: fee,
                recipient: address(this),
                deadline: block.timestamp + 60, 
                amountIn: amountIn,
                amountOutMinimum: amountOutMinV3,
                sqrtPriceLimitX96: sqrtPriceLimitX96
            })
        );
    }

    function uniswapV2(
        bytes memory data,
        uint256 amountIn,
        address[] memory path
    ) internal returns (uint256 amountOut) {
        console.log("IN UNISWAP V2 SWAP");
        address router  = abi.decode(data, (address));

        approveToken(path[0], router, amountIn);
        
        uint[] memory amountOutMin = IUniswapV2Router(router).getAmountsOut(amountIn, path);
        uint256 minReturnAmount = amountOutMin[1] * slippage / 100;

        amountOut = IUniswapV2Router(router).swapExactTokensForTokens(
            amountIn,
            minReturnAmount,
            path,
            address(this),
            block.timestamp + 60
        )[1];
    }

    function dodoV2Swap(
        bytes memory data,
        uint256 amountIn,
        address[] memory path
    ) internal returns (uint256 amountOut) {
        (address dodoV2Pool, address dodoProxy) = abi.decode(data, (address, address));

        address[] memory dodoPairs = new address[](1);
        dodoPairs[0] = dodoV2Pool;

        uint256 directions = IDODO(dodoV2Pool)._BASE_TOKEN_() == path[0] ? 0 : 1; // finds out the directions of the swap

        approveToken(path[0], dodoV2Pool, amountIn);

        (uint256 receivedQuoteAmount, ) = IDODOV2(dodoV2Pool).querySellBase(msg.sender, amountIn);
        uint256 minReturnAmount = receivedQuoteAmount * (100 - slippage) / 100;

        amountOut = IDODOProxy(dodoProxy).dodoSwapV2TokenToToken(
            path[0],
            path[1],
            amountIn,
            minReturnAmount,
            dodoPairs,
            directions,
            false,
            block.timestamp + 60
        );
    }

    function approveToken(
        address token,
        address to,
        uint256 amountIn
    ) internal {
        require(IERC20(token).approve(to, amountIn), "Approve failed");
    }

    function setSlippage(uint256 _slippage) external onlyOwner() {
        slippage = _slippage;
    }

}


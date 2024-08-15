// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IFlashloan.sol";
import "../libraries/RouteUtils.sol";
import "../interfaces/IDODO.sol";

contract DodoBase is IFlashloan {

    function DVMFlashLoanCall( 
        address sender,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata data
    ) external {
        _flashLoanCallBack(sender, baseAmount, quoteAmount, data);
    }

    function DPPFlashLoanCall(
        address sender,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata data
    ) external {
        _flashLoanCallBack(sender, baseAmount, quoteAmount, data);
    }

    function DSPFlashLoanCall(
        address sender,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata data
    ) external {
        _flashLoanCallBack(sender, baseAmount, quoteAmount, data);
    }

    function _flashLoanCallBack(
        address,
        uint256,
        uint256,
        bytes calldata data
    ) internal virtual {}

    modifier checkParams(FlashParams memory params) {
        address loanToken = RouteUtils.getInitialToken(params.routes[0]);
        bool loanEqBase = loanToken == IDODO(params.flashLoanPool)._BASE_TOKEN_();
        bool loanEqQuote = loanToken == IDODO(params.flashLoanPool)._QUOTE_TOKEN_();
        require(loanEqBase || loanEqQuote, "Wrong flashloan pool address");
        _;
    }
}
import { ethers } from "ethers"
import { Protocols, Routers, dodoV2Pool, factories } from "../constants"
import { ERC20Token } from "../constants/tokens"
import { getPriceInUSDC } from "../utils/getPriceInUSDC"
import flashloan from "../artifacts/contracts/FlashLoan.sol/Flashloan.json";
import { FlashLoanParams } from "../types";
import { findRouterByProtocol } from "../utils/findRouterByProtocol";
import { executeFlashloan } from "./executeFlashloan";

const MIN_PRICE_DIFF = 1000000 // $10;

async function main() {
    // WETH / USDC POOLS
    const checkArbitrage = async () => {

        const provider = new ethers.JsonRpcProvider(process.env.PROVIDER_URL!);

        const sushiQuote = await getPriceInUSDC({
            router: Routers.POLYGON_SUSHISWAP,
            factory: factories.POLYGON_SUSHISWAP,
            tokenAddress: ERC20Token.WETH?.address,
            id: Protocols.SUSHISWAP,
            provider
        })

        console.log("Sushi Quote", sushiQuote);

        const quickQuote = await getPriceInUSDC({
            router: Routers.POLYGON_QUICKSWAP,
            factory: factories.POLYGON_QUICKSWAP,
            tokenAddress: ERC20Token.WETH?.address,
            id: Protocols.QUICKSWAP,
            provider
        })

        console.log("Sushi Quote", quickQuote);

        const apeQuote = await getPriceInUSDC({
            router: Routers.POLYGON_APESWAP,
            factory: factories.POLYGON_APESWAP,
            tokenAddress: ERC20Token.WETH?.address,
            id: Protocols.APESWAP,
            provider
        })

        const quotes = [sushiQuote, quickQuote]; 

        const min = quotes.reduce((min, obj) => (obj.quote < min.quote) ? obj : min);
        const max = quotes.reduce((max, obj) => (obj.quote > max.quote) ? obj : max);

        const biggestPriceDiff = max.quote - min.quote;

        console.log("Biggest price difference $", ethers.formatUnits(biggestPriceDiff, 6));

        if(true){
            // execute arbitrage flashloan
            const wallet = new ethers.Wallet(process.env.PRIVATE_KEY!, provider);
            const Flashloan = new ethers.Contract(process.env.FLASHLOAN_ADDRESS!, flashloan.abi, provider);

            const params: FlashLoanParams = {
                flashLoanContractAddress: Flashloan.target.toString(),
                flashLoanPool: dodoV2Pool.USDT_USDC,
                loanAmount: ethers.parseEther("1"),
                loanAmountDecimals: 6,
                hops: [
                    {
                        protocol: max.protocol,
                        data: ethers.AbiCoder.defaultAbiCoder().encode(
                            ["address"],
                            [findRouterByProtocol(min.protocol)]
                        ),
                        path: [ERC20Token.USDC?.address, ERC20Token.WETH?.address],
                        amountOutMinV3: 0,
                        sqrtPriceLimitX96: 0
                    },
                    {
                        protocol: min.protocol,
                        data: ethers.AbiCoder.defaultAbiCoder().encode(
                            ["address"],
                            [findRouterByProtocol(min.protocol)]
                        ),
                        path: [ERC20Token.WETH?.address, ERC20Token.USDC?.address],
                        amountOutMinV3: 0,
                        sqrtPriceLimitX96: 0
                    },
                ],
                gasLimit: 3_000_000,
                gasPrice: ethers.parseUnits("300", "gwei"),
                signer: wallet
            }

            const tx = await executeFlashloan(params);

            console.log(tx.hash, "TX HASH");

        }

    }

    try {
        // setInterval(checkArbitrage, 5000);
        checkArbitrage();
    } catch (error) {
        console.log(error);
    }

}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
  


import { ethers } from "ethers";
import { deployDodoFlashloan } from "../scripts/deployDodoFlashloan";
import { FlashLoanParams } from "../types";
import { Protocols, QUOTER_ADDRESS2, dodoV2Pool } from "../constants";
import { findRouterByProtocol } from "../utils/findRouterByProtocol";
import { ERC20Token } from "../constants/tokens";
import { executeFlashloan } from "../scripts/executeFlashloan";
import { fundErc20, impersonateFundERC20 } from "../utils/funding";
import { ERC20__factory } from "../typechain-types";
import { expect } from "chai";
import quoter2Abi from "../abis/quoter2Abi.json";
import flashloan from "../artifacts/contracts/FlashLoan.sol/Flashloan.json";

require('dotenv').config();

describe("DODO Flashloan", () => {

    it("Execute flashloan", async () => {

        const provider = new ethers.JsonRpcProvider(process.env.PROVIDER_URL!);

        const wallet = await provider.getSigner();

        console.log(wallet.address, 'wallet address');

        // const Flashloan = await deployDodoFlashloan({
        //     wallet
        // });

        const Flashloan = new ethers.Contract(process.env.FLASHLOAN_ADDRESS!, flashloan.abi, provider);

        const tokenContract = ERC20__factory.connect(ERC20Token.WETH?.address, provider);

        const mrWhale = "0xdeD8C5159CA3673f543D0F72043E4c655b35b96A";

        const flashLoanAddress = await Flashloan.getAddress();

        // await tokenContract.connect(wallet).transfer(flashLoanAddress, ethers.parseEther("0.001"));

        // @note Use this just once to fund the flashloan contract, make sure the whale does not get out of funds.
        await impersonateFundERC20({
            sender: mrWhale,
            tokenContract,
            recipient: flashLoanAddress,
            decimals: 18,
            amount: "1"
        })

        // expect(await tokenContract.balanceOf(flashLoanAddress)).to.equal(ethers.parseEther("1"));

        const params: FlashLoanParams = {
            flashLoanContractAddress: Flashloan.target.toString(),
            flashLoanPool: dodoV2Pool.WETH_ULT,
            loanAmount: ethers.parseEther("0.1"),
            hops: [
                {
                    protocol: Protocols.QUICKSWAP,
                    data: ethers.AbiCoder.defaultAbiCoder().encode(
                        ["address"],
                        [findRouterByProtocol(Protocols.QUICKSWAP)]
                    ),
                    path: [ERC20Token.WETH?.address, ERC20Token.USDC?.address],
                    amountOutMinV3: 0,
                    sqrtPriceLimitX96: 0
                },
                {
                    protocol: Protocols.SUSHISWAP,
                    data: ethers.AbiCoder.defaultAbiCoder().encode(
                        ["address"],
                        [findRouterByProtocol(Protocols.SUSHISWAP)]
                    ),
                    path: [ERC20Token.USDC?.address, ERC20Token.WETH?.address],
                    amountOutMinV3: 0,
                    sqrtPriceLimitX96: 0
                },
            ],
            gasLimit: 3_000_000,
            gasPrice: ethers.parseUnits("300", "gwei"),
            signer: wallet,
        }

        const tx = await executeFlashloan(params);
        console.log(tx);

        // expect(await tokenContract.balanceOf(flashLoanAddress)).to.equal(ethers.parseEther("0"));
        // expect(tx.hash).to.not.equal(null);
        // expect(tx.hash).to.not.equal(undefined);

        // const ownerBalance = await tokenContract.balanceOf(wallet.address);

        // expect(ownerBalance).to.be.gt(ethers.parseEther("0"));

    })

})
import { Contract } from "ethers";
import { ethers, network } from "hardhat";
import { FundingParams } from "../types";
import wethAbi from "../abis/polygonWethAbi.json";

export const fundErc20 = async (fundingParams: FundingParams) => {

    const {sender, tokenContract, amount, decimals, recipient} = fundingParams;

    const FUND_AMOUNT = ethers.parseUnits(amount, decimals);

    const mrWhale = await ethers.getSigner(sender);

    await tokenContract.connect(mrWhale).transfer(recipient, FUND_AMOUNT);
}

export const impersonateFundERC20 = async (fundingParams: FundingParams) => {

    await network.provider.request({
        method: "hardhat_impersonateAccount",
        params: [fundingParams.sender]
    })

    // fund baseToken to the contract
    await fundErc20(fundingParams);

    await network.provider.request({
        method: "hardhat_stopImpersonatingAccount",
        params: [fundingParams.sender]
    })

}
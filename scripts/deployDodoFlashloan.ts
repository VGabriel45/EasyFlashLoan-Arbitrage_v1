import { ethers } from "hardhat";
import { Flashloan, Flashloan__factory } from "../typechain-types";
import { DeployDODOFlashloanParams } from "../types";
import { deployContract } from "../utils/deployContract";

export async function deployDodoFlashloan(params: DeployDODOFlashloanParams) {
    const Flashloan: Flashloan = await deployContract(
        Flashloan__factory,
        [],
        params.wallet
    );

    const deployed = await Flashloan.waitForDeployment();

    console.log("contract deployed to:", deployed.target);

    return deployed;
}

const provider = new ethers.JsonRpcProvider(process.env.PROVIDER_URL!);
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY!, provider);
deployDodoFlashloan({wallet: wallet});
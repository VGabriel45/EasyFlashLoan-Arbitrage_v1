import { ethers } from "ethers";
import { Flashloan } from "../typechain-types";

export const deployContract = async (
    factoryType: any,
    args: Array<any> = [],
    wallet: ethers.Wallet | ethers.JsonRpcSigner
) => {

    const factory = new ethers.ContractFactory(
        factoryType.abi,
        factoryType.bytecode,
        wallet
    )

    const contract = await factory.deploy(...args);
    await contract.waitForDeployment();

    return contract as Flashloan;
}
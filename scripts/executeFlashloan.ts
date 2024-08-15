import { ethers } from "ethers";
import flashLoanJson from "../artifacts/contracts/FlashLoan.sol/Flashloan.json";
import { FlashLoanParams } from "../types";

export async function executeFlashloan(params: FlashLoanParams) {

    const Flashloan: any = new ethers.Contract(params.flashLoanContractAddress, flashLoanJson.abi, params.signer);

    const tx = await Flashloan.executeFlashloan(
        {
            flashLoanPool: params.flashLoanPool,
            loanAmount: params.loanAmount,
            routes: [
                {
                    hops: params.hops,
                    part: 10000
                }
            ]
        },
        {
            gasLimit: params.gasLimit,
            gasPrice: params.gasPrice
        }
    );

   return tx;
}
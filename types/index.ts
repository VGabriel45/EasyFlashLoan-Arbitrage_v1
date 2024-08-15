import {Contract, JsonRpcProvider, ethers} from "ethers";
import { ERC20 } from "../typechain-types";

export type FlashLoanParams = {
    flashLoanContractAddress: string;
    flashLoanPool: string;
    loanAmount: number | ethers.BigNumberish;
    loanAmountDecimals: number;
    hops: Hop[];
    gasLimit: number;
    gasPrice: number | bigint;
    signer: ethers.Signer;
};

export type Hop = {
    protocol: number,
    data: string,
    path: string[],
    amountOutMinV3?: number | ethers.BigNumberish,
    sqrtPriceLimitX96?: number | ethers.BigNumberish,
}

export type Protocol = {
    UNISWAP_V3: number,
    UNISWAP_V2: number,
    SUSHISWAP: number,
    QUICKSWAP: number,
    JETSWAP: number,
    POLYCAT: number,
    APESWAP: number,
    WAULTSWAP: number,
    DODO: number,
}

export type DeployDODOFlashloanParams = {
    wallet: ethers.Wallet | ethers.JsonRpcSigner
}

export type IToken = {
    symbol: string;
    name: string;
    decimals: number;
    address: string;
    logoURI: string;
}

export type FundingParams = {
    tokenContract: ERC20,
    sender: string,
    recipient: string,
    amount: string,
    decimals: number
}

export type PriceInUsdcParams = {
    router: string;
    factory: string;
    tokenAddress: string;
    id: number;
    provider: JsonRpcProvider;
}

export type erc20Token = { [erc20: string]: IToken };

export type RouterMap = { [protocol: string]: string };
import { HardhatUserConfig } from "hardhat/config";
import '@typechain/hardhat'
import '@nomicfoundation/hardhat-ethers'
import '@nomicfoundation/hardhat-chai-matchers'

import { config as dotEnvConfig } from "dotenv";
dotEnvConfig();

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.4",
      },
      {
        version: "0.6.12",
      },
      {
        version: "0.8.19",
      },
      {
        version: "0.8.20",
      },
    ],
  },
  networks: {
    localhost: {
      url: "http://localhost:8545",
    },
    polygon: {
      url: "https://rpc.ankr.com/polygon",
    },
    phalcon: {
      url: "https://rpc.phalcon.blocksec.com/rpc_fdbb12273b334aaba61d911c084a0001",
      chainId: 137
    }
  },
};

export default config;

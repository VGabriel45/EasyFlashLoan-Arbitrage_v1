Steps to initiate the project:

1. run yarn install || npm install 
2. run npx hardhat typechain
3. go to [Phalcon](https://app.blocksec.com/fork) and create your own mainnet Fork (Polygon)
4. get the "RPC" from phalcon and add it as an env variable "PROVIDER_URL"
5. add your private key in the env file as "PRIVATE_KEY"
6. run "npx hardhat run scripts/deployDodoFlashloan --network phalcon"
7. the address of your flashloan contract was printed in your terminal, copy and paste it as "FLASHLOAN_ADDRESS" env variable
8. you can now run "npx hardhat run scripts/arbitrage --network phalcon"
9. actively monitor the pool used in the script to borrow, it may run out of liquidity


[User]
  |
  |--- Calls ---> [dodoFlashLoan]
                   |
                   |--- Encodes data (FlashCallbackData) with loan details
                   |
                   |--- Initiates Flash Loan ---> [DODO Protocol]
                                                   |
                                                   |--- Provides loan
                                                   |--- Calls ---> [_flashLoanCallBack]
                                                                   |
                                                                   |--- Decodes FlashCallbackData
                                                                   |
                                                                   |--- Verifies receipt of loan amount
                                                                   |
                                                                   |--- Invokes ---> [routeLoop]
                                                                                      |
                                                                                      |--- Iterates over routes
                                                                                      |    |
                                                                                      |    |--- Calculates amount per route
                                                                                      |    |
                                                                                      |    |--- Invokes ---> [hopLoop]
                                                                                      |                         |
                                                                                      |                         |--- Iterates  over hops in route
                                                                                      |                         |    |
                                                                                      |                         |    |--- Selects protocol ---> [pickProtocol]
                                                                                      |                         |    |       |
                                                                                      |                         |    |       |--- Executes token swap (UniswapV3, UniswapV2, DODOV2)
                                                                                      |                         |    |       |
                                                                                      |                         |    |       |--- Returns swapped amount
                                                                                      |                         |
                                                                                      |                         |--- Updates amount for next hop
                                                                   |
                                                                   |--- Verifies ability to repay loan
                                                                   |
                                                                   |--- Repays Flash Loan to [DODO Protocol]
                                                                   |
                                                                   |--- Transfers any profit to [Contract Owner]# FlashLoanArbitrage
# EasyFlashLoan-Arbitrage_v1

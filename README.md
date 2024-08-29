# Welcome to the official repository of the Flashloan Arbitrage Project.

## This project has been used to teach over 300+ students in my first Udemy course. 
### You can find the course here: [https://www.udemy.com/course/how-to-actually-build-flashloan-arbitrage-bots]

As my inaugural course, I recognize there's a lot of room for improvement. By making this repository public, I aim to enhance accessibility and foster collaboration among learners.

This project is now open source, and I enthusiastically encourage contributions. Feel free to submit pull requests and improvements. 
For more information please contact me at vgabrielmarian21@gmail.com

Steps to initiate the project:

1. run yarn install || npm install 
2. run npx hardhat typechain
3. run "npx hardhat node --fork https://gateway.tenderly.co/public/polygon" (or choose your own Polygon rpc url to fork)
4. set the env variable "PROVIDER_URL" to be "http://127.0.0.1:8545/" (your local hardhat fork)
5. add your TEST private key (DO NOT USE A PRIVATE KEY THAT HOLDS REAL FUNDS) in the env file as "PRIVATE_KEY"
6. run "npx hardhat run scripts/deployDodoFlashloan --network localhost"
7. the address of your flashloan contract was printed in your terminal, copy and paste it as "FLASHLOAN_ADDRESS" env variable
8. you can now run "npx hardhat run scripts/arbitrage --network localhost" or "npx hardhat test test/index.test.ts"

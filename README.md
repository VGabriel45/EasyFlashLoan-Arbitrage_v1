# Welcome to the official repository of the Flashloan Arbitrage Project.

## This project has been used to teach over 300+ students in my first Udemy course. 
### You can find the course here: [https://www.udemy.com/course/how-to-actually-build-flashloan-arbitrage-bots]

As my inaugural course, I recognize there's a lot of room for improvement. By making this repository public, I aim to enhance accessibility and foster collaboration among learners.
While flash loan bots are typically individual projects (because of obvious financial reasons), I believe we can revolutionize this approach by working together. With over 300 students enrolled in the course, imagine the potential of 300 developers collaborating towards the same project, you will be able to learn a lot of stuff while potentially building a real Flashloan Arbitrage bot.

We've created a private Discord channel for active contributors and students. The primary goal isn't to generate profit (as the project is public and freely available for individual use), but rather to learn and collaborate together. If our collective efforts lead to a robust project capable of generating significant returns, we may consider closing this repository to test its potential. In such a case, any profits would be fairly distributed among all contributors.

This project is now open source, and I enthusiastically encourage contributions. Feel free to submit pull requests and improvements. 
For more information please contact me at vgabrielmarian21@gmail.com

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Withdraw is Ownable, ReentrancyGuard {

    event Withdrawal(address indexed sender, uint256 amount);

    constructor() Ownable(msg.sender) {}

    function withdrawToken(
        IERC20 token,
        address _to,
        uint256 _value
    ) public onlyOwner nonReentrant {
        require(token.balanceOf(address(this)) > _value, "Not enough token");
        SafeERC20.safeTransfer(token, _to, _value);
        emit Withdrawal(_to, _value);
    }

}
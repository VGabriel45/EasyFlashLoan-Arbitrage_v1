// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SignedMath.sol";

library Part {
    using SignedMath for uint256;
    using SignedMath for uint16;

    function partToAmountIn(uint16 part, uint256 total)
        internal
        pure
        returns (uint256 amountIn)
    {
        amountIn = (total * part) / 10**4;
    }
}

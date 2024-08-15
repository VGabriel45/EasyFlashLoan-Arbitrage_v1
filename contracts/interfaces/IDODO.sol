// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

interface IDODO {

    function flashLoan(
        uint256 baseAmount,
        uint256 quoteAmount,
        address assetTo,
        bytes calldata data
    ) external;

    function _BASE_TOKEN_() external view returns (address);
    function _BASE_RESERVE_() external view returns (address);
    function _QUOTE_TOKEN_() external view returns (address);
    function _QUOTE_RESERVE_() external view returns (address);

}
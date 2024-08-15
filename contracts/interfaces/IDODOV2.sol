// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
interface IDODOV2 {
    function querySellBase(
        address trader, 
        uint256 payBaseAmount
    ) external view  returns (uint256 receiveQuoteAmount,uint256 mtFee);

    function querySellQuote(
        address trader, 
        uint256 payQuoteAmount
    ) external view  returns (uint256 receiveBaseAmount,uint256 mtFee);
}
// // SPDX-License-Identifier: Unlicensed
// pragma solidity >=0.8.0;

// import {Direction} from "codegen/Types.sol";
// import {ScoreTable, TreasuryTable} from "codegen/Tables.sol";

// library LibTreasury {
//     function getPlayerTreasuryWinnings(address player) internal returns (uint256) {
//         uint256 treasury = getTreasury();
//         uint256 score = ScoreTable.get(player);
//         uint256 totalScore = ScoreTable.get(SingletonAddress);
//         uint256 winnings = (treasury * score) / uint256(totalScore);
//         return winnings;
//     }

//     function incrementTreasury(uint256 msgValue, uint256 rewardFraction) internal {
//         uint256 increment = (msgValue * (rewardFraction - 1)) / rewardFraction;
//         uint256 treasury = TreasuryTable.get(SingletonKey);
//         uint256 incremented = treasury + increment;
//         TreasuryTable.set(SingletonKey, incremented);
//     }

//     function getTreasury() internal view returns (uint256) {
//         return TreasuryTable.get(SingletonKey);
//     }
// }

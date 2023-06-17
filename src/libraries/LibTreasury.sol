// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0;

import {Direction} from "codegen/Types.sol";
import {Treasury, Spent, GameConfig} from "codegen/Tables.sol";

library LibTreasury {
    // function getPlayerTreasuryWinnings(address player) internal returns (uint256) {
    //     uint256 treasury = getTreasury();
    //     uint256 score = ScoreTable.get(player);
    //     uint256 totalScore = ScoreTable.get(SingletonAddress);
    //     uint256 winnings = (treasury * score) / uint256(totalScore);
    //     return winnings;
    // }

    function incrementTreasury(address msgSender, uint256 msgValue) internal {
        Treasury.set(Treasury.get() + msgValue);
        Spent.emitEphemeral(msgSender, GameConfig.getWordsPlayed(), block.timestamp, msgValue);
    }
}

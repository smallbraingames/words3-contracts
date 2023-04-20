// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0;

import {RewardsTable} from "codegen/Tables.sol";
import {ScoreTable} from "codegen/Tables.sol";
import {SpentTable} from "codegen/Tables.sol";

library LibPlayer {
    function incrementRewards(address player, uint256 increment) internal {
        uint256 previous = RewardsTable.get(player);
        RewardsTable.set(player, previous + increment);
    }

    function incrementSpent(address player, uint256 increment) internal {
        uint256 spent = SpentTable.get(player);
        SpentTable.set(player, spent + increment);
    }

    function incrementScore(address player, uint32 increment) internal {
        uint256 score = ScoreTable.get(player);
        ScoreTable.set(player, score + increment);
    }
}

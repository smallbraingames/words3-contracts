// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0;

import {Direction} from "codegen/Types.sol";
import {Treasury, Spent, Points, GameConfig} from "codegen/Tables.sol";

import {LibPoints} from "libraries/LibPoints.sol";

library LibTreasury {
    function getClaimAmount(address player) internal view returns (uint256) {
        uint256 treasury = Treasury.get();
        uint256 points = Points.get(player);
        uint32 totalPoints = LibPoints.getTotalPoints();
        uint256 claimAmount = (treasury * points) / uint256(totalPoints);
        return claimAmount;
    }

    function incrementTreasury(address msgSender, uint256 msgValue) internal {
        Treasury.set(Treasury.get() + msgValue);
        Spent.emitEphemeral(msgSender, GameConfig.getWordsPlayed(), block.timestamp, msgValue);
    }
}

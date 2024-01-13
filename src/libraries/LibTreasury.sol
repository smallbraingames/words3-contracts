// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0;

import {Direction} from "codegen/common.sol";
import {Treasury, Spent, Points, GameConfig} from "codegen/index.sol";

import {NoPoints} from "common/Errors.sol";
import {LibPoints} from "libraries/LibPoints.sol";

library LibTreasury {
    function getClaimAmount(address player) internal view returns (uint256) {
        uint256 treasury = Treasury.get();
        uint256 points = Points.get(player);
        if (points == 0) {
            revert NoPoints();
        }
        uint32 totalPoints = LibPoints.getTotalPoints();
        uint256 claimAmount = (treasury * points) / uint256(totalPoints);
        return claimAmount;
    }

    function incrementTreasury(address msgSender, uint256 msgValue) internal {
        uint256 incrementedTreasury = Treasury.get() + msgValue;
        Treasury.set(incrementedTreasury);
        Spent.set(msgSender, incrementedTreasury, msgValue);
    }
}

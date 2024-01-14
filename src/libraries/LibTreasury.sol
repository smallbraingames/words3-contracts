// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0;

import { Points, Spent, SpentMove, Treasury } from "codegen/index.sol";
import { NoPoints } from "common/Errors.sol";
import { LibPoints } from "libraries/LibPoints.sol";

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

    function getFeeAmount(uint256 value, uint16 feeBps) internal pure returns (uint256) {
        uint256 feeAmount = (value * uint256(feeBps)) / 10_000;
        return feeAmount;
    }

    function incrementTreasury(address msgSender, uint256 msgValue) internal {
        uint256 incrementedTreasury = Treasury.get() + msgValue;
        Treasury.set(incrementedTreasury);
        SpentMove.set(msgSender, incrementedTreasury, msgValue);
        incrementSpent(msgSender, msgValue);
    }

    function incrementSpent(address msgSender, uint256 msgValue) internal {
        uint256 incrementedSpent = Spent.get(msgSender) + msgValue;
        Spent.set(msgSender, incrementedSpent);
    }
}

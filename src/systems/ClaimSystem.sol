// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { ClaimRestrictionConfig, Points, PointsClaimedUpdate } from "codegen/index.sol";

import { LibPlayer } from "libraries/LibPlayer.sol";
import { LibTreasury } from "libraries/LibTreasury.sol";
import { LibUpdateId } from "libraries/LibUpdateId.sol";

contract ClaimSystem is System {
    error NotEnoughPoints();
    error WithinClaimRestrictionPeriod();

    function claim(uint32 points) public {
        uint256 claimRestrictionBlock = ClaimRestrictionConfig.getClaimRestrictionBlock();
        if (block.number <= claimRestrictionBlock) {
            revert WithinClaimRestrictionPeriod();
        }

        address player = _msgSender();

        uint32 playerPoints = Points.get({ player: player });
        if (points > playerPoints) {
            revert NotEnoughPoints();
        }

        uint256 claimAmount = LibTreasury.getClaimAmount({ points: points });

        LibPlayer.decrementPoints({ player: player, decrement: points });
        LibTreasury.decrementTreasury({ decrement: claimAmount });

        payable(player).transfer(claimAmount);

        PointsClaimedUpdate.set({
            id: LibUpdateId.getUpdateId(),
            player: player,
            points: points,
            value: claimAmount,
            timestamp: block.timestamp
        });
    }
}

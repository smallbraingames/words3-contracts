// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { Points } from "codegen/index.sol";

import { LibPlayer } from "libraries/LibPlayer.sol";
import { LibTreasury } from "libraries/LibTreasury.sol";

contract ClaimSystem is System {
    error AlreadyClaimed();
    error InvalidClaimAddress();
    error NotEnoughPoints();

    function claim(uint32 points) public {
        address player = _msgSender();

        uint32 playerPoints = Points.get({ player: player });
        if (points > playerPoints) {
            revert NotEnoughPoints();
        }

        uint256 claimAmount = LibTreasury.getClaimAmount({ points: points });
        LibPlayer.decrementPoints({ player: player, decrement: points });

        LibTreasury.decrementTreasury({ decrement: claimAmount });

        payable(player).transfer(claimAmount);
    }
}

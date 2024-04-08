// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { Points } from "codegen/index.sol";
import { SINGLETON_ADDRESS } from "common/Constants.sol";

import { LibPlayer } from "libraries/LibPlayer.sol";
import { LibTreasury } from "libraries/LibTreasury.sol";

contract ClaimSystem is System {
    error AlreadyClaimed();
    error InvalidClaimAddress();
    error NotEnoughPoints();

    function claim(uint32 points) public {
        address player = _msgSender();

        if (player == address(0) || player == SINGLETON_ADDRESS) {
            revert InvalidClaimAddress();
        }

        uint32 playerPoints = Points.get(player);
        if (points > playerPoints) {
            revert NotEnoughPoints();
        }

        LibPlayer.decrementPoints(player, points);
        uint256 claimAmount = LibTreasury.getClaimAmount(points);

        payable(player).transfer(claimAmount);
    }
}

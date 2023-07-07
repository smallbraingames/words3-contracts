// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Status} from "codegen/Types.sol";
import {Claimed} from "codegen/Tables.sol";

import {GameNotOver, AlreadyClaimed} from "common/Errors.sol";
import {LibGame} from "libraries/LibGame.sol";
import {LibTreasury} from "libraries/LibTreasury.sol";

import {System} from "@latticexyz/world/src/System.sol";

contract ClaimSystem is System {
    function claim(address player) public {
        if (LibGame.getGameStatus() != Status.OVER) {
            revert GameNotOver();
        }
        if (Claimed.get(player)) {
            revert AlreadyClaimed();
        }
        Claimed.set(player, true);
        uint256 claimAmount = LibTreasury.getClaimAmount(player);
        payable(player).transfer(claimAmount);
    }
}

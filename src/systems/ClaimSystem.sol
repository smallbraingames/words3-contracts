// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { SystemSwitch } from "@latticexyz/world-modules/src/utils/SystemSwitch.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { Status } from "codegen/common.sol";
import { Claimed } from "codegen/index.sol";
import { IWorld } from "codegen/world/IWorld.sol";
import { SINGLETON_ADDRESS } from "common/Constants.sol";
import { AlreadyClaimed, GameNotOver, InvalidAddress } from "common/Errors.sol";
import { LibGame } from "libraries/LibGame.sol";
import { LibTreasury } from "libraries/LibTreasury.sol";

contract ClaimSystem is System {
    function claim(address player) public {
        if (player == address(0) || player == SINGLETON_ADDRESS) {
            revert InvalidAddress();
        }
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

    function endAndClaim(address player) public {
        SystemSwitch.call(abi.encodeCall(IWorld(_world()).end, ()));
        claim(player);
    }
}

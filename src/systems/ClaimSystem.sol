// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { Claimed } from "codegen/index.sol";
import { SINGLETON_ADDRESS } from "common/Constants.sol";
import { LibTreasury } from "libraries/LibTreasury.sol";

contract ClaimSystem is System {
    error AlreadyClaimed();
    error InvalidClaimAddress();

    function claim(address player) public {
        if (player == address(0) || player == SINGLETON_ADDRESS) {
            revert InvalidClaimAddress();
        }
        if (Claimed.get(player)) {
            revert AlreadyClaimed();
        }
        Claimed.set(player, true);
        uint256 claimAmount = LibTreasury.getClaimAmount(player);
        payable(player).transfer(claimAmount);
    }
}

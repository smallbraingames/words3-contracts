// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { SystemSwitch } from "@latticexyz/world-modules/src/utils/SystemSwitch.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { Status } from "codegen/common.sol";
import { Claimed } from "codegen/index.sol";
import { SINGLETON_ADDRESS } from "common/Constants.sol";
import { InvalidAddress } from "common/Errors.sol";
import { LibGame } from "libraries/LibGame.sol";
import { LibTreasury } from "libraries/LibTreasury.sol";

contract DrawSystem is System {
    function draw(address player) public payable {
        if (player == address(0) || player == SINGLETON_ADDRESS) {
            revert InvalidAddress();
        }

        // Randomly draw from a set of scrabble letters
        
    }
}

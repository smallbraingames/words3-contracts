// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { LibGame } from "libraries/LibGame.sol";
import { LibTreasury } from "libraries/LibTreasury.sol";

contract DonateSystem is System {
    error DonateBeforeStarted();

    function donate() public payable {
        if (!LibGame.canPlay()) {
            revert DonateBeforeStarted();
        }
        LibTreasury.incrementTreasury(address(0), _msgValue());
    }
}

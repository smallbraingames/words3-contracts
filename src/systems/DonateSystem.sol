// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {CannotPlay} from "common/Errors.sol";
import {LibGame} from "libraries/LibGame.sol";
import {LibTreasury} from "libraries/LibTreasury.sol";

import {System} from "@latticexyz/world/src/System.sol";

contract DonateSystem is System {
    function donate() public payable {
        if (!LibGame.canPlay()) {
            revert CannotPlay();
        }
        LibTreasury.incrementTreasury(address(0), msg.value);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Points} from "codegen/Tables.sol";

import {SINGLETON_ADDRESS} from "common/Constants.sol";

library LibPlayer {
    function incrementScore(address player, uint32 increment) internal {
        uint32 currentPoints = Points.get(player);
        uint32 currentTotalPoints = Points.get(SINGLETON_ADDRESS);
        Points.set(player, currentPoints + increment);
        Points.set(SINGLETON_ADDRESS, currentTotalPoints + increment);
    }
}

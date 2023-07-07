// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Points} from "codegen/Tables.sol";

import {SingletonAddress} from "libraries/LibPoints.sol";

library LibPlayer {
    function incrementScore(address player, uint32 increment) internal {
        uint32 currentPoints = Points.get(player);
        uint32 currentTotalPoints = Points.get(SingletonAddress);
        Points.set(player, currentPoints + increment);
        Points.set(SingletonAddress, currentTotalPoints + increment);
    }
}

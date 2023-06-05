// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Points} from "codegen/Tables.sol";

library LibPlayer {
    function incrementScore(address player, uint32 increment) internal {
        uint32 currentPoints = Points.get(player);
        Points.set(player, currentPoints + increment);
    }
}

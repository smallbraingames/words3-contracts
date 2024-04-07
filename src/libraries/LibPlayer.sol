// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Points } from "codegen/index.sol";
import { SINGLETON_ADDRESS } from "common/Constants.sol";

library LibPlayer {
    function incrementPoints(address player, uint32 increment) internal {
        uint32 currentPoints = Points.get(player);
        uint32 currentTotalPoints = Points.get(SINGLETON_ADDRESS);
        Points.set(player, currentPoints + increment);
        Points.set(SINGLETON_ADDRESS, currentTotalPoints + increment);
    }

    function decrementPoints(address player, uint32 decrement) internal {
        uint32 currentPoints = Points.get(player);
        uint32 currentTotalPoints = Points.get(SINGLETON_ADDRESS);
        Points.set(player, currentPoints - decrement);
        Points.set(SINGLETON_ADDRESS, currentTotalPoints - decrement);
    }
}

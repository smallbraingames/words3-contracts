// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Points } from "codegen/index.sol";
import { SINGLETON_ADDRESS } from "common/Constants.sol";

library LibPlayer {
    function incrementPoints(address player, uint32 increment) internal {
        uint32 currentPoints = Points.get({ player: player });
        uint32 currentTotalPoints = Points.get({ player: SINGLETON_ADDRESS });
        Points.set({ player: player, value: currentPoints + increment });
        Points.set({ player: SINGLETON_ADDRESS, value: currentTotalPoints + increment });
    }

    function decrementPoints(address player, uint32 decrement) internal {
        uint32 currentPoints = Points.get({ player: player });
        uint32 currentTotalPoints = Points.get({ player: SINGLETON_ADDRESS });
        Points.set({ player: player, value: currentPoints - decrement });
        Points.set({ player: SINGLETON_ADDRESS, value: currentTotalPoints - decrement });
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { Config } from "codegen/index.sol";

contract SetConfigSystem is System {
    error AlreadySet();

    function setConfig(uint256 period) public {
        bool set = Config.getValueSet();
        if (set) {
            revert AlreadySet();
        }
        Config.set({ period: period, valueSet: true });
    }
}

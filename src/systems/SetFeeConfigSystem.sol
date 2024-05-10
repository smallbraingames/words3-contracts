// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { FeeConfig, FeeConfigData } from "codegen/index.sol";

contract SetFeeConfigSystem is System {
    error NotFeeTaker();

    function setFeeConfig(uint16 feeBps, address feeTaker) public {
        FeeConfigData memory feeConfig = FeeConfig.get();
        if (_msgSender() != feeConfig.feeTaker) {
            revert NotFeeTaker();
        }
        FeeConfig.set({ feeBps: feeBps, feeTaker: feeTaker });
    }
}

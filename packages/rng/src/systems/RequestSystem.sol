// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { Request } from "codegen/index.sol";
import { LibId } from "libraries/LibId.sol";

contract RequestSystem is System {
    function request() public returns (uint256) {
        uint256 id = LibId.getId();
        Request.set({ id: id, timestamp: block.timestamp, blockNumber: block.number });
        return id;
    }
}

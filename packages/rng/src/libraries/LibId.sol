// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Id } from "codegen/index.sol";

library LibId {
    function getId() internal returns (uint256) {
        uint256 id = Id.get();
        Id.set({ value: id + 1 });
        return id + 1;
    }
}

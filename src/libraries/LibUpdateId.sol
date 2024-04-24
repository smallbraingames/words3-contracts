// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { UpdateId } from "codegen/index.sol";

library LibUpdateId {
    function getUpdateId() internal returns (uint256) {
        uint256 id = UpdateId.get() + 1;
        UpdateId.set({ value: id });
        return id;
    }
}

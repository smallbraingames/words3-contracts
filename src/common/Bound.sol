// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Letter} from "codegen/Types.sol";

// Bounds for a given letter
struct Bound {
    uint16 positive;
    uint16 negative;
    bytes32[] proof;
}

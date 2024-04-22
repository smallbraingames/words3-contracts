// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

// Bounds for a given letter
struct Bound {
    uint16 positive;
    uint16 negative;
    bytes32[] proof;
}

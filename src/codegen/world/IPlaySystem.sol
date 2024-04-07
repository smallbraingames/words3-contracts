// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { Direction, Letter } from "codegen/common.sol";

import { Bound } from "common/Bound.sol";
import { Coord } from "common/Coord.sol";

/**
 * @title IPlaySystem
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface IPlaySystem {
    error CannotPlay();
    error MissingLetters();

    function play(
        Letter[] memory word,
        bytes32[] memory proof,
        Coord memory coord,
        Direction direction,
        Bound[] memory bounds
    )
        external;
}

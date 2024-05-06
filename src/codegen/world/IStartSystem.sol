// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

import { Letter } from "codegen/common.sol";

/**
 * @title IStartSystem
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface IStartSystem {
  error GameAlreadyStarted();

  function start(
    Letter[] memory initialWord,
    bytes32 merkleRoot,
    uint256 initialPrice,
    uint256 minPrice,
    int256 wadFactor,
    int256 wadDurationRoot,
    int256 wadDurationScale,
    int256 wadDurationConstant,
    uint32 crossWordRewardFraction,
    uint16 bonusDistance,
    uint8 numDrawLetters
  ) external;
}

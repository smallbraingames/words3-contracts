// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

import { Letter, Coord, Direction, Bounds } from "./../../systems/BoardSystem.sol";

interface IBoardSystem {
  function play(
    Letter[] memory word,
    bytes32[] memory proof,
    Coord memory coord,
    Direction direction,
    Bounds memory bounds
  ) external payable;

  function claimPayout() external;

  function checkWord(
    Letter[] memory word,
    bytes32[] memory proof,
    Coord memory coord,
    Direction direction
  ) external view;

  function getLetterPrice(Letter letter, int256 totalWeight) external view returns (uint256);

  function getWordPrice(Letter[] memory word) external view returns (uint256);
}

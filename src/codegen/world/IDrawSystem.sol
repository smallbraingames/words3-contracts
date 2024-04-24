// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

/**
 * @title IDrawSystem
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface IDrawSystem {
  error InvalidDrawAddress();
  error NotEnoughValue();

  function draw(address player) external payable;

  function getDrawPrice() external view returns (uint256);
}
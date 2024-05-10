// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

/**
 * @title ISetFeeConfigSystem
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface ISetFeeConfigSystem {
    error NotFeeTaker();

    function setFeeConfig(uint16 feeBps, address feeTaker) external;
}
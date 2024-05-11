// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

/**
 * @title IClaimSystem
 * @author MUD (https://mud.dev) by Lattice (https://lattice.xyz)
 * @dev This interface is automatically generated from the corresponding system contract. Do not edit manually.
 */
interface IClaimSystem {
    error NotEnoughPoints();
    error WithinClaimRestrictionPeriod();

    function claim(uint32 points) external;
}

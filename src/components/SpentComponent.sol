// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0;

import {Uint256BareComponent} from "std-contracts/components/Uint256BareComponent.sol";

uint256 constant ID = uint256(keccak256("component.Spent"));

contract SpentComponent is Uint256BareComponent {
    constructor(address world) Uint256BareComponent(world, ID) {}
}

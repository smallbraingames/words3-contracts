// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0;

import {Int256BareComponent} from "common/Int256BareComponent.sol";

uint256 constant ID = uint256(keccak256("component.LetterWeight"));

contract LetterWeightComponent is Int256BareComponent {
    constructor(address world) Int256BareComponent(world, ID) {}
}

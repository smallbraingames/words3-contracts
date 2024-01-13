// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {MudTest} from "@latticexyz/world/test/MudTest.t.sol";

contract Words3Test is MudTest {
    address deployerAddress;

    function setUp() public virtual override {
        super.setUp();
        deployerAddress = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    }
}

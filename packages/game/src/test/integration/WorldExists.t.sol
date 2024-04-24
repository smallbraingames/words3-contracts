// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "codegen/world/IWorld.sol";

import { Words3Test } from "../Words3Test.t.sol";
import "forge-std/Test.sol";

contract WorldExists is Words3Test {
    function testWorldExists() public {
        uint256 codeSize;
        address addr = worldAddress;
        assembly {
            codeSize := extcodesize(addr)
        }
        assertTrue(codeSize > 0);
    }
}

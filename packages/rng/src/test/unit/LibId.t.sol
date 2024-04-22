// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { RngTest } from "../RngTest.t.sol";
import { LibId } from "libraries/LibId.sol";

contract LibIdTest is RngTest {
    function test_IdsIncrement() public {
        uint256 id1 = world.rng__request({ period: 1 });
        uint256 id2 = world.rng__request({ period: 2 });
        assertTrue(id1 < id2);
    }
}

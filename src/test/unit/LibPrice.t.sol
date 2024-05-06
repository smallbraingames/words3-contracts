// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;
/* solhint-disable no-global-import */
/* solhint-disable func-name-mixedcase */

import { Words3Test } from "../Words3Test.t.sol";
import "forge-std/Test.sol";
import { LibPrice } from "libraries/LibPrice.sol";
import { fromDaysWadUnsafe, toWadUnsafe, unsafeWadDiv, wadPow } from "solmate/src/utils/SignedWadMath.sol";

contract LibPriceTest is Words3Test {
    function test_WadRoot() public {
        assertApproxEqRel(uint256(LibPrice.wadRoot(1e18, 2e18)), 1e18, 1);
        assertApproxEqRel(uint256(LibPrice.wadRoot(1e18, 3e18)), 1e18, 1);
        assertApproxEqRel(uint256(LibPrice.wadRoot(1e18, 4e18)), 1e18, 1);
        assertApproxEqRel(uint256(LibPrice.wadRoot(4e18, 2e18)), 2e18, 1);
        assertApproxEqRel(uint256(LibPrice.wadRoot(9e18, 2e18)), 3e18, 1);
        assertApproxEqRel(uint256(LibPrice.wadRoot(16e18, 4e18)), 2e18, 1);
    }

    function testFuzz_WadRootWhole(uint128 a, uint128 power) public {
        a = uint128(bound(a, 1, 50));
        power = uint128(bound(power, 1, 20));
        uint128 b = a ** power;
        int256 c = LibPrice.wadRoot(toWadUnsafe(b), toWadUnsafe(power));
        assertApproxEqRel(uint256(c), uint256(toWadUnsafe(uint256(a))), 1e3);
    }

    function testFuzz_WadRootFraction(uint128 a, uint32 power) public {
        power = uint32(bound(power, 10, 90));
        a = uint128(bound(a, 1, 50));
        int256 wadPower = int256(uint256(power)) * 1e17;
        int256 b = wadPow(toWadUnsafe(a), wadPower);
        int256 c = LibPrice.wadRoot(b, wadPower);
        assertApproxEqRel(uint256(c), uint256(toWadUnsafe(uint256(a))), 1e3);
    }

    function test_WadRootFraction() public {
        assertApproxEqRel(uint256(LibPrice.wadRoot(4e18, 1.5e18)), 2.51984209979e18, 1e8);
        assertApproxEqRel(uint256(LibPrice.wadRoot(12e18, 3.6e18)), 1.99421770808e18, 1e8);
    }
}

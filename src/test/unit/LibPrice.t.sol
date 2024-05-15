// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;
/* solhint-disable no-global-import */
/* solhint-disable func-name-mixedcase */

import { Words3Test } from "../Words3Test.t.sol";

import { Wrapper } from "./Wrapper.sol";
import "forge-std/Test.sol";
import { LibPrice } from "libraries/LibPrice.sol";
import { toWadUnsafe, wadPow } from "solmate/src/utils/SignedWadMath.sol";
import { wadDiv, wadMul, wadPow } from "solmate/src/utils/SignedWadMath.sol";

contract LibPriceTest is Words3Test {
    function test_WadRoot() public {
        assertApproxEqRel(uint256(LibPrice.wadRoot(1e18, 2e18)), 1e18, 1);
        assertApproxEqRel(uint256(LibPrice.wadRoot(1e18, 3e18)), 1e18, 1);
        assertApproxEqRel(uint256(LibPrice.wadRoot(1e18, 4e18)), 1e18, 1);
        assertApproxEqRel(uint256(LibPrice.wadRoot(4e18, 2e18)), 2e18, 1);
        assertApproxEqRel(uint256(LibPrice.wadRoot(9e18, 2e18)), 3e18, 1);
        assertApproxEqRel(uint256(LibPrice.wadRoot(16e18, 4e18)), 2e18, 1);
        assertApproxEqRel(uint256(LibPrice.wadRoot(16e18, 4e18)), 2e18, 1);
        assertApproxEqRel(uint256(LibPrice.wadRoot(12e18, 3e18)), 2.28942848511e18, 0.00001e18);
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

    function test_ToWad() public {
        assertEq(LibPrice.toWad(1), 1e18);
        assertEq(LibPrice.toWad(15), 15e18);
        assertEq(LibPrice.toWad(1.5e18), 1.5e36);
        assertEq(LibPrice.toWad(1e9 ether), 1e45);
        // Reverts on overflow
        Wrapper w = new Wrapper();
        uint256 maxUint = 2 ** 256 - 1;
        vm.expectRevert();
        w.priceToWad(maxUint / 1e18);
        vm.expectRevert();
        w.priceToWad(maxUint);
    }

    function testFuzz_ToWad(uint256 x) public {
        x = bound(x, 1, uint256(type(int256).max / 1e18));
        int256 wad = LibPrice.toWad(x);
        assertEq(uint256(wad), x * 1e18);
    }

    function test_GetF() public {
        assertEq(
            LibPrice.getF({ x: 1.3e18, wadPower: 0.8e18, wadScale: 550e18, wadConstant: 7e18 }),
            452_869_748_949_216_062_373
        );
    }

    function test_GetInverseF() public {
        assertApproxEqRel(
            LibPrice.getInverseF({
                y: 452_869_748_949_216_062_373,
                wadPower: 0.8e18,
                wadScale: 550e18,
                wadConstant: 7e18
            }),
            1.3e18,
            5
        );
    }

    function testFuzz_GetFMatchesInverse(int256 x, int256 wadPower, int256 wadScale, int256 wadConstant) public {
        x = int256(bound(uint256(x), 1e18, 300e18 * 1e18));
        wadPower = int256(bound(uint256(wadPower), 0.1e18, 1e18));
        wadScale = int256(bound(uint256(wadScale), 1e18, 1e45));
        wadConstant = int256(bound(uint256(wadConstant), 0.000000001 ether * 1e18, 1000 ether * 1e18));

        int256 f = LibPrice.getF({ x: x, wadPower: wadPower, wadScale: wadScale, wadConstant: wadConstant });
        vm.assume(f > (wadConstant + 5e13));
        int256 y = LibPrice.getInverseF({ y: f, wadPower: wadPower, wadScale: wadScale, wadConstant: wadConstant });
        if (y > 100 && x > 100) {
            assertApproxEqRel(uint256(y), uint256(x), 1e17);
        } else {
            assertTrue((y > x ? y - x : x - y) < 10);
        }
    }

    function testFuzz_GetFMatchesInverseTightlyInReasonableBounds(uint256 x) public {
        x = bound(x, 0.01e18, 80e24);
        int256 f = LibPrice.getF({ x: int256(x), wadPower: 0.9e18, wadScale: 9.96e36, wadConstant: 0.001 ether * 1e18 });
        int256 y = LibPrice.getInverseF({ y: f, wadPower: 0.9e18, wadScale: 9.96e36, wadConstant: 0.001 ether * 1e18 });
        assertApproxEqRel(uint256(y), x, 1000);

        int256 f2 = LibPrice.getF({ x: int256(x), wadPower: 0.8e18, wadScale: 5.6e36, wadConstant: 0.001 ether * 1e18 });
        int256 y2 = LibPrice.getInverseF({ y: f2, wadPower: 0.8e18, wadScale: 5.6e36, wadConstant: 0.001 ether * 1e18 });
        assertApproxEqRel(uint256(y2), x, 1000);

        int256 f3 =
            LibPrice.getF({ x: int256(x), wadPower: 0.23e18, wadScale: 3.4e36, wadConstant: 0.001 ether * 1e18 });
        int256 y3 =
            LibPrice.getInverseF({ y: f3, wadPower: 0.23e18, wadScale: 3.4e36, wadConstant: 0.001 ether * 1e18 });
        assertApproxEqRel(uint256(y3), x, 1000);
    }

    function testFuzz_GetPriceNeverBelowMin(
        int256 wadStartPrice,
        uint256 minPrice,
        int256 wadPower,
        int256 wadScale,
        int256 wadPassed
    )
        public
    {
        minPrice = bound(minPrice, 0.000001 ether, 1e6 ether);
        int256 wadMinPrice = LibPrice.toWad(minPrice);
        // Make sure start price is always at least 1% higher than the min
        wadStartPrice = int256(bound(uint256(wadStartPrice), uint256(wadMul(wadMinPrice, 1.01e18)), 1e50));
        wadPower = int256(bound(uint256(wadPower), 0.1e18, 0.99e18));
        wadScale = int256(bound(uint256(wadScale), 1e18, 1e39));
        wadPassed = int256(bound(uint256(wadPassed), 1e18, 1e26));

        uint256 price = LibPrice.getPrice({
            wadStartPrice: wadStartPrice,
            wadMinPrice: wadMinPrice,
            wadPower: wadPower,
            wadScale: wadScale,
            wadPassed: wadPassed
        });
        assertTrue(price >= minPrice);
    }
}

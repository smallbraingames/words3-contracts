// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;
/* solhint-disable no-global-import */
/* solhint-disable func-name-mixedcase */

import { Words3Test } from "../Words3Test.t.sol";

import { Wrapper } from "./Wrapper.sol";
import "forge-std/Test.sol";
import { LibPrice } from "libraries/LibPrice.sol";
import { toWadUnsafe, wadPow } from "solmate/src/utils/SignedWadMath.sol";

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

    function test_GetGDADuration() public {
        assertEq(
            LibPrice.getGDADuration({
                wadStartPrice: 1e18,
                wadDurationRoot: 1e18,
                wadDurationScale: 1e18,
                wadDurationConstant: 1e18
            }),
            3
        );
        assertEq(
            LibPrice.getGDADuration({
                wadStartPrice: 12e18,
                wadDurationRoot: 3e18,
                wadDurationScale: 10e18,
                wadDurationConstant: 18e18
            }),
            41
        );
        assertEq(
            LibPrice.getGDADuration({
                wadStartPrice: 100_000_000e18,
                wadDurationRoot: 12e18,
                wadDurationScale: 15_000e18,
                wadDurationConstant: 23e18
            }),
            69_647
        );
        assertEq(
            LibPrice.getGDADuration({
                wadStartPrice: LibPrice.toWad(0.00034 ether),
                wadDurationRoot: 1.7e18,
                wadDurationScale: 1.72e11,
                wadDurationConstant: 60e18
            }),
            121
        );
        assertEq(
            LibPrice.getGDADuration({
                wadStartPrice: LibPrice.toWad(0.0034 ether),
                wadDurationRoot: 1.7e18,
                wadDurationScale: 1.72e11,
                wadDurationConstant: 60e18
            }),
            296
        );
        assertEq(
            LibPrice.getGDADuration({
                wadStartPrice: LibPrice.toWad(0.0182 ether),
                wadDurationRoot: 1.7e18,
                wadDurationScale: 1.72e11,
                wadDurationConstant: 60e18
            }),
            692
        );
        assertEq(
            LibPrice.getGDADuration({
                wadStartPrice: LibPrice.toWad(100_000_000 ether),
                wadDurationRoot: 1.7e18,
                wadDurationScale: 1.72e11,
                wadDurationConstant: 60e18
            }),
            338_568_205
        );
        assertEq(
            LibPrice.getGDADuration({
                wadStartPrice: LibPrice.toWad(0.1231 ether),
                wadDurationRoot: 1.54e18,
                wadDurationScale: 1.322e11,
                wadDurationConstant: 99e18
            }),
            16_650
        );
    }

    function test_GetGDAPrice() public {
        assertEq(LibPrice.getGDAPrice({ startPrice: 1, endPrice: 1, duration: 1, passed: 1 }), 1);
        assertEq(
            LibPrice.getGDAPrice({ startPrice: 100 ether, endPrice: 1 ether, duration: 1000, passed: 1 }), 99.901 ether
        );

        assertEq(
            LibPrice.getGDAPrice({
                startPrice: 23_892_398_384,
                endPrice: 132_932_832,
                duration: 1_000_939_329_239,
                passed: 328_328
            }),
            2.3892390591e10
        );

        assertEq(
            LibPrice.getGDAPrice({
                startPrice: 9_932_832_832 ether,
                endPrice: 1_730_492 ether,
                duration: 239,
                passed: 238
            }),
            43_283_221_456_066_945_606_694_561
        );
    }

    function testFuzz_GetGDAPriceNeverBelowEndPrice(
        uint256 startPrice,
        uint256 endPrice,
        uint256 duration,
        uint256 passed
    )
        public
    {
        passed = bound(passed, 0, uint256(type(uint128).max));
        startPrice = bound(startPrice, 0, uint256(type(uint128).max));
        uint256 price =
            LibPrice.getGDAPrice({ startPrice: startPrice, endPrice: endPrice, duration: duration, passed: passed });
        assertTrue(price >= endPrice);
    }
}

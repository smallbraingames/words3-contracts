// SPDX-License-Identifier: MIT
// Linear VRGDA tests adapted from https://github.com/transmissions11/VRGDAs/blob/master/test/LinearVRGDA.t.sol
pragma solidity >=0.8.0;

import { Direction, Letter } from "codegen/common.sol";
import { DrawCount, VRGDAConfig } from "codegen/index.sol";
import { IWorld } from "codegen/world/IWorld.sol";

import { NotEnoughValue } from "common/Errors.sol";
import { LibPrice } from "libraries/LibPrice.sol";

import { Words3Test } from "../Words3Test.t.sol";
import "forge-std/Test.sol";
import {
    fromDaysWadUnsafe, toDaysWadUnsafe, toWadUnsafe, unsafeWadDiv, wadPow
} from "solmate/src/utils/SignedWadMath.sol";

contract LibPriceTest is Words3Test {
    function testWadRoot() public {
        assertRelApproxEq(uint256(LibPrice.wadRoot(1e18, 2e18)), 1e18, 1);
        assertRelApproxEq(uint256(LibPrice.wadRoot(1e18, 3e18)), 1e18, 1);
        assertRelApproxEq(uint256(LibPrice.wadRoot(1e18, 4e18)), 1e18, 1);
        assertRelApproxEq(uint256(LibPrice.wadRoot(4e18, 2e18)), 2e18, 1);
        assertRelApproxEq(uint256(LibPrice.wadRoot(9e18, 2e18)), 3e18, 1);
        assertRelApproxEq(uint256(LibPrice.wadRoot(16e18, 4e18)), 2e18, 1);
    }

    function testFuzzWadRootWhole(uint128 a, uint128 power) public {
        vm.assume(power < 20 && power > 0);
        vm.assume(a < 50 && a > 0);
        uint128 b = a ** power;
        int256 c = LibPrice.wadRoot(toWadUnsafe(b), toWadUnsafe(power));
        assertRelApproxEq(uint256(c), uint256(toWadUnsafe(uint256(a))), 1e3);
    }

    function testFuzzWadRootFraction(uint128 a, uint32 power) public {
        power = uint32(bound(power, 10, 90));
        a = uint128(bound(a, 1, 50));
        int256 wadPower = int256(uint256(power)) * 1e17;
        int256 b = wadPow(toWadUnsafe(a), wadPower);
        int256 c = LibPrice.wadRoot(b, wadPower);
        assertRelApproxEq(uint256(c), uint256(toWadUnsafe(uint256(a))), 1e3);
    }

    function testWadRootFraction() public {
        assertRelApproxEq(uint256(LibPrice.wadRoot(4e18, 1.5e18)), 2.51984209979e18, 1e8);
        assertRelApproxEq(uint256(LibPrice.wadRoot(12e18, 3.6e18)), 1.99421770808e18, 1e8);
    }

    // Test with true values
    function testTargetPrice() public {
        vm.startPrank(deployerAddress);
        VRGDAConfig.set({
            startTime: block.timestamp,
            targetPrice: 1e18,
            priceDecay: 0.5e18,
            perDayInitial: 20e18,
            power: 1.3e18
        });

        uint256 start = block.timestamp;

        DrawCount.set(uint32(20));
        vm.warp(start + 1 days);
        assertRelApproxEq(LibPrice.getDrawPrice(), 1e18, 0.03e18);

        DrawCount.set(uint32(49));
        vm.warp(start + 2 days);
        assertRelApproxEq(LibPrice.getDrawPrice(), 1e18, 0.03e18);

        DrawCount.set(uint32(83));
        vm.warp(start + 3 days);
        assertRelApproxEq(LibPrice.getDrawPrice(), 1e18, 0.03e18);

        DrawCount.set(uint32(121));
        vm.warp(start + 4 days);
        assertRelApproxEq(LibPrice.getDrawPrice(), 1e18, 0.03e18);

        DrawCount.set(uint32(162));
        vm.warp(start + 5 days);
        assertRelApproxEq(LibPrice.getDrawPrice(), 1e18, 0.03e18);

        DrawCount.set(uint32(205));
        vm.warp(start + 6 days);
        assertRelApproxEq(LibPrice.getDrawPrice(), 1e18, 0.03e18);

        vm.stopPrank();
    }

    function testFuzzDoesNotRevertWithReasonableValues(
        uint256 targetPriceRaw,
        uint256 priceDecayRaw,
        uint256 perDayInitialRaw,
        uint256 powerRaw,
        uint256 time,
        uint32 drawCount
    )
        public
    {
        int256 targetPrice = int256(bound(targetPriceRaw, 0.003e18, 1e19));
        int256 priceDecay = int256(bound(priceDecayRaw, 0.003e18, 0.999e18));
        uint256 perDayInitialNonWad = bound(perDayInitialRaw, 1, 1000);
        int256 power = int256(bound(powerRaw, 1e18, 5e18));
        time = bound(time, 1, 1000 days);
        drawCount = uint32(bound(drawCount, 0, uint256(perDayInitialNonWad * 5)));

        vm.startPrank(deployerAddress);
        VRGDAConfig.set({
            startTime: block.timestamp,
            targetPrice: targetPrice,
            priceDecay: priceDecay,
            perDayInitial: toWadUnsafe(perDayInitialNonWad),
            power: power
        });
        DrawCount.set(drawCount);
        vm.stopPrank();
        vm.warp(block.timestamp + time);

        // This should not revert
        LibPrice.getDrawPrice();
    }

    function testFuzzAroundConstantsDoNotRevertWithReasonableValues(
        uint256 targetPriceRaw,
        uint256 priceDecayRaw,
        uint256 perDayInitialRaw,
        uint256 powerRaw,
        uint256 time,
        uint32 drawCount
    )
        public
    {
        int256 targetPrice = int256(bound(targetPriceRaw, 0.003e18, 0.06e18));
        int256 priceDecay = int256(bound(priceDecayRaw, 0.3e18, 0.8e18));
        uint256 perDayInitialNonWad = bound(perDayInitialRaw, 10, 100);
        int256 power = int256(bound(powerRaw, 1.2e18, 5e18));
        uint256 timeDays = bound(time, 0, 8);
        time = bound(time, 1 + timeDays * 86_400, 9 days);
        drawCount = uint32(bound(drawCount, 0, perDayInitialNonWad * 5 * (timeDays + 1)));

        vm.startPrank(deployerAddress);
        VRGDAConfig.set({
            startTime: block.timestamp,
            targetPrice: targetPrice,
            priceDecay: priceDecay,
            perDayInitial: toWadUnsafe(perDayInitialNonWad),
            power: power
        });
        DrawCount.set(drawCount);
        vm.stopPrank();
        vm.warp(block.timestamp + time);

        // This should not revert
        LibPrice.getDrawPrice();
    }

    /// ===== Modified tests from t11s https://github.com/transmissions11/VRGDAs/blob/master/test/LinearVRGDA.t.sol
    /// =====
    /// When power is set to 1, the VRGDA is linear

    function testLinearTargetPrice() public {
        vm.startPrank(deployerAddress);
        VRGDAConfig.set({
            startTime: block.timestamp,
            targetPrice: 69.42e18,
            priceDecay: 0.31e18,
            perDayInitial: 2e18,
            power: 1e18
        });
        vm.stopPrank();

        // Warp to the target sale time so that the VRGDA price equals the target price.
        int256 targetSaleTime = unsafeWadDiv(1e18, 2e18);
        vm.warp(block.timestamp + fromDaysWadUnsafe(targetSaleTime));

        uint256 cost = LibPrice.getDrawPrice();
        assertRelApproxEq(cost, uint256(69.42e18), 0.00000000001e18);
    }

    function testLinearPricingBasic() public {
        uint256 timeDelta = 120 days;
        uint256 numMint = 239;

        vm.startPrank(deployerAddress);
        VRGDAConfig.set({
            startTime: block.timestamp,
            targetPrice: 69.42e18,
            priceDecay: 0.31e18,
            perDayInitial: 2e18,
            power: 1e18
        });
        DrawCount.set(uint32(numMint));
        vm.stopPrank();

        vm.warp(block.timestamp + timeDelta);

        uint256 cost = LibPrice.getDrawPrice();
        assertRelApproxEq(cost, uint256(VRGDAConfig.getTargetPrice()), 0.00000001e18);
    }

    function testLinearAlwaysTargetPriceInRightConditions(uint32 sold) public {
        sold = uint32(bound(sold, 0, type(uint16).max));
        vm.startPrank(deployerAddress);
        VRGDAConfig.set({
            startTime: block.timestamp,
            targetPrice: 69.42e18,
            priceDecay: 0.31e18,
            perDayInitial: 2e18,
            power: 1e18
        });
        DrawCount.set(sold);
        vm.stopPrank();
        int256 targetSaleTime = unsafeWadDiv(toWadUnsafe(sold + 1), 2e18);
        vm.warp(block.timestamp + fromDaysWadUnsafe(targetSaleTime));
        assertRelApproxEq(LibPrice.getDrawPrice(), uint256(VRGDAConfig.getTargetPrice()), 0.00000001e18);
    }

    /// ===== Copied from solmate's DSTestPlus (https://github.com/transmissions11/solmate/tree/main/src/test/utils)
    /// =====

    function assertRelApproxEq(
        uint256 a,
        uint256 b,
        uint256 maxPercentDelta // An 18 decimal fixed point number, where 1e18 == 100%
    )
        internal
        virtual
    {
        if (b == 0) return assertEq(a, b); // If the expected is 0, actual must be too.

        uint256 percentDelta = ((a > b ? a - b : b - a) * 1e18) / b;

        if (percentDelta > maxPercentDelta) {
            emit log("Error: a ~= b not satisfied [uint]");
            emit log_named_uint("    Expected", b);
            emit log_named_uint("      Actual", a);
            emit log_named_decimal_uint(" Max % Delta", maxPercentDelta, 18);
            emit log_named_decimal_uint("     % Delta", percentDelta, 18);
            fail();
        }
    }
}

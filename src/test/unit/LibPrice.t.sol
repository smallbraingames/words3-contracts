// SPDX-License-Identifier: MIT
// Linear VRGDA tests adapted from https://github.com/transmissions11/VRGDAs/blob/master/test/LinearVRGDA.t.sol
pragma solidity >=0.8.0;

import {IWorld} from "codegen/world/IWorld.sol";
import {Letter, Direction} from "codegen/Types.sol";
import {VRGDAConfig, LetterCount} from "codegen/Tables.sol";

import {NotEnoughValue} from "common/Errors.sol";
import {LibPrice} from "libraries/LibPrice.sol";

import "forge-std/Test.sol";
import {MudTest} from "@latticexyz/store/src/MudTest.sol";
import {
    toWadUnsafe, toDaysWadUnsafe, fromDaysWadUnsafe, unsafeWadDiv, wadPow
} from "solmate/src/utils/SignedWadMath.sol";

contract LibPriceTest is MudTest {
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

    /// ===== Modified tests from t11s https://github.com/transmissions11/VRGDAs/blob/master/test/LinearVRGDA.t.sol =====

    function testTargetPrice() public {
        vm.startPrank(worldAddress);
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

        uint256 cost = LibPrice.getLetterPrice(Letter.A);
        assertRelApproxEq(cost, uint256(69.42e18), 0.00000000001e18);
    }

    function testPricingBasic() public {
        uint256 timeDelta = 120 days;
        uint256 numMint = 239;

        vm.startPrank(worldAddress);
        VRGDAConfig.set({
            startTime: block.timestamp,
            targetPrice: 69.42e18,
            priceDecay: 0.31e18,
            perDayInitial: 2e18,
            power: 1e18
        });
        LetterCount.set(Letter.A, uint32(numMint));
        vm.stopPrank();

        vm.warp(block.timestamp + timeDelta);

        uint256 cost = LibPrice.getLetterPrice(Letter.A);
        assertRelApproxEq(cost, uint256(VRGDAConfig.getTargetPrice()), 0.00000001e18);
    }

    function testAlwaysTargetPriceInRightConditions(uint32 sold) public {
        sold = uint32(bound(sold, 0, type(uint16).max));
        vm.startPrank(worldAddress);
        VRGDAConfig.set({
            startTime: block.timestamp,
            targetPrice: 69.42e18,
            priceDecay: 0.31e18,
            perDayInitial: 2e18,
            power: 1e18
        });
        LetterCount.set(Letter.A, sold);
        vm.stopPrank();
        int256 targetSaleTime = unsafeWadDiv(toWadUnsafe(sold + 1), 2e18);
        vm.warp(block.timestamp + fromDaysWadUnsafe(targetSaleTime));
        assertRelApproxEq(LibPrice.getLetterPrice(Letter.A), uint256(VRGDAConfig.getTargetPrice()), 0.00000001e18);
    }

    /// ===== Copied from solmate's DSTestPlus (https://github.com/transmissions11/solmate/tree/main/src/test/utils) =====

    function assertRelApproxEq(
        uint256 a,
        uint256 b,
        uint256 maxPercentDelta // An 18 decimal fixed point number, where 1e18 == 100%
    ) internal virtual {
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

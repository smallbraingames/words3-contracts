// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;
/* solhint-disable no-global-import */
/* solhint-disable func-name-mixedcase */

import { Words3Test } from "../Words3Test.t.sol";
import { Points, Treasury } from "codegen/index.sol";
import "forge-std/Test.sol";
import { LibTreasury } from "libraries/LibTreasury.sol";

contract LibTreasuryTest is Words3Test {
    function test_GetFeeAmount() public {
        assertEq(LibTreasury.getFeeAmount({ value: 100, feeBps: 1000 }), 10);
        assertEq(LibTreasury.getFeeAmount({ value: 100, feeBps: 500 }), 5);
        assertEq(LibTreasury.getFeeAmount({ value: 100, feeBps: 0 }), 0);
        assertEq(LibTreasury.getFeeAmount({ value: 100, feeBps: 10_000 }), 100);
        assertEq(LibTreasury.getFeeAmount({ value: 100, feeBps: 9999 }), 99);
        assertEq(LibTreasury.getFeeAmount({ value: 100 ether, feeBps: 9999 }), 99.99 ether);
        assertEq(LibTreasury.getFeeAmount({ value: 1e6 ether, feeBps: 9999 }), 0.9999e6 ether);
        assertEq(LibTreasury.getFeeAmount({ value: 1e6 ether, feeBps: 690 }), 0.069e6 ether);
    }

    function testFuzz_GetFeeAmount(uint256 value, uint16 feeBps) public {
        value = bound(value, 0, uint256(type(uint128).max));
        feeBps = uint16(bound(feeBps, 0, 10_000));
        uint256 expected = (value * feeBps) / 10_000;
        assertEq(LibTreasury.getFeeAmount({ value: value, feeBps: feeBps }), expected);
    }

    function testFuzz_GetClaimAmountNeverAboveTreasury(uint32 points, uint256 treasury, uint32 totalPoints) public {
        treasury = bound(treasury, 0, uint256(type(uint128).max));
        totalPoints = uint32(bound(totalPoints, 1, type(uint32).max));
        points = uint32(bound(points, 1, totalPoints));
        uint256 expected = (treasury * points) / totalPoints;
        vm.startPrank(deployerAddress);
        Treasury.set({ value: treasury });
        Points.setValue({ player: address(0), value: totalPoints });
        vm.stopPrank();
        assertEq(LibTreasury.getClaimAmount(points), expected);
        assertTrue(expected <= treasury);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Words3Test } from "../Words3Test.t.sol";
import { GameConfig, Spent } from "codegen/index.sol";
import "forge-std/Test.sol";

import { LibTreasury } from "libraries/LibTreasury.sol";

contract LibTreasuryTest is Words3Test {
    function testGetFeeAmount() public {
        assertEq(LibTreasury.getFeeAmount(100, 10), 0);
        assertEq(LibTreasury.getFeeAmount(1000, 20), 2);
        assertEq(LibTreasury.getFeeAmount(1000, 30), 3);
        assertEq(LibTreasury.getFeeAmount(1000, 40), 4);
        assertEq(LibTreasury.getFeeAmount(1000, 50), 5);
        assertEq(LibTreasury.getFeeAmount(1000, 60), 6);
        assertEq(LibTreasury.getFeeAmount(1000, 70), 7);
        assertEq(LibTreasury.getFeeAmount(1000, 80), 8);
        assertEq(LibTreasury.getFeeAmount(1000, 90), 9);
        assertEq(LibTreasury.getFeeAmount(1000, 100), 10);
        assertEq(LibTreasury.getFeeAmount(1_558_823_529_411_764_705, 500), 77_941_176_470_588_235);
    }

    function testGetFeeAmountZeroFeeBps() public {
        assertEq(LibTreasury.getFeeAmount(100, 0), 0);
    }

    function testFuzzGetFeeAmountZeroFeeBps(uint256 amount) public {
        assertEq(LibTreasury.getFeeAmount(amount, 0), 0);
    }

    function testGetFeeAmountZeroMsgValue() public {
        assertEq(LibTreasury.getFeeAmount(0, 10), 0);
    }

    function testFuzzGetFeeAmount(uint256 msgValue, uint16 feeBps) public {
        msgValue = bound(msgValue, 0, 1000);
        feeBps = uint16(bound(feeBps, 0, 10_000));
        uint256 feeAmount = LibTreasury.getFeeAmount(msgValue, feeBps);
        assertTrue(feeAmount <= msgValue);
    }

    function testIncrementSpent() public {
        address spender = address(1);
        vm.startPrank(deployerAddress);
        LibTreasury.incrementSpent(spender, 100);
        assertEq(Spent.get(spender), 100);
        LibTreasury.incrementSpent(spender, 100);
        assertEq(Spent.get(spender), 200);
        vm.stopPrank();
    }

    function testCanSpend() public {
        address spender = address(1);
        vm.startPrank(deployerAddress);
        GameConfig.setMaxPlayerSpend(1000);
        assertTrue(LibTreasury.canSpend(spender, 100));
        LibTreasury.incrementSpent(spender, 100);
        assertTrue(LibTreasury.canSpend(spender, 100));
        LibTreasury.incrementSpent(spender, 100);
        assertTrue(LibTreasury.canSpend(spender, 100));
        LibTreasury.incrementSpent(spender, 100);
        assertTrue(LibTreasury.canSpend(spender, 100));
        LibTreasury.incrementSpent(spender, 100);
        assertTrue(LibTreasury.canSpend(spender, 100));
        LibTreasury.incrementSpent(spender, 100);
        assertTrue(LibTreasury.canSpend(spender, 400));
        assertTrue(LibTreasury.canSpend(spender, 500));
        assertTrue(!LibTreasury.canSpend(spender, 600));
        assertTrue(!LibTreasury.canSpend(spender, 700));
        assertTrue(!LibTreasury.canSpend(spender, 800));
        vm.stopPrank();
    }

    function testNoSpendCapIfZero() public {
        address spender = address(1);
        vm.startPrank(deployerAddress);
        GameConfig.setMaxPlayerSpend(0);
        assertTrue(LibTreasury.canSpend(spender, 100));
        LibTreasury.incrementSpent(spender, 100);
        assertTrue(LibTreasury.canSpend(spender, 100));
        LibTreasury.incrementSpent(spender, 100);
        assertTrue(LibTreasury.canSpend(spender, 100));
        LibTreasury.incrementSpent(spender, 100);
        assertTrue(LibTreasury.canSpend(spender, 100));
        LibTreasury.incrementSpent(spender, 100);
        assertTrue(LibTreasury.canSpend(spender, 100));
        LibTreasury.incrementSpent(spender, 100);
        assertTrue(LibTreasury.canSpend(spender, 100));
        assertTrue(LibTreasury.canSpend(spender, 1000));
        assertTrue(LibTreasury.canSpend(spender, 100_000));
        assertTrue(LibTreasury.canSpend(spender, 10_000_000));
        vm.stopPrank();
    }

    function testFuzzCanSpend(address spender, uint256 msgValue, uint256 maxPlayerSpend) public {
        maxPlayerSpend = bound(maxPlayerSpend, 0, 1000e18);
        vm.assume(maxPlayerSpend > 2);
        msgValue = bound(msgValue, 0, maxPlayerSpend - 1);
        vm.startPrank(deployerAddress);
        GameConfig.setMaxPlayerSpend(maxPlayerSpend);
        assertTrue(LibTreasury.canSpend(spender, msgValue));
        assertTrue(!LibTreasury.canSpend(spender, msgValue + maxPlayerSpend + 1));
        vm.stopPrank();
    }
}

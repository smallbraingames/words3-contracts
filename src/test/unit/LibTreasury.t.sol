// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Words3Test } from "../Words3Test.t.sol";
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
}

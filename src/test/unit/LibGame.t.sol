// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IWorld} from "codegen/world/IWorld.sol";
import {GameConfig, MerkleRootConfig, VRGDAConfig} from "codegen/Tables.sol";
import {Status} from "codegen/Types.sol";

import {LibGame} from "libraries/LibGame.sol";

import "forge-std/Test.sol";
import {MudTest} from "@latticexyz/store/src/MudTest.sol";

contract LibGameTest is MudTest {
    IWorld world;

    function setUp() public override {
        super.setUp();
        world = IWorld(worldAddress);
    }

    function testCanPlay() public {
        assertFalse(LibGame.canPlay());
        vm.startPrank(worldAddress);
        GameConfig.setEndTime(block.timestamp + 100);
        GameConfig.setStatus(Status.STARTED);
        vm.stopPrank();
        assertTrue(LibGame.canPlay());
        vm.warp(block.timestamp + 100);
        assertFalse(LibGame.canPlay());
    }

    function testCanPlayAfterGameStart() public {
        vm.startPrank(worldAddress);
        LibGame.startGame(block.timestamp + 100, bytes32(0), 0, 0, 0, 3);
        vm.stopPrank();
        assertTrue(LibGame.canPlay());
        vm.warp(block.timestamp + 100);
        assertFalse(LibGame.canPlay());
    }

    function testFuzzCanPlay(uint256 endTime) public {
        vm.assume(endTime > block.timestamp);
        vm.startPrank(worldAddress);
        LibGame.startGame(endTime, bytes32(0), 0, 0, 0, 3);
        vm.stopPrank();
        assertTrue(LibGame.canPlay());
        vm.warp(endTime);
        assertFalse(LibGame.canPlay());
    }

    function testFuzzCanPlayFalseIfPastTime(uint256 endTime, uint256 callTime) public {
        vm.assume(endTime > block.timestamp);
        vm.assume(callTime > endTime);
        vm.startPrank(worldAddress);
        LibGame.startGame(endTime, bytes32(0), 0, 0, 0, 3);
        vm.stopPrank();
        vm.warp(callTime);
        assertFalse(LibGame.canPlay());
    }

    function testFuzzCanPlayFalseIfNotStarted(uint256 time, uint256 endTime, uint8 statusRaw) public {
        statusRaw = uint8(bound(statusRaw, 0, 2));
        Status status = Status(statusRaw);
        vm.assume(status != Status.STARTED);
        vm.startPrank(worldAddress);
        GameConfig.setEndTime(endTime);
        GameConfig.setStatus(status);
        vm.stopPrank();
        vm.warp(time);
        assertFalse(LibGame.canPlay());
    }

    function testFuzzStartGame(
        uint256 endTime,
        bytes32 merkleRoot,
        int256 vrgdaTargetPrice,
        int256 vrgdaPriceDecay,
        int256 vrgdaPerDay,
        uint32 crossWordRewardFraction
    ) public {
        vm.assume(endTime > block.timestamp);
        vm.startPrank(worldAddress);
        LibGame.startGame(endTime, merkleRoot, vrgdaTargetPrice, vrgdaPriceDecay, vrgdaPerDay, crossWordRewardFraction);
        vm.stopPrank();
        assertEq(endTime, GameConfig.getEndTime());
        assertEq(merkleRoot, MerkleRootConfig.get());
        assertEq(vrgdaTargetPrice, VRGDAConfig.getTargetPrice());
        assertEq(vrgdaPriceDecay, VRGDAConfig.getPriceDecay());
        assertEq(vrgdaPerDay, VRGDAConfig.getPerDay());
        assertEq(crossWordRewardFraction, GameConfig.getCrossWordRewardFraction());
    }
}

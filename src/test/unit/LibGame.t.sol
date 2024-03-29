// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Status } from "codegen/common.sol";
import { GameConfig, HostConfig, HostConfigData, MerkleRootConfig, VRGDAConfig } from "codegen/index.sol";
import { IWorld } from "codegen/world/IWorld.sol";

import { LibGame } from "libraries/LibGame.sol";

import { Words3Test } from "../Words3Test.t.sol";
import "forge-std/Test.sol";

contract LibGameTest is Words3Test {
    IWorld world;

    function setUp() public override {
        super.setUp();
        world = IWorld(worldAddress);
    }

    function testCanPlay() public {
        assertFalse(LibGame.canPlay());
        vm.startPrank(deployerAddress);
        GameConfig.setEndTime(block.timestamp + 100);
        GameConfig.setStatus(Status.STARTED);
        vm.stopPrank();
        assertTrue(LibGame.canPlay());
        vm.warp(block.timestamp + 100);
        assertFalse(LibGame.canPlay());
    }

    function testCanPlayAfterGameStart() public {
        vm.startPrank(deployerAddress);
        LibGame.startGame(
            block.timestamp + 100, 0, bytes32(0), 0, 0, 0, 0, HostConfigData({ host: address(0), hostFeeBps: 0 }), 3, 5
        );
        vm.stopPrank();
        assertTrue(LibGame.canPlay());
        vm.warp(block.timestamp + 100);
        assertFalse(LibGame.canPlay());
    }

    function testFuzzCanPlay(uint256 endTime) public {
        vm.assume(endTime > block.timestamp);
        vm.startPrank(deployerAddress);
        LibGame.startGame(endTime, 0, bytes32(0), 0, 0, 0, 0, HostConfigData({ host: address(0), hostFeeBps: 0 }), 3, 8);
        vm.stopPrank();
        assertTrue(LibGame.canPlay());
        vm.warp(endTime);
        assertFalse(LibGame.canPlay());
    }

    function testFuzzCanPlayFalseIfPastTime(uint256 endTime, uint256 callTime) public {
        vm.assume(endTime > block.timestamp);
        vm.assume(callTime > endTime);
        vm.startPrank(deployerAddress);
        LibGame.startGame(
            endTime, 0, bytes32(0), 0, 0, 0, 0, HostConfigData({ host: address(0), hostFeeBps: 0 }), 3, 12
        );
        vm.stopPrank();
        vm.warp(callTime);
        assertFalse(LibGame.canPlay());
    }

    function testFuzzCanPlayFalseIfNotStarted(uint256 time, uint256 endTime, uint8 statusRaw) public {
        statusRaw = uint8(bound(statusRaw, 0, 2));
        Status status = Status(statusRaw);
        vm.assume(status != Status.STARTED);
        vm.startPrank(deployerAddress);
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
        int256 vrgdaPerDayInitial,
        int256 vrgdaPower,
        uint32 crossWordRewardFraction,
        address host,
        uint16 hostFeeBps,
        uint256 maxPlayerSpend
    )
        public
    {
        hostFeeBps = uint16(bound(hostFeeBps, 0, 10_000));
        vm.assume(endTime > block.timestamp);
        vm.startPrank(deployerAddress);
        LibGame.startGame(
            endTime,
            maxPlayerSpend,
            merkleRoot,
            vrgdaTargetPrice,
            vrgdaPriceDecay,
            vrgdaPerDayInitial,
            vrgdaPower,
            HostConfigData({ host: host, hostFeeBps: hostFeeBps }),
            crossWordRewardFraction,
            12
        );
        vm.stopPrank();
        assertEq(endTime, GameConfig.getEndTime());
        assertEq(merkleRoot, MerkleRootConfig.get());
        assertEq(vrgdaTargetPrice, VRGDAConfig.getTargetPrice());
        assertEq(vrgdaPriceDecay, VRGDAConfig.getPriceDecay());
        assertEq(vrgdaPerDayInitial, VRGDAConfig.getPerDayInitial());
        assertEq(vrgdaPower, VRGDAConfig.getPower());
        assertEq(crossWordRewardFraction, GameConfig.getCrossWordRewardFraction());
        assertEq(host, HostConfig.getHost());
        assertEq(hostFeeBps, HostConfig.getHostFeeBps());
        assertEq(maxPlayerSpend, GameConfig.getMaxPlayerSpend());
    }
}

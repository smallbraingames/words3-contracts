// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Direction, Letter } from "codegen/common.sol";
import { PlayerLetters } from "codegen/index.sol";
import { IWorld } from "codegen/world/IWorld.sol";

import { Bound } from "common/Bound.sol";
import { Coord } from "common/Coord.sol";
import { GameStartedOrOver } from "common/Errors.sol";

import { Words3Test } from "../Words3Test.t.sol";
import { Merkle } from "../murky/src/Merkle.sol";
import "forge-std/Test.sol";

contract Transfer is Words3Test {
    IWorld world;

    function setUp() public override {
        super.setUp();
        world = IWorld(worldAddress);
        setDefaultLetterOdds();
    }

    function test_Transfer() public {
        Letter[] memory initialWord = new Letter[](2);
        initialWord[0] = Letter.H;
        initialWord[1] = Letter.I;
        world.words3__start({
            initialWord: initialWord,
            merkleRoot: bytes32(0),
            vrgdaTargetPrice: 1,
            vrgdaPriceDecay: 1e17,
            vrgdaPerDayInitial: 100e18,
            vrgdaPower: 1e16,
            crossWordRewardFraction: 3,
            bonusDistance: 5
        });

        address player = address(0x123);
        address to = address(0x456);
        vm.deal(player, 50 ether);
        vm.startPrank(player);
        for (uint256 i = 0; i < 50; i++) {
            uint256 price = world.words3__getDrawPrice();
            vm.warp(block.timestamp + 1 days);
            world.words3__draw{ value: price }(player);
        }
        assertEq(PlayerLetters.get({ player: to, letter: Letter.A }), 0);
        Letter[] memory transferLetters = new Letter[](2);
        transferLetters[0] = Letter.A;
        transferLetters[1] = Letter.B;
        world.words3__transfer({ letters: transferLetters, to: to });
        assertEq(PlayerLetters.get({ player: to, letter: Letter.A }), 1);
        assertEq(PlayerLetters.get({ player: to, letter: Letter.B }), 1);
        vm.stopPrank();
    }
}

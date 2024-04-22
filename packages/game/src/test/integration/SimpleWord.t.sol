// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Direction, Letter } from "codegen/common.sol";
import { MerkleRootConfig, TileLetter, TilePlayer } from "codegen/index.sol";
import { IWorld } from "codegen/world/IWorld.sol";

import { Bound } from "common/Bound.sol";
import { Coord } from "common/Coord.sol";
import { GameStartedOrOver } from "common/Errors.sol";

import { Words3Test } from "../Words3Test.t.sol";
import { Merkle } from "../murky/src/Merkle.sol";
import "forge-std/Test.sol";

contract SimpleWord is Words3Test {
    IWorld world;
    bytes32[] public words;
    Merkle private m;
    Letter[] initialWord;

    function setUp() public override {
        super.setUp();
        world = IWorld(worldAddress);

        m = new Merkle();
        Letter[] memory hi = new Letter[](2);
        hi[0] = Letter.H;
        hi[1] = Letter.I;
        Letter[] memory go = new Letter[](2);
        go[0] = Letter.G;
        go[1] = Letter.O;
        words.push(keccak256(bytes.concat(keccak256(abi.encode(hi))))); // hi
        words.push(keccak256(bytes.concat(keccak256(abi.encode(go))))); // go

        setDefaultLetterOdds();
    }

    function test_Setup() public {
        initialWord = new Letter[](2);
        initialWord[0] = Letter.H;
        initialWord[1] = Letter.I;
        world.start(initialWord, m.getRoot(words), 0, 0, 0, 1e16, 3, 5);
        assertEq(uint8(TileLetter.get(0, 0)), uint8(Letter.H));
        assertEq(uint8(TileLetter.get(1, 0)), uint8(Letter.I));
    }

    function test_PlayHi() public {
        initialWord = new Letter[](2);
        initialWord[0] = Letter.H;
        initialWord[1] = Letter.I;
        world.start({
            initialWord: initialWord,
            merkleRoot: m.getRoot(words),
            vrgdaTargetPrice: 1,
            vrgdaPriceDecay: 1e17,
            vrgdaPerDayInitial: 100e18,
            vrgdaPower: 1e16,
            crossWordRewardFraction: 3,
            bonusDistance: 5
        });

        Letter[] memory word = new Letter[](2);
        word[0] = Letter.EMPTY;
        word[1] = Letter.I;
        Bound[] memory bounds = new Bound[](2);
        bytes32[] memory proof = m.getProof(words, 0);

        address player = address(0x123);
        vm.deal(player, 50 ether);
        vm.startPrank(player);
        for (uint256 i = 0; i < 50; i++) {
            uint256 price = world.getDrawPrice();
            vm.warp(block.timestamp + 1 days);
            world.draw{ value: price }(player);
        }
        world.play(word, proof, Coord({ x: 0, y: 0 }), Direction.TOP_TO_BOTTOM, bounds);
        vm.stopPrank();
    }

    function test_MultipleDraws() public {
        world.start({
            initialWord: initialWord,
            merkleRoot: 0xacd24e8edae5cf4cdbc3ce0c196a670cbea1dbf37576112b0a3defac3318b432,
            vrgdaTargetPrice: 40e13,
            vrgdaPriceDecay: 99_999e13,
            vrgdaPerDayInitial: 700e18,
            vrgdaPower: 1e18,
            crossWordRewardFraction: 3,
            bonusDistance: 10
        });

        address player = address(0x123);
        vm.deal(player, 50 ether);
        vm.startPrank(player);

        world.draw{ value: world.getDrawPrice() }(player);
        world.draw{ value: world.getDrawPrice() }(player);
        vm.warp(block.timestamp + 5);
        world.draw{ value: world.getDrawPrice() }(player);
        vm.warp(block.timestamp + 10);
        world.draw{ value: world.getDrawPrice() }(player);
        world.draw{ value: world.getDrawPrice() }(player);
        world.draw{ value: world.getDrawPrice() }(player);
        vm.warp(block.timestamp + 10);
        world.draw{ value: world.getDrawPrice() }(player);
        world.draw{ value: world.getDrawPrice() }(player);
        world.draw{ value: world.getDrawPrice() }(player);
        world.draw{ value: world.getDrawPrice() }(player);
        world.draw{ value: world.getDrawPrice() }(player);
        vm.warp(block.timestamp + 3);
        world.draw{ value: world.getDrawPrice() }(player);
        world.draw{ value: world.getDrawPrice() }(player);
    }
}

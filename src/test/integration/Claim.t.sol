// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IWorld} from "codegen/world/IWorld.sol";
import {Letter, Direction} from "codegen/Types.sol";
import {MerkleRootConfig, TileLetter, TilePlayer, Points, Treasury} from "codegen/Tables.sol";

import {Coord} from "common/Coord.sol";
import {Bound} from "common/Bound.sol";
import {SINGLETON_ADDRESS} from "common/Constants.sol";
import {GameStartedOrOver} from "common/Errors.sol";

import "forge-std/Test.sol";
import {MudTest} from "@latticexyz/store/src/MudTest.sol";
import {getKeysWithValue} from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import {Merkle} from "../murky/src/Merkle.sol";

contract Claim is MudTest {
    IWorld world;
    bytes32[] public words;
    Merkle private m;

    function setUp() public override {
        super.setUp();
        world = IWorld(worldAddress);
        m = new Merkle();
        Letter[] memory hello = new Letter[](5);
        hello[0] = Letter.H;
        hello[1] = Letter.E;
        hello[1] = Letter.L;
        hello[1] = Letter.L;
        hello[1] = Letter.O;
        Letter[] memory zone = new Letter[](4);
        zone[0] = Letter.Z;
        zone[1] = Letter.O;
        zone[2] = Letter.N;
        zone[3] = Letter.E;
        words.push(keccak256(bytes.concat(keccak256(abi.encode(hello))))); // hello
        words.push(keccak256(bytes.concat(keccak256(abi.encode(zone))))); // zone
    }

    function testSimpleClaim() public {
        address player1 = address(0x12345);

        Letter[] memory initialWord = new Letter[](5);
        initialWord[0] = Letter.H;
        initialWord[1] = Letter.E;
        initialWord[2] = Letter.L;
        initialWord[3] = Letter.L;
        initialWord[4] = Letter.O;

        world.start(initialWord, block.timestamp + 1e6, m.getRoot(words), 1 ether, 1e15, 1e15, 3);

        Letter[] memory word = new Letter[](4);
        word[0] = Letter.Z;
        word[1] = Letter.EMPTY;
        word[2] = Letter.N;
        word[3] = Letter.E;

        uint256 wordPrice = world.getWordPrice(word);
        vm.deal(player1, wordPrice * 2);

        Bound[] memory bounds = new Bound[](4);
        bytes32[] memory proof = m.getProof(words, 1);

        // Play zone
        vm.prank(player1);
        world.play{value: wordPrice}(word, proof, Coord({x: 4, y: -1}), Direction.TOP_TO_BOTTOM, bounds);
        assertEq(address(player1).balance, wordPrice);
        assertEq(address(worldAddress).balance, wordPrice);

        vm.warp(block.timestamp + 1e6 + 1);
        world.end();
        world.claim(player1);
        assertEq(address(player1).balance, wordPrice * 2);
        assertEq(address(worldAddress).balance, 0);
    }

    function testFuzzDuplicateClaim(address winner, address attacker) public {
        vm.assume(uint160(winner) > 100 && uint160(attacker) > 100);
        vm.assume(winner != attacker);
        vm.assume(winner != address(0) && attacker != address(0));
        vm.assume(winner != worldAddress && attacker != worldAddress);
        uint256 winnerPrev = address(winner).balance;
        uint256 attackerPrev = address(attacker).balance;
        Letter[] memory initialWord = new Letter[](5);
        initialWord[0] = Letter.H;
        initialWord[1] = Letter.E;
        initialWord[2] = Letter.L;
        initialWord[3] = Letter.L;
        initialWord[4] = Letter.O;
        world.start(initialWord, block.timestamp + 1e6, m.getRoot(words), 1 ether, 1e15, 1e15, 3);
        payable(worldAddress).transfer(2 ether);
        vm.startPrank(worldAddress);
        Treasury.set(1 ether);
        Points.set(winner, 10);
        Points.set(SINGLETON_ADDRESS, 10);
        vm.stopPrank();
        vm.warp(block.timestamp + 1e6 + 1);
        vm.expectRevert();
        world.claim(winner);
        vm.expectRevert();
        world.claim(attacker);
        world.end();
        vm.expectRevert();
        world.claim(attacker);
        world.claim(winner);
        assertEq(address(worldAddress).balance, 1 ether);
        assertEq(address(winner).balance, winnerPrev + 1 ether);
        assertEq(address(attacker).balance, attackerPrev);
        vm.expectRevert();
        world.claim(winner);
        vm.expectRevert();
        world.claim(attacker);
    }
}

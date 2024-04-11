// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Direction, Letter } from "codegen/common.sol";
import { MerkleRootConfig, Points, TileLetter, TilePlayer, Treasury } from "codegen/index.sol";
import { IWorld } from "codegen/world/IWorld.sol";

import { Bound } from "common/Bound.sol";
import { SINGLETON_ADDRESS } from "common/Constants.sol";
import { Coord } from "common/Coord.sol";

import { Words3Test } from "../Words3Test.t.sol";
import { Merkle } from "../murky/src/Merkle.sol";
import "forge-std/Test.sol";

contract Claim is Words3Test {
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
        Letter[] memory echo = new Letter[](4);
        echo[0] = Letter.E;
        echo[1] = Letter.C;
        echo[2] = Letter.H;
        echo[3] = Letter.O;
        Letter[] memory zebra = new Letter[](5);
        zebra[0] = Letter.Z;
        zebra[1] = Letter.E;
        zebra[2] = Letter.B;
        zebra[3] = Letter.R;
        zebra[4] = Letter.A;
        Letter[] memory riot = new Letter[](5);
        riot[0] = Letter.R;
        riot[1] = Letter.I;
        riot[2] = Letter.O;
        riot[3] = Letter.T;
        Letter[] memory emi = new Letter[](3);
        emi[0] = Letter.E;
        emi[1] = Letter.M;
        emi[2] = Letter.I;
        Letter[] memory om = new Letter[](2);
        om[0] = Letter.O;
        om[1] = Letter.M;
        Letter[] memory omq = new Letter[](3);
        omq[0] = Letter.O;
        omq[1] = Letter.M;
        omq[2] = Letter.Q;
        Letter[] memory bqt = new Letter[](3);
        bqt[0] = Letter.B;
        bqt[1] = Letter.Q;
        bqt[2] = Letter.T;
        words.push(keccak256(bytes.concat(keccak256(abi.encode(hello))))); // hello
        words.push(keccak256(bytes.concat(keccak256(abi.encode(zone))))); // zone
        words.push(keccak256(bytes.concat(keccak256(abi.encode(echo))))); // echo
        words.push(keccak256(bytes.concat(keccak256(abi.encode(zebra))))); // zebra
        words.push(keccak256(bytes.concat(keccak256(abi.encode(riot))))); // riot
        words.push(keccak256(bytes.concat(keccak256(abi.encode(emi))))); // emi
        words.push(keccak256(bytes.concat(keccak256(abi.encode(om))))); // om
        words.push(keccak256(bytes.concat(keccak256(abi.encode(omq))))); // omq
        words.push(keccak256(bytes.concat(keccak256(abi.encode(bqt))))); // qt

        setDefaultLetterOdds();
    }

    function test_SimpleClaim() public {
        address player1 = address(0x12345);
        address player2 = address(0x54321);

        Letter[] memory initialWord = new Letter[](5);
        initialWord[0] = Letter.H;
        initialWord[1] = Letter.E;
        initialWord[2] = Letter.L;
        initialWord[3] = Letter.L;
        initialWord[4] = Letter.O;

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

        Letter[] memory word = new Letter[](4);
        word[0] = Letter.Z;
        word[1] = Letter.EMPTY;
        word[2] = Letter.N;
        word[3] = Letter.E;

        vm.deal(player1, 10 ether);

        Bound[] memory bounds = new Bound[](4);
        bytes32[] memory proof = m.getProof(words, 1);

        // Play zone
        vm.startPrank(player1);
        for (uint256 i = 0; i < 20; i++) {
            vm.warp(block.timestamp + 1 days);
            world.draw{ value: 0.5 ether }(player1);
        }
        world.play(word, proof, Coord({ x: 4, y: -1 }), Direction.TOP_TO_BOTTOM, bounds);
        vm.stopPrank();
        assertEq(address(player1).balance, 0);
        assertEq(address(worldAddress).balance, 10 ether);

        // Play zebra on zone
        vm.deal(player2, 10 ether);
        Letter[] memory word2 = new Letter[](5);
        word2[0] = Letter.EMPTY;
        word2[1] = Letter.E;
        word2[2] = Letter.B;
        word2[3] = Letter.R;
        word2[4] = Letter.A;

        bytes32[] memory proof2 = m.getProof(words, 3);
        Bound[] memory bounds2 = new Bound[](5);
        vm.startPrank(player2);
        for (uint256 i = 0; i < 20; i++) {
            vm.warp(block.timestamp + 1 days);
            world.draw{ value: 0.5 ether }(player2);
        }
        world.play(word2, proof2, Coord({ x: 4, y: -1 }), Direction.LEFT_TO_RIGHT, bounds2);
        vm.stopPrank();
        uint32 player1Points = Points.get(player1);
        uint32 player2Points = Points.get(player2);

        assertEq(Treasury.get(), 20 ether);

        vm.prank(player1);
        world.claim(player1Points);

        vm.prank(player2);
        world.claim(player2Points);

        uint256 player1ExpectedBalance = (20 ether * player1Points) / (player1Points + player2Points);

        assertEq(address(player1).balance, player1ExpectedBalance);
        assertEq(address(player2).balance, 20 ether - player1ExpectedBalance);
    }
}

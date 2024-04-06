// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Direction, Letter } from "codegen/common.sol";
import { MerkleRootConfig, Points, TileLetter, TilePlayer, Treasury } from "codegen/index.sol";
import { IWorld } from "codegen/world/IWorld.sol";

import { Bound } from "common/Bound.sol";
import { SINGLETON_ADDRESS } from "common/Constants.sol";
import { Coord } from "common/Coord.sol";
import { SpendCap } from "common/Errors.sol";

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
    }

    function testSimpleClaim() public {
        address player1 = address(0x12345);

        Letter[] memory initialWord = new Letter[](5);
        initialWord[0] = Letter.H;
        initialWord[1] = Letter.E;
        initialWord[2] = Letter.L;
        initialWord[3] = Letter.L;
        initialWord[4] = Letter.O;

        world.start(initialWord, block.timestamp + 1e6, 0, m.getRoot(words), 0, 1e17, 3e18, 1e16, 3, 5);

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
        world.play{ value: wordPrice }(word, proof, Coord({ x: 4, y: -1 }), Direction.TOP_TO_BOTTOM, bounds);
        assertEq(address(player1).balance, wordPrice);
        assertEq(address(worldAddress).balance, wordPrice);

        vm.warp(block.timestamp + 1e6 + 1);
        world.end();
        world.claim(player1);
        assertEq(address(player1).balance, wordPrice * 2);
        assertEq(address(worldAddress).balance, 0);
    }

    function testFuzzDuplicateClaim(uint64 winnerRaw, uint64 attackerRaw) public {
        address winner = address(uint160(winnerRaw));
        address attacker = address(uint160(attackerRaw));
        vm.assume(
            winner != 0xCe71065D4017F316EC606Fe4422e11eB2c47c246 && winner != 0x4e59b44847b379578588920cA78FbF26c0B4956C
                && winner != 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84
                && winner != 0x185a4dc360CE69bDCceE33b3784B0282f7961aea
                && winner != 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D && winner != address(0x9)
        );

        vm.assume(
            attacker != 0xCe71065D4017F316EC606Fe4422e11eB2c47c246
                && attacker != 0x4e59b44847b379578588920cA78FbF26c0B4956C
                && attacker != 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84
                && attacker != 0x185a4dc360CE69bDCceE33b3784B0282f7961aea
                && attacker != 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D && attacker != address(0x9)
        );

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
        world.start(initialWord, block.timestamp + 1e6, 0, m.getRoot(words), 0, 1e17, 3e18, 1e16, 3, 5);
        vm.deal(worldAddress, 2 ether);
        vm.startPrank(deployerAddress);
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

    function testClaim() public {
        address player3 = address(0x11111);
        address player4 = address(0x22222);

        Letter[] memory initialWord = new Letter[](8);
        initialWord[0] = Letter.I;
        initialWord[1] = Letter.N;
        initialWord[2] = Letter.F;
        initialWord[3] = Letter.I;
        initialWord[4] = Letter.N;
        initialWord[5] = Letter.I;
        initialWord[6] = Letter.T;
        initialWord[7] = Letter.E;
        world.start(
            initialWord, block.timestamp + 1e6, 3 ether, m.getRoot(words), 0.0000001 ether, 1e17, 3e18, 1e16, 3, 5
        );
        Letter[] memory word = new Letter[](4);
        word[0] = Letter.Z;
        word[1] = Letter.O;
        word[2] = Letter.EMPTY;
        word[3] = Letter.E;
        Bound[] memory bounds = new Bound[](4);
        bytes32[] memory proof = m.getProof(words, 1);
        vm.deal(address(0xcafe), 6 ether);
        vm.startPrank(address(0xcafe));
        vm.expectRevert(SpendCap.selector);
        world.play{ value: 4 ether }(word, proof, Coord({ x: 4, y: -2 }), Direction.TOP_TO_BOTTOM, bounds);
        world.play{ value: 1 ether }(word, proof, Coord({ x: 4, y: -2 }), Direction.TOP_TO_BOTTOM, bounds);
        vm.stopPrank();
        assertEq(Points.get(address(0xcafe)), 13);

        // Play zebra on zone
        Letter[] memory word2 = new Letter[](5);
        word2[0] = Letter.EMPTY;
        word2[1] = Letter.E;
        word2[2] = Letter.B;
        word2[3] = Letter.R;
        word2[4] = Letter.A;

        bytes32[] memory proof2 = m.getProof(words, 3);
        Bound[] memory bounds2 = new Bound[](5);
        vm.deal(address(0xface), 2 ether);
        vm.startPrank(address(0xcafe));
        vm.expectRevert(SpendCap.selector);
        world.play{ value: 2.1 ether }(word2, proof2, Coord({ x: 4, y: -2 }), Direction.LEFT_TO_RIGHT, bounds2);
        vm.stopPrank();
        vm.prank(address(0xface));
        world.play{ value: 1 ether }(word2, proof2, Coord({ x: 4, y: -2 }), Direction.LEFT_TO_RIGHT, bounds2);
        assertEq(Points.get(address(0xcafe)), 18);
        assertEq(Points.get(address(0xface)), 17);

        // Play emi on both words
        Letter[] memory word3 = new Letter[](3);
        word3[0] = Letter.EMPTY;
        word3[1] = Letter.M;
        word3[2] = Letter.EMPTY;

        bytes32[] memory proof3 = m.getProof(words, 5);
        Bound[] memory bounds3 = new Bound[](3);
        bounds3[1] = Bound({ positive: 0, negative: 1, proof: m.getProof(words, 6) });

        vm.deal(player3, 2 ether);
        vm.prank(player3);
        world.play{ value: 1 ether }(word3, proof3, Coord({ x: 5, y: -2 }), Direction.TOP_TO_BOTTOM, bounds3);
        assertEq(Points.get(address(0xcafe)), 19);
        assertEq(Points.get(address(0xface)), 18);
        assertEq(Points.get(player3), 9);

        // Play omq, qt
        word3 = new Letter[](3);
        word3[0] = Letter.EMPTY;
        word3[1] = Letter.EMPTY;
        word3[2] = Letter.Q;

        bytes32[] memory proof4 = m.getProof(words, 7);
        Bound[] memory bounds4 = new Bound[](3);
        bounds4[2] = Bound({ positive: 1, negative: 1, proof: m.getProof(words, 8) });

        vm.deal(player4, 2 ether);
        vm.prank(player4);
        world.play{ value: 1 ether }(word3, proof4, Coord({ x: 4, y: -1 }), Direction.LEFT_TO_RIGHT, bounds4);
        assertEq(Points.get(address(0xcafe)), 19);
        assertEq(Points.get(address(0xface)), 29);
        assertEq(Points.get(player3), 20);
        assertEq(Points.get(player4), 68);
        assertEq(Points.get(SINGLETON_ADDRESS), 136);
        vm.warp(block.timestamp + 1e6 + 1);
        vm.expectRevert();
        world.claim(player4);
        world.end();

        world.claim(address(0xcafe));
        assertEq(address(0xcafe).balance, 5 ether + 558_823_529_411_764_705);

        world.claim(address(0xface));
        assertEq(address(0xface).balance, 1 ether + 852_941_176_470_588_235);

        world.claim(address(player3));
        assertEq(address(player3).balance, 1 ether + 588_235_294_117_647_058);

        world.claim(player4);
        assertEq(address(player4).balance, 3 ether);
    }

    function testRevertClaimSingleton() public {
        address player1 = address(0x12345);

        Letter[] memory initialWord = new Letter[](5);
        initialWord[0] = Letter.H;
        initialWord[1] = Letter.E;
        initialWord[2] = Letter.L;
        initialWord[3] = Letter.L;
        initialWord[4] = Letter.O;

        world.start(initialWord, block.timestamp + 1e6, 0, m.getRoot(words), 0, 1e17, 3e18, 1e16, 3, 5);

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
        world.play{ value: wordPrice }(word, proof, Coord({ x: 4, y: -1 }), Direction.TOP_TO_BOTTOM, bounds);
        assertEq(address(player1).balance, wordPrice);
        assertEq(address(worldAddress).balance, wordPrice);

        vm.warp(block.timestamp + 1e6 + 1);
        world.end();

        vm.expectRevert();
        world.claim(address(0));

        vm.expectRevert();
        world.claim(SINGLETON_ADDRESS);
    }

    function testEndAndClaim() public {
        address player1 = address(0x12345);

        Letter[] memory initialWord = new Letter[](5);
        initialWord[0] = Letter.H;
        initialWord[1] = Letter.E;
        initialWord[2] = Letter.L;
        initialWord[3] = Letter.L;
        initialWord[4] = Letter.O;

        world.start(initialWord, block.timestamp + 1e6, 0, m.getRoot(words), 0, 1e17, 3e18, 1e16, 3, 5);

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
        world.play{ value: wordPrice }(word, proof, Coord({ x: 4, y: -1 }), Direction.TOP_TO_BOTTOM, bounds);
        assertEq(address(player1).balance, wordPrice);
        assertEq(address(worldAddress).balance, wordPrice);

        vm.warp(block.timestamp + 1e6 + 1);
        vm.prank(player1);
        vm.expectRevert();
        world.claim(player1);

        world.endAndClaim(player1);
        assertEq(address(player1).balance, wordPrice * 2);
        assertEq(address(worldAddress).balance, 0);
    }
}

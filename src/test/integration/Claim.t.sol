// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;
/* solhint-disable no-global-import */
/* solhint-disable func-name-mixedcase */

import { Words3Test } from "../Words3Test.t.sol";
import { Merkle } from "../murky/src/Merkle.sol";
import { Direction, Letter } from "codegen/common.sol";
import { FeeConfigData, Points, PriceConfigData, Treasury } from "codegen/index.sol";
import { Bound } from "common/Bound.sol";
import { Coord } from "common/Coord.sol";

import "forge-std/Test.sol";
import { ClaimSystem } from "systems/ClaimSystem.sol";

contract Claim is Words3Test {
    bytes32[] public words;
    Merkle private m;

    function setUp() public override {
        super.setUp();
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
        words.push(keccak256(bytes.concat(keccak256(abi.encode(omq))))); // omq, made up for testing
        words.push(keccak256(bytes.concat(keccak256(abi.encode(bqt))))); // bqt, made up for testing

        setDefaultLetterOdds();
    }

    function test_SimpleClaim() public {
        address player1 = address(0x12345);
        address player2 = address(0x54321);

        Letter[] memory initialWord = new Letter[](9);
        initialWord[0] = Letter.S;
        initialWord[1] = Letter.U;
        initialWord[2] = Letter.P;
        initialWord[3] = Letter.E;
        initialWord[4] = Letter.R;
        initialWord[5] = Letter.H;
        initialWord[6] = Letter.E;
        initialWord[7] = Letter.R;
        initialWord[8] = Letter.O;

        uint32[26] memory initialLetterAllocation;
        world.start({
            initialWord: initialWord,
            initialLetterAllocation: initialLetterAllocation,
            initialLettersTo: address(0),
            merkleRoot: m.getRoot(words),
            initialPrice: 0.001 ether,
            claimRestrictionDurationBlocks: 50,
            priceConfig: PriceConfigData({
                minPrice: 0.0001 ether,
                wadFactor: 1.3e18,
                wadDurationRoot: 2e18,
                wadDurationScale: 3000e18,
                wadDurationConstant: 0
            }),
            feeConfig: FeeConfigData({ feeBps: 0, feeTaker: address(0) }),
            crossWordRewardFraction: 3,
            bonusDistance: 5,
            numDrawLetters: 7
        });

        Letter[] memory word = new Letter[](4);
        word[0] = Letter.Z;
        word[1] = Letter.EMPTY;
        word[2] = Letter.N;
        word[3] = Letter.E;

        vm.deal(player1, 50 ether);

        Bound[] memory bounds = new Bound[](4);
        bytes32[] memory proof = m.getProof(words, 1);

        // Play zone
        vm.startPrank(player1);
        for (uint256 i = 0; i < 100; i++) {
            vm.roll(block.number + 1000);
            world.draw{ value: 0.5 ether }(player1);
        }
        world.play(word, proof, Coord({ x: 4, y: -1 }), Direction.TOP_TO_BOTTOM, bounds);
        vm.stopPrank();
        assertEq(address(player1).balance, 0);
        assertEq(address(worldAddress).balance, 50 ether);

        // Play zebra on zone
        vm.deal(player2, 50 ether);
        Letter[] memory word2 = new Letter[](5);
        word2[0] = Letter.EMPTY;
        word2[1] = Letter.E;
        word2[2] = Letter.B;
        word2[3] = Letter.R;
        word2[4] = Letter.A;

        bytes32[] memory proof2 = m.getProof(words, 3);
        Bound[] memory bounds2 = new Bound[](5);
        vm.startPrank(player2);
        for (uint256 i = 0; i < 100; i++) {
            vm.roll(block.number + 1000);
            world.draw{ value: 0.5 ether }(player2);
        }
        world.play(word2, proof2, Coord({ x: 4, y: -1 }), Direction.LEFT_TO_RIGHT, bounds2);
        vm.stopPrank();
        uint32 player1Points = Points.get(player1);
        uint32 player2Points = Points.get(player2);

        assertEq(Treasury.get(), 100 ether);

        vm.prank(player1);
        world.claim(player1Points);

        vm.prank(player2);
        world.claim(player2Points);

        uint256 player1ExpectedBalance =
            (100 ether * uint256(player1Points)) / (uint256(player1Points) + uint256(player2Points));

        assertEq(address(player1).balance, player1ExpectedBalance);
        assertEq(address(player2).balance, 100 ether - player1ExpectedBalance);
    }

    function test_ClaimAfterDonation() public {
        address player = address(0x12345);

        Letter[] memory initialWord = new Letter[](9);
        initialWord[0] = Letter.S;
        initialWord[1] = Letter.U;
        initialWord[2] = Letter.P;
        initialWord[3] = Letter.E;
        initialWord[4] = Letter.R;
        initialWord[5] = Letter.H;
        initialWord[6] = Letter.E;
        initialWord[7] = Letter.R;
        initialWord[8] = Letter.O;

        uint32[26] memory initialLetterAllocation;
        world.start({
            initialWord: initialWord,
            initialLetterAllocation: initialLetterAllocation,
            initialLettersTo: address(0),
            merkleRoot: m.getRoot(words),
            initialPrice: 0.001 ether,
            claimRestrictionDurationBlocks: 0,
            priceConfig: PriceConfigData({
                minPrice: 0.0001 ether,
                wadFactor: 1.3e18,
                wadDurationRoot: 2e18,
                wadDurationScale: 3000e18,
                wadDurationConstant: 0
            }),
            feeConfig: FeeConfigData({ feeBps: 0, feeTaker: address(0) }),
            crossWordRewardFraction: 3,
            bonusDistance: 5,
            numDrawLetters: 10
        });

        Letter[] memory word = new Letter[](2);
        word[0] = Letter.EMPTY;
        word[1] = Letter.M;

        vm.deal(player, 50 ether);

        Bound[] memory bounds = new Bound[](2);
        bytes32[] memory proof = m.getProof(words, 6);

        // Play om
        vm.startPrank(player);
        for (uint256 i = 0; i < 100; i++) {
            vm.roll(block.number + 1000);
            world.draw{ value: 0.5 ether }(player);
        }
        world.play(word, proof, Coord({ x: 4, y: 0 }), Direction.TOP_TO_BOTTOM, bounds);
        vm.stopPrank();
        assertEq(address(player).balance, 0);
        assertEq(address(worldAddress).balance, 50 ether);

        address donor = address(0x54321);
        vm.deal(donor, 50 ether);
        vm.prank(donor);
        world.donate{ value: 50 ether }();

        uint32 points = Points.get(player);
        vm.prank(player);
        world.claim(points);

        assertEq(address(player).balance, 100 ether);
    }

    function testFuzz_RevertsWhen_DoubleClaim(uint32 points) public {
        points = uint32(bound(points, 1, 4_294_967_295));

        address player = address(0x12345);

        Letter[] memory initialWord = new Letter[](7);
        initialWord[0] = Letter.P;
        initialWord[1] = Letter.A;
        initialWord[2] = Letter.T;
        initialWord[3] = Letter.R;
        initialWord[4] = Letter.I;
        initialWord[5] = Letter.O;
        initialWord[6] = Letter.T;

        uint32[26] memory initialLetterAllocation;
        world.start({
            initialWord: initialWord,
            initialLetterAllocation: initialLetterAllocation,
            initialLettersTo: address(0),
            merkleRoot: m.getRoot(words),
            initialPrice: 0.001 ether,
            claimRestrictionDurationBlocks: 0,
            priceConfig: PriceConfigData({
                minPrice: 0.0001 ether,
                wadFactor: 1.3e18,
                wadDurationRoot: 2e18,
                wadDurationScale: 3000e18,
                wadDurationConstant: 0
            }),
            feeConfig: FeeConfigData({ feeBps: 0, feeTaker: address(0) }),
            crossWordRewardFraction: 3,
            bonusDistance: 5,
            numDrawLetters: 20
        });

        Letter[] memory word = new Letter[](3);
        word[0] = Letter.E;
        word[1] = Letter.M;
        word[2] = Letter.EMPTY;

        vm.deal(player, 50 ether);

        Bound[] memory bounds = new Bound[](3);
        bytes32[] memory proof = m.getProof(words, 5);

        // Play emi
        vm.startPrank(player);
        for (uint256 i = 0; i < 10; i++) {
            vm.roll(block.number + 1e8);
            world.draw{ value: 5 ether }(player);
        }
        world.play(word, proof, Coord({ x: 1, y: -2 }), Direction.TOP_TO_BOTTOM, bounds);
        world.claim(Points.get(player));
        vm.stopPrank();

        assertEq(address(player).balance, 50 ether);

        vm.expectRevert(ClaimSystem.NotEnoughPoints.selector);
        vm.prank(player);
        world.claim(points);

        assertEq(address(player).balance, 50 ether);
    }

    function test_RevertsWhen_ClaimBeforeRestrictionPeriod() public {
        address player = address(0x12345);

        Letter[] memory initialWord = new Letter[](9);
        initialWord[0] = Letter.S;
        initialWord[1] = Letter.U;
        initialWord[2] = Letter.P;
        initialWord[3] = Letter.E;
        initialWord[4] = Letter.R;
        initialWord[5] = Letter.H;
        initialWord[6] = Letter.E;
        initialWord[7] = Letter.R;
        initialWord[8] = Letter.O;

        uint32[26] memory initialLetterAllocation;
        world.start({
            initialWord: initialWord,
            initialLetterAllocation: initialLetterAllocation,
            initialLettersTo: address(0),
            merkleRoot: m.getRoot(words),
            initialPrice: 0.001 ether,
            claimRestrictionDurationBlocks: 100 * 1000 + 1,
            priceConfig: PriceConfigData({
                minPrice: 0.0001 ether,
                wadFactor: 1.3e18,
                wadDurationRoot: 2e18,
                wadDurationScale: 3000e18,
                wadDurationConstant: 0
            }),
            feeConfig: FeeConfigData({ feeBps: 0, feeTaker: address(0) }),
            crossWordRewardFraction: 3,
            bonusDistance: 5,
            numDrawLetters: 10
        });

        Letter[] memory word = new Letter[](2);
        word[0] = Letter.EMPTY;
        word[1] = Letter.M;

        vm.deal(player, 50 ether);

        Bound[] memory bounds = new Bound[](2);
        bytes32[] memory proof = m.getProof(words, 6);

        vm.startPrank(player);
        for (uint256 i = 0; i < 100; i++) {
            vm.roll(block.number + 1000);
            world.draw{ value: 0.5 ether }(player);
        }
        world.play(word, proof, Coord({ x: 4, y: 0 }), Direction.TOP_TO_BOTTOM, bounds);
        vm.stopPrank();
        assertEq(address(player).balance, 0);
        assertEq(address(worldAddress).balance, 50 ether);

        uint32 points = Points.get(player);
        vm.prank(player);
        vm.expectRevert(ClaimSystem.WithinClaimRestrictionPeriod.selector);
        world.claim(points);

        assertEq(address(player).balance, 0);
        vm.roll(block.number + 2);

        vm.prank(player);
        world.claim(points);

        assertEq(address(player).balance, 50 ether);
    }

    function test_ClaimWithFee() public {
        address player = address(0x12345);

        Letter[] memory initialWord = new Letter[](9);
        initialWord[0] = Letter.S;
        initialWord[1] = Letter.U;
        initialWord[2] = Letter.P;
        initialWord[3] = Letter.E;
        initialWord[4] = Letter.R;
        initialWord[5] = Letter.H;
        initialWord[6] = Letter.E;
        initialWord[7] = Letter.R;
        initialWord[8] = Letter.O;
        address feeTaker = address(0x54321);
        uint32[26] memory initialLetterAllocation;
        world.start({
            initialWord: initialWord,
            initialLetterAllocation: initialLetterAllocation,
            initialLettersTo: address(0),
            merkleRoot: m.getRoot(words),
            initialPrice: 0.001 ether,
            claimRestrictionDurationBlocks: 0,
            priceConfig: PriceConfigData({
                minPrice: 0.0001 ether,
                wadFactor: 1.3e18,
                wadDurationRoot: 2e18,
                wadDurationScale: 3000e18,
                wadDurationConstant: 0
            }),
            feeConfig: FeeConfigData({ feeBps: 1000, feeTaker: feeTaker }),
            crossWordRewardFraction: 3,
            bonusDistance: 5,
            numDrawLetters: 10
        });

        Letter[] memory word = new Letter[](2);
        word[0] = Letter.EMPTY;
        word[1] = Letter.M;

        vm.deal(player, 50 ether);

        Bound[] memory bounds = new Bound[](2);
        bytes32[] memory proof = m.getProof(words, 6);

        vm.startPrank(player);
        for (uint256 i = 0; i < 100; i++) {
            vm.roll(block.number + 1000);
            world.draw{ value: 0.5 ether }(player);
        }
        world.play(word, proof, Coord({ x: 4, y: 0 }), Direction.TOP_TO_BOTTOM, bounds);
        vm.stopPrank();
        assertEq(address(player).balance, 0);
        assertEq(address(worldAddress).balance, 50 ether);

        uint32 points = Points.get(player);
        vm.prank(player);
        world.claim(points);

        assertEq(address(feeTaker).balance, 5 ether);
        assertEq(address(player).balance, 45 ether);
    }
}

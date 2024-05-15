// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;
/* solhint-disable no-global-import */
/* solhint-disable func-name-mixedcase */

import { Words3Test } from "../Words3Test.t.sol";
import { Merkle } from "../murky/src/Merkle.sol";
import { BonusType, Direction, Letter } from "codegen/common.sol";
import { FeeConfigData, Points, PriceConfigData } from "codegen/index.sol";
import { IWorld } from "codegen/world/IWorld.sol";
import { Bonus } from "common/Bonus.sol";
import { Bound } from "common/Bound.sol";
import { Coord } from "common/Coord.sol";
import "forge-std/Test.sol";
import { LibBonus } from "libraries/LibBonus.sol";

contract PointsTest is Words3Test {
    bytes32[] public words;
    Merkle private m;

    function setUp() public override {
        super.setUp();
        world = IWorld(worldAddress);
        m = new Merkle();
        Letter[] memory hi = new Letter[](2);
        hi[0] = Letter.H;
        hi[1] = Letter.I;
        Letter[] memory hello = new Letter[](5);
        hello[0] = Letter.H;
        hello[1] = Letter.E;
        hello[2] = Letter.L;
        hello[3] = Letter.L;
        hello[4] = Letter.O;
        Letter[] memory zone = new Letter[](4);
        zone[0] = Letter.Z;
        zone[1] = Letter.O;
        zone[2] = Letter.N;
        zone[3] = Letter.E;
        Letter[] memory zones = new Letter[](5);
        zones[0] = Letter.Z;
        zones[1] = Letter.O;
        zones[2] = Letter.N;
        zones[3] = Letter.E;
        zones[4] = Letter.S;
        Letter[] memory ollie = new Letter[](5);
        ollie[0] = Letter.O;
        ollie[1] = Letter.L;
        ollie[2] = Letter.L;
        ollie[3] = Letter.I;
        ollie[4] = Letter.E;
        words.push(keccak256(bytes.concat(keccak256(abi.encode(hi))))); // hi
        words.push(keccak256(bytes.concat(keccak256(abi.encode(hello))))); // hello
        words.push(keccak256(bytes.concat(keccak256(abi.encode(zone))))); // zone
        words.push(keccak256(bytes.concat(keccak256(abi.encode(zones))))); // zones
        words.push(keccak256(bytes.concat(keccak256(abi.encode(ollie))))); // ollie

        setDefaultLetterOdds();
    }

    function test_CountPoints() public {
        // Test works as long as points are not on bonus tiles
        address player1 = address(0x12345);
        address player2 = address(0x22345);

        Letter[] memory initialWord = new Letter[](5);
        initialWord[0] = Letter.H;
        initialWord[1] = Letter.E;
        initialWord[2] = Letter.L;
        initialWord[3] = Letter.L;
        initialWord[4] = Letter.O;

        uint32[26] memory initialLetterAllocation;
        world.start({
            initialWord: initialWord,
            initialLetterAllocation: initialLetterAllocation,
            initialLettersTo: address(0),
            merkleRoot: m.getRoot(words),
            initialPrice: 0.001 ether,
            claimRestrictionDurationBlocks: 0,
            priceConfig: PriceConfigData({
                minPrice: 0.001 ether,
                wadPriceIncreaseFactor: 1.115e18,
                wadPower: 0.9e18,
                wadScale: 9.96e36
            }),
            feeConfig: FeeConfigData({ feeBps: 0, feeTaker: address(0) }),
            crossWordRewardFraction: 3,
            bonusDistance: 10,
            numDrawLetters: 7
        });

        Letter[] memory word = new Letter[](4);
        word[0] = Letter.Z;
        word[1] = Letter.EMPTY;
        word[2] = Letter.N;
        word[3] = Letter.E;

        Bound[] memory bounds = new Bound[](4);
        bytes32[] memory proof = m.getProof(words, 2);

        // Play zone
        vm.deal(player1, 50 ether);
        vm.startPrank(player1);
        for (uint256 i = 0; i < 50; i++) {
            vm.roll(block.number + 100);
            world.draw{ value: world.getDrawPrice() }(player1);
        }
        world.play(word, proof, Coord({ x: 2, y: -1 }), Direction.TOP_TO_BOTTOM, bounds);
        vm.stopPrank();
        assertEq(Points.get(player1), 13);

        // Play zones
        Letter[] memory ext = new Letter[](5);
        ext[0] = Letter.EMPTY;
        ext[1] = Letter.EMPTY;
        ext[2] = Letter.EMPTY;
        ext[3] = Letter.EMPTY;
        ext[4] = Letter.S;
        Bound[] memory extBounds = new Bound[](5);
        bytes32[] memory extProof = m.getProof(words, 3);

        vm.deal(player2, 50 ether);
        vm.startPrank(player2);
        for (uint256 i = 0; i < 50; i++) {
            vm.roll(block.number + 100);
            world.draw{ value: world.getDrawPrice() }(player2);
        }
        world.play(ext, extProof, Coord({ x: 2, y: -1 }), Direction.TOP_TO_BOTTOM, extBounds);
        vm.stopPrank();
        assertEq(Points.get(player2), 14);

        // We lose 1 because of rounding
        assertEq(Points.get(player1), 13 + 4);
    }

    function test_Bonus() public {
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
                minPrice: 0.001 ether,
                wadPriceIncreaseFactor: 1.115e18,
                wadPower: 0.9e18,
                wadScale: 9.96e36
            }),
            feeConfig: FeeConfigData({ feeBps: 0, feeTaker: address(0) }),
            crossWordRewardFraction: 3,
            bonusDistance: 5,
            numDrawLetters: 7
        });

        Letter[] memory word = new Letter[](5);
        word[0] = Letter.EMPTY;
        word[1] = Letter.L;
        word[2] = Letter.L;
        word[3] = Letter.I;
        word[4] = Letter.E;

        Bound[] memory bounds = new Bound[](5);
        bytes32[] memory proof = m.getProof(words, 4);

        vm.deal(address(this), 50 ether);
        for (uint256 i = 0; i < 50; i++) {
            vm.roll(block.number + 100);
            world.draw{ value: world.getDrawPrice() }(address(this));
        }
        world.play(word, proof, Coord({ x: 4, y: 0 }), Direction.TOP_TO_BOTTOM, bounds);

        uint32 truePoints = 5;
        Bonus memory bonus = LibBonus.getTileBonus(Coord({ x: 4, y: 1 }));

        if (bonus.bonusType == BonusType.MULTIPLY_WORD) {
            truePoints *= bonus.bonusValue;
        } else {
            truePoints += bonus.bonusValue - 1;
        }
        assertEq(Points.get(address(this)), truePoints);
    }
}

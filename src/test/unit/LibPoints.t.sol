// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { BonusType, Direction, Letter } from "codegen/common.sol";
import { GameConfig } from "codegen/index.sol";
import { IWorld } from "codegen/world/IWorld.sol";

import { Bonus } from "common/Bonus.sol";

import { IWorld } from "codegen/world/IWorld.sol";
import { Coord } from "common/Coord.sol";
import { NoPointsForEmptyLetter } from "common/Errors.sol";
import { LibBonus } from "libraries/LibPoints.sol";
import { LibPoints } from "libraries/LibPoints.sol";

import { Words3Test } from "../Words3Test.t.sol";
import { Wrapper } from "./Wrapper.sol";
import "forge-std/Test.sol";

contract LibPointsTest is Words3Test {
    IWorld world;
    Wrapper wrapper;

    function setUp() public override {
        super.setUp();
        wrapper = new Wrapper();
        world = IWorld(worldAddress);
    }

    function testGetBaseLetterPoints() public {
        assertEq(LibPoints.getBaseLetterPoints(Letter.A), 1);
        assertEq(LibPoints.getBaseLetterPoints(Letter.B), 3);
        assertEq(LibPoints.getBaseLetterPoints(Letter.C), 3);
        assertEq(LibPoints.getBaseLetterPoints(Letter.D), 2);
        assertEq(LibPoints.getBaseLetterPoints(Letter.E), 1);
        assertEq(LibPoints.getBaseLetterPoints(Letter.X), 8);
        assertEq(LibPoints.getBaseLetterPoints(Letter.Y), 4);
        assertEq(LibPoints.getBaseLetterPoints(Letter.Z), 10);
    }

    function testGetBonusLetterPoints() public {
        Bonus memory bonus = Bonus({ bonusValue: 2, bonusType: BonusType.MULTIPLY_LETTER });
        assertEq(LibPoints.getBonusLetterPoints(Letter.A, bonus), 2);
        assertEq(LibPoints.getBonusLetterPoints(Letter.B, bonus), 6);
        assertEq(LibPoints.getBonusLetterPoints(Letter.C, bonus), 6);
        assertEq(LibPoints.getBonusLetterPoints(Letter.D, bonus), 4);
        assertEq(LibPoints.getBonusLetterPoints(Letter.E, bonus), 2);
        assertEq(LibPoints.getBonusLetterPoints(Letter.X, bonus), 16);
        assertEq(LibPoints.getBonusLetterPoints(Letter.Y, bonus), 8);
        assertEq(LibPoints.getBonusLetterPoints(Letter.Z, bonus), 20);
        bonus.bonusValue = 3;
        assertEq(LibPoints.getBonusLetterPoints(Letter.A, bonus), 3);
        assertEq(LibPoints.getBonusLetterPoints(Letter.B, bonus), 9);
        assertEq(LibPoints.getBonusLetterPoints(Letter.C, bonus), 9);
        assertEq(LibPoints.getBonusLetterPoints(Letter.D, bonus), 6);
        assertEq(LibPoints.getBonusLetterPoints(Letter.E, bonus), 3);
        assertEq(LibPoints.getBonusLetterPoints(Letter.X, bonus), 24);
        assertEq(LibPoints.getBonusLetterPoints(Letter.Y, bonus), 12);
        bonus.bonusType = BonusType.MULTIPLY_WORD;
        for (uint256 i = 0; i <= 26; i++) {
            if (i == 0) {
                vm.expectRevert();
                wrapper.pointsGetBonusLetterPoints(Letter(i), bonus);
            } else {
                assertEq(LibPoints.getBonusLetterPoints(Letter(i), bonus), LibPoints.getBaseLetterPoints(Letter(i)));
            }
        }
    }

    function testFuzzGetBonusLetterPoints(uint8 multiplier) public {
        vm.assume(multiplier > 0);
        Bonus memory bonus = Bonus({ bonusValue: uint32(multiplier), bonusType: BonusType.MULTIPLY_LETTER });
        for (uint256 i = 1; i <= 26; i++) {
            assertEq(
                LibPoints.getBonusLetterPoints(Letter(i), bonus), LibPoints.getBaseLetterPoints(Letter(i)) * multiplier
            );
        }
    }

    function testGetWordPoints() public {
        Letter[] memory initialWord = new Letter[](1);
        initialWord[0] = Letter.A;
        uint16 bonusDistance = 8;
        world.start(initialWord, block.timestamp + 1e6, bytes32(0x0), 0, 1e17, 3e18, 1e16, 3, bonusDistance);

        Letter[] memory playWord = new Letter[](bonusDistance);
        Letter[] memory filledWord = new Letter[](bonusDistance);
        for (uint256 i; i < bonusDistance; i++) {
            playWord[i] = Letter.A;
            filledWord[i] = Letter.A;
        }
        playWord[bonusDistance - 1] = Letter.EMPTY;

        Coord memory coord = Coord({ x: 0, y: 0 });
        Direction direction = Direction.LEFT_TO_RIGHT;
        uint32 points = LibPoints.getWordPoints(playWord, filledWord, coord, direction);

        uint32 truePoints = bonusDistance;
        Bonus memory bonus = LibBonus.getTileBonus(coord);
        if (bonus.bonusType == BonusType.MULTIPLY_WORD) {
            truePoints *= bonus.bonusValue;
        } else {
            truePoints += bonus.bonusValue - 1;
        }
        assertEq(points, truePoints);
    }

    /// forge-config: default.fuzz.runs = 300
    function testFuzzGetWordPointsNoBonus(uint8[] memory playWordRaw, bool directionRaw) public {
        Letter[] memory initialWord = new Letter[](1);
        initialWord[0] = Letter.A;
        uint16 bonusDistance = 3;
        world.start(initialWord, block.timestamp + 1e6, bytes32(0x0), 0, 1e17, 3e18, 1e16, 3, bonusDistance);

        // If the word does not touch any bonus tiles, points are equal to the base point value
        uint256 minLength = playWordRaw.length < bonusDistance - 1 ? playWordRaw.length : bonusDistance - 2;

        Letter[] memory playWord = new Letter[](minLength);
        Letter[] memory filledWord = new Letter[](minLength);
        for (uint256 i; i < minLength; i++) {
            uint8 letter = playWordRaw[i];
            if (letter > 26) {
                letter = 26;
            }
            playWord[i] = Letter(letter);
            if (playWordRaw[i] == 0) {
                filledWord[i] = Letter(1);
            } else {
                filledWord[i] = Letter(letter);
            }
        }
        Direction direction = Direction(directionRaw ? 1 : 0);
        Coord memory coord = direction == Direction.LEFT_TO_RIGHT ? Coord({ x: 1, y: 0 }) : Coord({ x: 0, y: 1 });
        uint32 points = LibPoints.getWordPoints(playWord, filledWord, coord, direction);

        uint32 basePoints = 0;
        for (uint256 i; i < filledWord.length; i++) {
            basePoints += LibPoints.getBaseLetterPoints(filledWord[i]);
        }
        assertEq(points, basePoints);
    }
}

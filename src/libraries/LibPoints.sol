// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Direction} from "codegen/Types.sol";
import {Letter} from "codegen/Types.sol";

import {Bound} from "common/Bound.sol";
import {Coord} from "common/Coord.sol";
import {LibBoard} from "libraries/LibBoard.sol";
import {LibPlayer} from "libraries/LibPlayer.sol";

import {NoPointsForEmptyLetter} from "common/Errors.sol";

library LibPoints {
    /// @notice Updates the score for a player for the main word and cross words
    function setScore(
        Letter[] memory filledWord,
        Coord memory coord,
        Direction direction,
        Bound[] memory bounds,
        address player
    ) internal {
        uint32 points = getWordPoints(filledWord);
        // Count points for cross words
        // This double counts points on purpose (points are recounted for every valid word)
        for (uint256 i; i < filledWord.length; i++) {
            uint16 positive = bounds[i].positive;
            uint16 negative = bounds[i].negative;
            if (positive != 0 || negative != 0) {
                Letter[] memory perpendicularWord = LibBoard.getCrossWord(
                    LibBoard.getRelativeCoord(coord, int32(uint32(i)), direction), filledWord[i], direction, bounds[i]
                );
                points += getWordPoints(perpendicularWord);
            }
        }

        LibPlayer.incrementScore(player, points);
    }

    /// @notice Get the points for a given word, the points are simply a sum of the letter point values
    function getWordPoints(Letter[] memory word) internal pure returns (uint32) {
        uint32 points;
        for (uint256 i; i < word.length; i++) {
            points += getLetterPoints(word[i]);
        }
        return points;
    }

    function getLetterPoints(Letter letter) internal pure returns (uint32) {
        if (letter == Letter.A) {
            return 1;
        } else if (letter == Letter.B) {
            return 3;
        } else if (letter == Letter.C) {
            return 3;
        } else if (letter == Letter.D) {
            return 2;
        } else if (letter == Letter.E) {
            return 1;
        } else if (letter == Letter.F) {
            return 4;
        } else if (letter == Letter.G) {
            return 2;
        } else if (letter == Letter.H) {
            return 4;
        } else if (letter == Letter.I) {
            return 1;
        } else if (letter == Letter.J) {
            return 8;
        } else if (letter == Letter.K) {
            return 5;
        } else if (letter == Letter.L) {
            return 1;
        } else if (letter == Letter.M) {
            return 3;
        } else if (letter == Letter.N) {
            return 1;
        } else if (letter == Letter.O) {
            return 1;
        } else if (letter == Letter.P) {
            return 3;
        } else if (letter == Letter.Q) {
            return 10;
        } else if (letter == Letter.R) {
            return 1;
        } else if (letter == Letter.S) {
            return 1;
        } else if (letter == Letter.T) {
            return 1;
        } else if (letter == Letter.U) {
            return 1;
        } else if (letter == Letter.V) {
            return 4;
        } else if (letter == Letter.W) {
            return 4;
        } else if (letter == Letter.X) {
            return 8;
        } else if (letter == Letter.Y) {
            return 4;
        } else if (letter == Letter.Z) {
            return 10;
        }
        revert NoPointsForEmptyLetter();
    }
}

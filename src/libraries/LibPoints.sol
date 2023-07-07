// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Direction, Letter, BonusType} from "codegen/Types.sol";
import {GameConfig, Points} from "codegen/Tables.sol";

import {Bonus} from "common/Bonus.sol";
import {Bound} from "common/Bound.sol";
import {Coord} from "common/Coord.sol";
import {LibBoard} from "libraries/LibBoard.sol";
import {LibPlayer} from "libraries/LibPlayer.sol";

import {NoPointsForEmptyLetter} from "common/Errors.sol";

address constant SingletonAddress = address(0);

library LibPoints {
    /// @notice Updates the score for a player for the main word and cross words
    function setScore(
        Letter[] memory word,
        Letter[] memory filledWord,
        Coord memory coord,
        Direction direction,
        Bound[] memory bounds,
        address player
    ) internal returns (uint32) {
        uint32 pointsWithoutBonus = getWordPoints(filledWord);
        // Count points for cross words
        // This double counts points on purpose (points are recounted for every valid word)
        for (uint256 i; i < filledWord.length; i++) {
            uint16 positive = bounds[i].positive;
            uint16 negative = bounds[i].negative;
            if (positive != 0 || negative != 0) {
                Letter[] memory perpendicularWord = LibBoard.getCrossWord(
                    LibBoard.getRelativeCoord(coord, int32(uint32(i)), direction), filledWord[i], direction, bounds[i]
                );
                pointsWithoutBonus += getWordPoints(perpendicularWord);
            }
        }
        uint32 points = addBonusPoints(word, coord, direction, pointsWithoutBonus);
        LibPlayer.incrementScore(player, points);
        return points;
    }

    function setCrossWordRewards(uint32 points, address[] memory crossWordPlayers) internal {
        uint32 numCrossWordPlayers = 0;
        for (uint256 i; i < crossWordPlayers.length; i++) {
            if (crossWordPlayers[i] != address(0)) {
                numCrossWordPlayers++;
            }
        }
        if (numCrossWordPlayers == 0) {
            return;
        }

        uint32 crossWordPoints = points / GameConfig.getCrossWordRewardFraction() / numCrossWordPlayers;

        for (uint256 i; i < crossWordPlayers.length; i++) {
            if (crossWordPlayers[i] != address(0)) {
                LibPlayer.incrementScore(crossWordPlayers[i], crossWordPoints);
            }
        }
    }

    /// @notice Get the points for a given word, not including bonuses
    function getWordPoints(Letter[] memory word) internal pure returns (uint32) {
        uint32 points;
        for (uint256 i; i < word.length; i++) {
            points += getLetterPoints(word[i]);
        }
        return points;
    }

    /// @notice Gets the bonus points for a word, takes a word with empty letters in
    function addBonusPoints(Letter[] memory playWord, Coord memory coord, Direction direction, uint32 baseWordPoints)
        internal
        pure
        returns (uint32)
    {
        uint32 wordMultiplier = 1;
        for (uint256 i; i < playWord.length; i++) {
            Letter letter = playWord[i];
            if (playWord[i] != Letter.EMPTY) {
                Coord memory letterCoord = LibBoard.getRelativeCoord(coord, int32(uint32(i)), direction);
                if (LibBoard.isBonusTile(letterCoord)) {
                    Bonus memory bonus = LibBoard.getTileBonus(letterCoord);
                    if (bonus.bonusType == BonusType.MULTIPLY_WORD) {
                        wordMultiplier *= bonus.bonusValue;
                    } else if (bonus.bonusType == BonusType.MULTIPLY_LETTER) {
                        baseWordPoints += getLetterPoints(letter) * (bonus.bonusValue - 1);
                    }
                }
            }
        }
        return baseWordPoints * wordMultiplier;
    }

    function getTotalPoints() internal view returns (uint32) {
        return Points.get(SingletonAddress);
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

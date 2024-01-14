// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { BonusType, Direction, Letter } from "codegen/common.sol";
import { GameConfig, Points, PointsResult } from "codegen/index.sol";
import { Bonus } from "common/Bonus.sol";
import { Bound } from "common/Bound.sol";
import { SINGLETON_ADDRESS } from "common/Constants.sol";
import { Coord } from "common/Coord.sol";

import { NoPointsForEmptyLetter } from "common/Errors.sol";
import { LibBoard } from "libraries/LibBoard.sol";
import { LibBonus } from "libraries/LibBonus.sol";
import { LibPlayer } from "libraries/LibPlayer.sol";

library LibPoints {
    /// @notice Updates the score for a player for the main word and cross words
    function setScore(
        Letter[] memory playWord,
        Letter[] memory filledWord,
        Coord memory start,
        Direction direction,
        Bound[] memory bounds,
        address player,
        uint256 playResultId
    )
        internal
        returns (uint32)
    {
        uint32 points = getPoints(playWord, filledWord, start, direction, bounds);
        LibPlayer.incrementScore(player, points);
        PointsResult.set(playResultId, player, -1, points);
        return points;
    }

    function getPoints(
        Letter[] memory playWord,
        Letter[] memory filledWord,
        Coord memory start,
        Direction direction,
        Bound[] memory bounds
    )
        internal
        view
        returns (uint32)
    {
        uint32 points = getWordPoints(playWord, filledWord, start, direction);

        // Count points for cross words (double counts by design)
        Direction crossDirection =
            direction == Direction.LEFT_TO_RIGHT ? Direction.TOP_TO_BOTTOM : Direction.LEFT_TO_RIGHT;
        for (uint256 i; i < playWord.length; i++) {
            Letter letter = playWord[i];
            if (letter == Letter.EMPTY) {
                continue;
            }
            uint16 positive = bounds[i].positive;
            uint16 negative = bounds[i].negative;
            if (positive == 0 && negative == 0) {
                continue;
            }

            Coord memory letterCoord = LibBoard.getRelativeCoord(start, int32(uint32(i)), direction);

            Letter[] memory crossFilledWord = LibBoard.getCrossWord(letterCoord, letter, direction, bounds[i]);
            Letter[] memory crossPlayWord = new Letter[](crossFilledWord.length);
            for (uint256 j; j < crossFilledWord.length; j++) {
                if (j == negative) {
                    crossPlayWord[j] = letter;
                } else {
                    crossPlayWord[j] = Letter.EMPTY;
                }
            }

            Coord memory crossStart =
                LibBoard.getRelativeCoord(letterCoord, -1 * int32(uint32(negative)), crossDirection);

            points += getWordPoints(crossPlayWord, crossFilledWord, crossStart, crossDirection);
        }
        return points;
    }

    function setBuildsOnWordRewards(uint32 points, address[] memory buildsOnPlayers, uint256 playResultId) internal {
        if (buildsOnPlayers.length == 0) {
            return;
        }

        uint32 rewardPoints = points / GameConfig.getCrossWordRewardFraction() / uint32(buildsOnPlayers.length);

        for (uint256 i; i < buildsOnPlayers.length; i++) {
            if (buildsOnPlayers[i] != address(0)) {
                address player = buildsOnPlayers[i];
                LibPlayer.incrementScore(player, rewardPoints);
                PointsResult.set(playResultId, player, int16(uint16(i)), rewardPoints);
            }
        }
    }

    function getTotalPoints() internal view returns (uint32) {
        return Points.get(SINGLETON_ADDRESS);
    }

    function getWordPoints(
        Letter[] memory word,
        Letter[] memory filledWord,
        Coord memory start,
        Direction direction
    )
        internal
        pure
        returns (uint32)
    {
        uint32 points = 0;
        uint32 multiplier = 1;

        for (uint256 i; i < word.length; i++) {
            Coord memory letterCoord = LibBoard.getRelativeCoord(start, int32(uint32(i)), direction);
            if (word[i] != Letter.EMPTY && LibBonus.isBonusTile(letterCoord)) {
                Bonus memory bonus = LibBonus.getTileBonus(letterCoord);
                if (bonus.bonusType == BonusType.MULTIPLY_WORD) {
                    multiplier *= bonus.bonusValue;
                }

                points += getBonusLetterPoints(word[i], bonus);
            } else {
                points += getBaseLetterPoints(filledWord[i]);
            }
        }

        return points * multiplier;
    }

    function getBonusLetterPoints(Letter letter, Bonus memory bonus) internal pure returns (uint32) {
        uint32 basePoints = getBaseLetterPoints(letter);
        if (bonus.bonusType == BonusType.MULTIPLY_LETTER) {
            return basePoints * bonus.bonusValue;
        }
        return basePoints;
    }

    function getBaseLetterPoints(Letter letter) internal pure returns (uint32) {
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
            return 3;
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

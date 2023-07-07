// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Direction, Letter, BonusType} from "codegen/Types.sol";

import {Bonus} from "common/Bonus.sol";
import {Bound} from "common/Bound.sol";
import {Coord} from "common/Coord.sol";
import {BoundTooLong, EmptyLetterInBounds, LetterOnExistingLetter} from "common/Errors.sol";
import {LibTile} from "libraries/LibTile.sol";

library LibBoard {
    uint16 constant MAX_BOUND_LENGTH = 200;

    function getRelativeCoord(Coord memory startCoord, int32 distance, Direction direction)
        internal
        pure
        returns (Coord memory)
    {
        if (direction == Direction.LEFT_TO_RIGHT) {
            return Coord({x: startCoord.x + distance, y: startCoord.y});
        } else {
            return Coord({x: startCoord.x, y: startCoord.y + distance});
        }
    }

    /// @notice Returns coordinates immediately outside of a bound in the perpendicular direction
    function getCoordsOutsideBound(Coord memory letterCoord, Direction wordDirection, Bound memory bound)
        internal
        pure
        returns (Coord memory, Coord memory)
    {
        if (bound.positive > MAX_BOUND_LENGTH || bound.negative > MAX_BOUND_LENGTH) {
            revert BoundTooLong();
        }
        Coord memory start = Coord({x: letterCoord.x, y: letterCoord.y});
        Coord memory end = Coord({x: letterCoord.x, y: letterCoord.y});
        if (wordDirection == Direction.LEFT_TO_RIGHT) {
            start.y -= (int32(uint32(bound.negative)) + 1);
            end.y += (int32(uint32(bound.positive)) + 1);
        } else {
            start.x -= (int32(uint32(bound.negative)) + 1);
            end.x += (int32(uint32(bound.positive)) + 1);
        }
        return (start, end);
    }

    /// @notice Gets the cross word inside a given boundary
    function getCrossWord(Coord memory letterCoord, Letter letter, Direction direction, Bound memory bound)
        internal
        view
        returns (Letter[] memory)
    {
        uint16 wordLength = bound.positive + bound.negative + 1;
        Letter[] memory word = new Letter[](wordLength);
        Coord memory coord;
        // Start at edge of negative bound
        if (direction == Direction.LEFT_TO_RIGHT) {
            coord = LibBoard.getRelativeCoord(letterCoord, -1 * int32(uint32(bound.negative)), Direction.TOP_TO_BOTTOM);
        } else {
            coord = LibBoard.getRelativeCoord(letterCoord, -1 * int32(uint32(bound.negative)), Direction.LEFT_TO_RIGHT);
        }
        for (uint256 i = 0; i < wordLength; i++) {
            word[i] = LibTile.getLetter(coord);

            if (uint32(i) == uint32(bound.negative)) {
                word[i] = letter;
            }

            if (word[i] == Letter.EMPTY) {
                revert EmptyLetterInBounds();
            }

            if (direction == Direction.LEFT_TO_RIGHT) {
                coord.y += 1;
            } else {
                coord.x += 1;
            }
        }

        return word;
    }

    function isBonusTile(Coord memory coord) internal pure returns (bool) {
        int32 x = abs(coord.x);
        int32 y = abs(coord.y);
        return ((x - y) % 4) == 0;
    }

    /// @notice Assumes that isBonusTile is called to check if the tile is a bonus tile first
    function getTileBonus(Coord memory coord) internal pure returns (Bonus memory) {
        int32 x = abs(coord.x);
        int32 y = abs(coord.y);
        int32 bonusValue = max(x, y) / 4 + 2;
        if (x % 4 == 0 && y % 4 == 0) {
            return Bonus({bonusValue: uint32(bonusValue), bonusType: BonusType.MULTIPLY_WORD});
        }
        return Bonus({bonusValue: uint32(bonusValue), bonusType: BonusType.MULTIPLY_LETTER});
    }

    function abs(int32 x) private pure returns (int32) {
        if (x < 0) {
            return -x;
        }
        return x;
    }

    function max(int32 x, int32 y) private pure returns (int32) {
        if (x > y) {
            return x;
        }
        return y;
    }
}

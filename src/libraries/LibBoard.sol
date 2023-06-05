// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Direction} from "codegen/Types.sol";
import {Letter} from "codegen/Types.sol";

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
}

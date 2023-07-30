// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Direction, Letter} from "codegen/Types.sol";

import {Bound} from "common/Bound.sol";
import {Coord} from "common/Coord.sol";
import {BoundTooLong, EmptyLetterInBounds} from "common/Errors.sol";
import {LibTile} from "libraries/LibTile.sol";
import "forge-std/Test.sol";

library LibBoard {
    uint16 constant MAX_BOUND_LENGTH = 50;

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

        int32 positiveDistance = int32(uint32(bound.positive)) + 1;
        int32 negativeDistance = int32(uint32(bound.negative)) + 1;

        if (wordDirection == Direction.LEFT_TO_RIGHT) {
            start.y -= negativeDistance;
            end.y += positiveDistance;
        } else {
            start.x -= negativeDistance;
            end.x += positiveDistance;
        }

        return (start, end);
    }

    /// @notice Gets the cross word inside a given boundary
    function getCrossWord(Coord memory letterCoord, Letter letter, Direction wordDirection, Bound memory bound)
        internal
        view
        returns (Letter[] memory)
    {
        uint16 wordLength = bound.positive + bound.negative + 1;
        Letter[] memory word = new Letter[](wordLength);

        Direction crossDirection =
            wordDirection == Direction.TOP_TO_BOTTOM ? Direction.LEFT_TO_RIGHT : Direction.TOP_TO_BOTTOM;

        Coord memory startCoord =
            LibBoard.getRelativeCoord(letterCoord, -1 * int32(uint32(bound.negative)), crossDirection);

        for (uint16 i = 0; i < wordLength; i++) {
            Coord memory coord = LibBoard.getRelativeCoord(startCoord, int32(uint32(i)), wordDirection);
            word[i] = LibTile.getLetter(coord);

            if (word[i] == Letter.EMPTY) {
                revert EmptyLetterInBounds();
            }

            if (i == bound.negative) {
                word[i] = letter;
            }
        }

        return word;
    }
}

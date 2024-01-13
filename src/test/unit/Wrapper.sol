// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Direction, Letter } from "codegen/common.sol";

import { Bonus } from "common/Bonus.sol";
import { Bound } from "common/Bound.sol";
import { Coord } from "common/Coord.sol";

import { LibBoard } from "libraries/LibBoard.sol";
import { LibPlay } from "libraries/LibPlay.sol";
import { LibPoints } from "libraries/LibPoints.sol";

contract Wrapper {
    function playCheckCrossWords(
        Letter[] memory word,
        Coord memory coord,
        Direction direction,
        Bound[] memory bounds
    )
        public
        view
        returns (address[] memory)
    {
        return LibPlay.checkCrossWords(word, coord, direction, bounds);
    }

    function playCheckWord(
        Letter[] memory word,
        bytes32[] memory proof,
        Coord memory coord,
        Direction direction
    )
        public
        view
    {
        LibPlay.checkWord(word, proof, coord, direction);
    }

    function boardGetCoordsOutsideBound(
        Coord memory coord,
        Direction direction,
        Bound memory bound
    )
        public
        pure
        returns (Coord memory, Coord memory)
    {
        return LibBoard.getCoordsOutsideBound(coord, direction, bound);
    }

    function pointsGetBonusLetterPoints(Letter letter, Bonus memory bonus) public pure returns (uint32) {
        return LibPoints.getBonusLetterPoints(letter, bonus);
    }
}

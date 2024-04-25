// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { Direction, Letter } from "codegen/common.sol";
import { Bound } from "common/Bound.sol";
import { Coord } from "common/Coord.sol";
import { LibGame } from "libraries/LibGame.sol";

import { LibLetters } from "libraries/LibLetters.sol";
import { LibPlay } from "libraries/LibPlay.sol";

contract PlaySystem is System {
    error CannotPlay();
    error PlayMissingLetters();

    /// @notice Checks if a move is valid and if so, plays a word on the board
    /// @param word Letters of the word being played, empty letters mean using existing letters on board
    /// @param proof Merkle proof that the word is in the dictionary
    /// @param coord Starting coord that the word is being played from
    /// @param direction Direction the word is being played (top-down, or left-to-right)
    /// @param bounds Bounds of all other words on the cross axis this word makes
    function play(
        Letter[] memory word,
        bytes32[] memory proof,
        Coord memory coord,
        Direction direction,
        Bound[] memory bounds
    )
        public
    {
        address player = _msgSender();
        if (!LibGame.canPlay()) {
            revert CannotPlay();
        }
        if (!LibLetters.hasLetters({ player: player, letters: word })) {
            revert PlayMissingLetters();
        }
        LibLetters.useLetters({ player: player, letters: word });
        LibPlay.play({ word: word, proof: proof, coord: coord, direction: direction, bounds: bounds, player: player });
    }
}

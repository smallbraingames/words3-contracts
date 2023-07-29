// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Direction} from "codegen/Types.sol";
import {Letter} from "codegen/Types.sol";

import {Bound} from "common/Bound.sol";
import {Coord} from "common/Coord.sol";
import {NotEnoughValue, CannotPlay} from "common/Errors.sol";

import {LibPlay} from "libraries/LibPlay.sol";
import {LibPrice} from "libraries/LibPrice.sol";
import {LibTreasury} from "libraries/LibTreasury.sol";
import {LibGame} from "libraries/LibGame.sol";

import {System} from "@latticexyz/world/src/System.sol";

contract PlaySystem is System {
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
    ) public payable {
        if (msg.value < LibPrice.getWordPrice(word)) {
            revert NotEnoughValue();
        }
        if (!LibGame.canPlay()) {
            revert CannotPlay();
        }
        LibTreasury.incrementTreasury(_msgSender(), msg.value);
        LibPlay.play(word, proof, coord, direction, bounds, _msgSender());
    }

    function getWordPrice(Letter[] memory word) public view returns (uint256) {
        return LibPrice.getWordPrice(word);
    }
}

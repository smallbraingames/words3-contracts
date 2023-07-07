// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Direction} from "codegen/Types.sol";
import {Letter} from "codegen/Types.sol";
import {MerkleRootConfig} from "codegen/Tables.sol";

import {Bound} from "common/Bound.sol";
import {Coord} from "common/Coord.sol";
import {
    WordTooLong,
    InvalidWordStart,
    InvalidWordEnd,
    EmptyLetterNotOnExistingLetter,
    LetterOnExistingLetter,
    LonelyWord,
    NoLettersPlayed,
    WordNotInDictionary,
    InvalidBoundLength,
    NonzeroEmptyLetterBound,
    NonemptyBoundEdges
} from "common/Errors.sol";
import {LibBoard} from "libraries/LibBoard.sol";
import {LibPoints} from "libraries/LibPoints.sol";
import {LibTile} from "libraries/LibTile.sol";

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

library LibPlay {
    uint16 constant MAX_WORD_LENGTH = 200;

    function play(
        Letter[] memory word,
        bytes32[] memory proof,
        Coord memory coord,
        Direction direction,
        Bound[] memory bounds,
        address player
    ) internal {
        checkWord(word, proof, coord, direction);
        address[] memory crossWordPlayers = checkCrossWords(word, coord, direction, bounds);
        Letter[] memory filledWord = setTiles(word, coord, direction, player);
        uint32 points = LibPoints.setScore(word, filledWord, coord, direction, bounds, player);
        LibPoints.setCrossWordRewards(points, crossWordPlayers);
    }

    function setTiles(Letter[] memory word, Coord memory coord, Direction direction, address player)
        internal
        returns (Letter[] memory)
    {
        Letter[] memory filledWord = new Letter[](word.length);

        // Place tiles and fill filledWord
        for (uint256 i = 0; i < word.length; i++) {
            Coord memory letterCoord = LibBoard.getRelativeCoord(coord, int32(uint32(i)), direction);
            if (word[i] == Letter.EMPTY) {
                filledWord[i] = LibTile.getLetter(letterCoord);
            } else {
                filledWord[i] = word[i];
                LibTile.setTile(letterCoord, word[i], player);
            }
        }
        return filledWord;
    }

    function checkCrossWords(Letter[] memory word, Coord memory coord, Direction direction, Bound[] memory bounds)
        internal
        view
        returns (address[] memory)
    {
        // Ensure bounds of correct length
        if (bounds.length != word.length) {
            revert InvalidBoundLength();
        }

        address[] memory crossWordPlayers = new address[](word.length);

        for (uint256 i; i < word.length; i++) {
            uint16 positive = bounds[i].positive;
            uint16 negative = bounds[i].negative;

            if (positive + negative + 1 > MAX_WORD_LENGTH) {
                revert WordTooLong();
            }

            Coord memory letterCoord = LibBoard.getRelativeCoord(coord, int32(uint32(i)), direction);

            if (word[i] == Letter.EMPTY) {
                // Ensure bounds are 0 if letter is empty
                // since you cannot get points for words formed by letters you did not play
                if (positive != 0 || negative != 0) {
                    revert NonzeroEmptyLetterBound();
                }
                crossWordPlayers[i] = LibTile.getPlayer(letterCoord);
            } else {
                // Ensure bounds are valid (empty at edges) for nonempty letters
                // Bounds that are too large will be caught while verifying formed words
                Bound memory bound = bounds[i];

                (Coord memory start, Coord memory end) = LibBoard.getCoordsOutsideBound(
                    LibBoard.getRelativeCoord(coord, int32(uint32(i)), direction), direction, bound
                );
                if (LibTile.getLetter(start) != Letter.EMPTY || LibTile.getLetter(end) != Letter.EMPTY) {
                    revert NonemptyBoundEdges();
                }

                if (bound.positive != 0 || bound.negative != 0) {
                    // Ensure cross word is valid
                    Letter[] memory crossWord = LibBoard.getCrossWord(letterCoord, word[i], direction, bound);
                    if (!isWordInDictionary(crossWord, bound.proof)) {
                        revert WordNotInDictionary();
                    }

                    // Get cross word player
                    Direction crossDirection = Direction((uint8(direction) + 1) % 2);
                    if (bound.positive != 0) {
                        Coord memory crossWordStart = LibBoard.getRelativeCoord(letterCoord, 1, crossDirection);
                        crossWordPlayers[i] = LibTile.getPlayer(crossWordStart);
                    } else {
                        Coord memory crossWordEnd = LibBoard.getRelativeCoord(letterCoord, -1, crossDirection);
                        crossWordPlayers[i] = LibTile.getPlayer(crossWordEnd);
                    }
                }
            }
        }
        return crossWordPlayers;
    }

    /// @notice Checks if a word is a valid move (without checking cross words)
    /// Specifically, this checks that a word is 1) has valid bounds, 2) is played on another word & has at least one letter and 3) is a valid word
    function checkWord(Letter[] memory word, bytes32[] memory proof, Coord memory coord, Direction direction)
        internal
        view
    {
        // 1. Check bounds
        if (word.length > MAX_WORD_LENGTH) {
            revert WordTooLong();
        }
        Coord memory startEdge = LibBoard.getRelativeCoord(coord, -1, direction);
        if (LibTile.getLetter(startEdge) != Letter.EMPTY) {
            revert InvalidWordStart();
        }
        // Don't need SafeCast because word.length < MAX_WORD_LENGTH < MAX_INT32
        Coord memory endEdge = LibBoard.getRelativeCoord(coord, int32(uint32(word.length)), direction);
        if (LibTile.getLetter(endEdge) != Letter.EMPTY) {
            revert InvalidWordEnd();
        }

        // 2. Check word is played on another word, has at least one letter, and has valid cross bounds
        bool containsEmpty = false;
        bool containsLetter = false;

        Letter[] memory filledWord = new Letter[](word.length);

        for (uint256 i = 0; i < word.length; i++) {
            Coord memory letterCoord = LibBoard.getRelativeCoord(coord, int32(uint32(i)), direction);
            if (word[i] == Letter.EMPTY) {
                containsEmpty = true;

                // Ensure empty letter is played on existing letter
                Letter existingLetter = LibTile.getLetter(letterCoord);
                if (existingLetter == Letter.EMPTY) {
                    revert EmptyLetterNotOnExistingLetter();
                }

                filledWord[i] = existingLetter;
            } else {
                containsLetter = true;

                // Ensure non-empty letter is played on empty tile
                if (LibTile.getLetter(letterCoord) != Letter.EMPTY) {
                    revert LetterOnExistingLetter();
                }

                filledWord[i] = word[i];
            }
        }

        // Ensure word is played on another word
        if (!containsEmpty) {
            revert LonelyWord();
        }
        // Ensure word has at least one letter
        if (!containsLetter) {
            revert NoLettersPlayed();
        }

        // 3. Ensure word is a valid word
        if (!isWordInDictionary(filledWord, proof)) {
            revert WordNotInDictionary();
        }
    }

    function isWordInDictionary(Letter[] memory word, bytes32[] memory proof) internal view returns (bool) {
        bytes32 merkleRoot = MerkleRootConfig.get();
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(word))));
        bool isValidLeaf = MerkleProof.verify(proof, merkleRoot, leaf);
        return isValidLeaf;
    }
}

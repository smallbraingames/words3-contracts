// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { Direction, Letter } from "codegen/common.sol";
import { MerkleRootConfig, PlayUpdate } from "codegen/index.sol";
import { Bound } from "common/Bound.sol";
import { MAX_WORD_LENGTH } from "common/Constants.sol";
import { Coord } from "common/Coord.sol";
import {
    EmptyLetterNotOnExistingLetter,
    InvalidBoundLength,
    InvalidWordEnd,
    InvalidWordStart,
    LetterOnExistingLetter,
    LonelyWord,
    NoLettersPlayed,
    NonemptyBoundEdges,
    NonzeroEmptyLetterBound,
    WordNotInDictionary,
    WordTooLong
} from "common/Errors.sol";
import { LibBoard } from "libraries/LibBoard.sol";
import { LibPoints } from "libraries/LibPoints.sol";
import { LibTile } from "libraries/LibTile.sol";
import { LibUpdateId } from "libraries/LibUpdateId.sol";

library LibPlay {
    function play(
        Letter[] memory word,
        bytes32[] memory proof,
        Coord memory coord,
        Direction direction,
        Bound[] memory bounds,
        address player
    )
        internal
    {
        checkWord({ word: word, proof: proof, coord: coord, direction: direction, bounds: bounds });
        address[] memory buildsOnPlayers =
            checkCrossWords({ word: word, coord: coord, direction: direction, bounds: bounds });
        Letter[] memory filledWord = setTiles({ word: word, coord: coord, direction: direction, player: player });
        uint256 playUpdateId = LibUpdateId.getUpdateId();
        uint32 points = LibPoints.setScore({
            playWord: word,
            filledWord: filledWord,
            start: coord,
            direction: direction,
            bounds: bounds,
            player: player,
            playUpdateId: playUpdateId
        });
        LibPoints.setBuildsOnWordRewards({ points: points, buildsOnPlayers: buildsOnPlayers, playUpdateId: playUpdateId });
        emitPlayResult({
            word: word,
            filledWord: filledWord,
            coord: coord,
            direction: direction,
            player: player,
            playUpdateId: playUpdateId
        });
    }

    function emitPlayResult(
        Letter[] memory word,
        Letter[] memory filledWord,
        Coord memory coord,
        Direction direction,
        address player,
        uint256 playUpdateId
    )
        internal
    {
        PlayUpdate.set({
            id: playUpdateId,
            player: player,
            direction: direction,
            timestamp: block.timestamp,
            x: coord.x,
            y: coord.y,
            word: wordToUint8Array({ word: word }),
            filledWord: wordToUint8Array({ word: filledWord })
        });
    }

    function setTiles(
        Letter[] memory word,
        Coord memory coord,
        Direction direction,
        address player
    )
        internal
        returns (Letter[] memory)
    {
        Letter[] memory filledWord = new Letter[](word.length);

        // Place tiles and fill filledWord
        for (uint256 i = 0; i < word.length; i++) {
            Coord memory letterCoord =
                LibBoard.getRelativeCoord({ startCoord: coord, distance: int32(uint32(i)), direction: direction });
            if (word[i] == Letter.EMPTY) {
                filledWord[i] = LibTile.getLetter({ coord: letterCoord });
            } else {
                filledWord[i] = word[i];
                LibTile.setTile({ coord: letterCoord, letter: word[i], player: player });
            }
        }
        return filledWord;
    }

    function checkCrossWords(
        Letter[] memory word,
        Coord memory coord,
        Direction direction,
        Bound[] memory bounds
    )
        internal
        view
        returns (address[] memory)
    {
        // Ensure bounds of correct length
        if (bounds.length != word.length) {
            revert InvalidBoundLength();
        }

        address[] memory buildsOnPlayers = new address[](word.length * 2);

        for (uint256 i; i < word.length; i++) {
            uint16 positive = bounds[i].positive;
            uint16 negative = bounds[i].negative;

            if (positive + negative + 1 > MAX_WORD_LENGTH) {
                revert WordTooLong();
            }

            Coord memory letterCoord =
                LibBoard.getRelativeCoord({ startCoord: coord, distance: int32(uint32(i)), direction: direction });

            if (word[i] == Letter.EMPTY) {
                // Ensure bounds are 0 if letter is empty
                // since you cannot get points for words formed by letters you did not play
                if (positive != 0 || negative != 0) {
                    revert NonzeroEmptyLetterBound();
                }

                bool hasPlayedLetterNegative = i > 0 && word[i - 1] != Letter.EMPTY;
                bool hasPlayedLetterPositive = i < word.length - 1 && word[i + 1] != Letter.EMPTY;
                if (hasPlayedLetterNegative || hasPlayedLetterPositive) {
                    buildsOnPlayers[i * 2] = LibTile.getPlayer({ coord: letterCoord });
                }
            } else {
                // Ensure bounds are valid (empty at edges) for nonempty letters
                // Bounds that are too large will be caught while verifying formed words
                Bound memory bound = bounds[i];

                (Coord memory start, Coord memory end) =
                    LibBoard.getCoordsOutsideBound({ letterCoord: letterCoord, wordDirection: direction, bound: bound });
                if (
                    LibTile.getLetter({ coord: start }) != Letter.EMPTY
                        || LibTile.getLetter({ coord: end }) != Letter.EMPTY
                ) {
                    revert NonemptyBoundEdges();
                }

                if (positive != 0 || negative != 0) {
                    // Ensure cross word is valid
                    Letter[] memory crossWord = LibBoard.getCrossWord({letterCoord: letterCoord, letter: word[i], wordDirection: direction, bound: bound});
                    if (!isWordInDictionary({ word: crossWord, proof: bound.proof })) {
                        revert WordNotInDictionary();
                    }

                    Direction crossDirection =
                        direction == Direction.LEFT_TO_RIGHT ? Direction.TOP_TO_BOTTOM : Direction.LEFT_TO_RIGHT;
                    if (positive > 0) {
                        Coord memory buildsOnWordPositive = LibBoard.getRelativeCoord({
                            startCoord: letterCoord,
                            distance: 1,
                            direction: crossDirection
                        });
                        buildsOnPlayers[i * 2] = LibTile.getPlayer({ coord: buildsOnWordPositive });
                    }
                    if (negative > 0) {
                        Coord memory buildsOnWordNegative = LibBoard.getRelativeCoord({
                            startCoord: letterCoord,
                            distance: -1,
                            direction: crossDirection
                        });
                        buildsOnPlayers[i * 2 + 1] = LibTile.getPlayer({ coord: buildsOnWordNegative });
                    }
                }
            }
        }
        return stripZeroAddresses({ addresses: buildsOnPlayers });
    }

    /// @notice Checks if a word is a valid move (without checking cross words)
    /// Specifically, this checks that a word is 1) has valid bounds, 2) is played on another word & has at least one
    /// letter and 3) is a valid word
    function checkWord(
        Letter[] memory word,
        bytes32[] memory proof,
        Coord memory coord,
        Direction direction,
        Bound[] memory bounds
    )
        internal
        view
    {
        // 1. Check bounds
        if (word.length > MAX_WORD_LENGTH) {
            revert WordTooLong();
        }
        Coord memory startEdge = LibBoard.getRelativeCoord({ startCoord: coord, distance: -1, direction: direction });
        if (LibTile.getLetter({ coord: startEdge }) != Letter.EMPTY) {
            revert InvalidWordStart();
        }
        Coord memory endEdge =
            LibBoard.getRelativeCoord({ startCoord: coord, distance: int32(uint32(word.length)), direction: direction });
        if (LibTile.getLetter({ coord: endEdge }) != Letter.EMPTY) {
            revert InvalidWordEnd();
        }

        // 2. Check word is played on another word, has at least one letter, and has valid cross bounds
        bool containsEmpty = false;
        bool containsLetter = false;

        Letter[] memory filledWord = new Letter[](word.length);

        for (uint256 i = 0; i < word.length; i++) {
            Coord memory letterCoord =
                LibBoard.getRelativeCoord({ startCoord: coord, distance: int32(uint32(i)), direction: direction });
            if (word[i] == Letter.EMPTY) {
                containsEmpty = true;

                // Ensure empty letter is played on existing letter
                Letter existingLetter = LibTile.getLetter({ coord: letterCoord });
                if (existingLetter == Letter.EMPTY) {
                    revert EmptyLetterNotOnExistingLetter();
                }

                filledWord[i] = existingLetter;
            } else {
                containsLetter = true;

                // Ensure non-empty letter is played on empty tile
                if (LibTile.getLetter({ coord: letterCoord }) != Letter.EMPTY) {
                    revert LetterOnExistingLetter();
                }

                filledWord[i] = word[i];
            }
        }

        // Ensure word is played on another word
        if (!containsEmpty) {
            // If it is not directly played on a word, check that it has at least one cross word
            bool hasCrossWord = false;
            for (uint256 i = 0; i < bounds.length; i++) {
                if (bounds[i].positive != 0 || bounds[i].negative != 0) {
                    hasCrossWord = true;
                    break;
                }
            }
            if (!hasCrossWord) {
                revert LonelyWord();
            }
        }
        // Ensure word has at least one letter
        if (!containsLetter) {
            revert NoLettersPlayed();
        }

        // 3. Ensure word is a valid word
        if (!isWordInDictionary({ word: filledWord, proof: proof })) {
            revert WordNotInDictionary();
        }
    }

    function isWordInDictionary(Letter[] memory word, bytes32[] memory proof) internal view returns (bool) {
        bytes32 merkleRoot = MerkleRootConfig.get();
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(word))));
        bool isValidLeaf = MerkleProof.verify({ proof: proof, root: merkleRoot, leaf: leaf });
        return isValidLeaf;
    }

    function stripZeroAddresses(address[] memory addresses) internal pure returns (address[] memory) {
        uint256 numNonZeroAddresses = 0;
        for (uint256 i = 0; i < addresses.length; i++) {
            if (addresses[i] != address(0)) {
                numNonZeroAddresses++;
            }
        }

        address[] memory nonZeroAddresses = new address[](numNonZeroAddresses);
        uint256 nonZeroAddressesIndex = 0;
        for (uint256 i = 0; i < addresses.length; i++) {
            if (addresses[i] != address(0)) {
                nonZeroAddresses[nonZeroAddressesIndex] = addresses[i];
                nonZeroAddressesIndex++;
            }
        }

        return nonZeroAddresses;
    }

    function wordToUint8Array(Letter[] memory word) internal pure returns (uint8[] memory) {
        uint8[] memory uint8Word = new uint8[](word.length);
        for (uint256 i = 0; i < word.length; i++) {
            uint8Word[i] = uint8(word[i]);
        }
        return uint8Word;
    }
}

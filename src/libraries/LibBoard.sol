// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0;

import {Letter} from "codegen/Types.sol";
import {TileTableData} from "codegen/Tables.sol";

import {Coord} from "common/Coord.sol";
import {BoundTooLong, EmptyLetterInBounds, InvalidWord, AlreadySetupGrid} from "common/Errors.sol";
import {Direction} from "common/Direction.sol";
import {LibTile} from "libraries/LibTile.sol";

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

library LibBoard {
    /// @notice Verifies a Merkle proof to check if a given word is in the dictionary
    function verifyWordProof(
        Letter[] memory word,
        bytes32[] memory proof,
        bytes32 merkleRoot
    ) internal pure {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(word))));
        bool isValidLeaf = MerkleProof.verify(proof, merkleRoot, leaf);
        if (!isValidLeaf) revert InvalidWord();
    }

    /// @notice Get the amount of rewards paid to every empty tile in the word
    function getRewardPerEmptyTile(
        Letter[] memory word,
        uint256 rewardFraction,
        uint256 value
    ) internal pure returns (uint256) {
        uint256 numEmptyTiles;
        for (uint32 i = 0; i < word.length; i++) {
            if (word[i] == Letter.EMPTY) numEmptyTiles++;
        }
        // msg.value / rewardFraction is total to be paid out in rewards, split across numEmptyTiles
        return (value / rewardFraction) / numEmptyTiles;
    }

    /// @notice Gets the position of a letter in a word given an offset and a direction
    /// @dev Useful for looping through words
    /// @param letterOffset The offset of the position from the start position
    /// @param coord The starting coord of the word
    /// @param direction The direction the word is being played in
    function getLetterCoord(
        int32 letterOffset,
        Coord memory coord,
        Direction direction
    ) internal pure returns (Coord memory) {
        if (direction == Direction.LEFT_TO_RIGHT) {
            return Coord({x: coord.x + letterOffset, y: coord.y});
        } else {
            return Coord({x: coord.x, y: coord.y + letterOffset});
        }
    }

    /// @notice Gets the coords OUTSIDE a boundary on the boundary axis
    /// @dev Useful for checking if a boundary is valid
    /// @param letterCoord The starting coord of the letter for which the boundary is for
    /// @param direction The direction the original word (not the boundary) is being played in
    /// @param positive The distance the bound spans in the positive direction
    /// @param negative The distance the bound spans in the negative direction
    function getOutsideBoundCoords(
        Coord memory letterCoord,
        Direction direction,
        uint32 positive,
        uint32 negative
    ) internal pure returns (Coord memory, Coord memory) {
        if (positive > 200 || negative > 200) revert BoundTooLong();
        Coord memory start = Coord({x: letterCoord.x, y: letterCoord.y});
        Coord memory end = Coord({x: letterCoord.x, y: letterCoord.y});
        if (direction == Direction.LEFT_TO_RIGHT) {
            start.y -= (int32(negative) + 1);
            end.y += (int32(positive) + 1);
        } else {
            start.x -= (int32(negative) + 1);
            end.x += (int32(positive) + 1);
        }
        return (start, end);
    }

    /// @notice Gets the word inside a given boundary and checks to make sure there are no empty letters in the bound
    /// @dev Assumes that the word being made this round has already been played on board
    function getWordInBoundsChecked(
        Coord memory letterCoord,
        Direction direction,
        uint32 positive,
        uint32 negative
    ) internal view returns (Letter[] memory) {
        uint32 wordLength = positive + negative + 1;
        Letter[] memory word = new Letter[](wordLength);
        Coord memory coord;
        // Start at edge of negative bound
        if (direction == Direction.LEFT_TO_RIGHT) {
            coord = LibBoard.getLetterCoord(
                -1 * int32(negative),
                letterCoord,
                Direction.TOP_TO_BOTTOM
            );
        } else {
            coord = LibBoard.getLetterCoord(
                -1 * int32(negative),
                letterCoord,
                Direction.LEFT_TO_RIGHT
            );
        }
        for (uint32 i = 0; i < wordLength; i++) {
            word[i] = LibTile.getTileAtCoord(coord).letter;
            if (word[i] == Letter.EMPTY) revert EmptyLetterInBounds();
            if (direction == Direction.LEFT_TO_RIGHT) {
                coord.y += 1;
            } else {
                coord.x += 1;
            }
        }
        return word;
    }

    /// @notice Plays the first word "infinite" on the board
    function playInfinite() internal {
        if (LibTile.hasTileAtCoord(Coord({x: 0, y: 0}))) {
            revert AlreadySetupGrid();
        }
        LibTile.setTileAtCoord(
            Coord({x: 0, y: 0}),
            TileTableData({player: address(0), letter: Letter.I})
        );
        LibTile.setTileAtCoord(
            Coord({x: 1, y: 0}),
            TileTableData({player: address(0), letter: Letter.N})
        );
        LibTile.setTileAtCoord(
            Coord({x: 2, y: 0}),
            TileTableData({player: address(0), letter: Letter.F})
        );
        LibTile.setTileAtCoord(
            Coord({x: 3, y: 0}),
            TileTableData({player: address(0), letter: Letter.I})
        );
        LibTile.setTileAtCoord(
            Coord({x: 4, y: 0}),
            TileTableData({player: address(0), letter: Letter.N})
        );
        LibTile.setTileAtCoord(
            Coord({x: 5, y: 0}),
            TileTableData({player: address(0), letter: Letter.I})
        );
        LibTile.setTileAtCoord(
            Coord({x: 6, y: 0}),
            TileTableData({player: address(0), letter: Letter.T})
        );
        LibTile.setTileAtCoord(
            Coord({x: 7, y: 0}),
            TileTableData({player: address(0), letter: Letter.E})
        );
    }
}

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0;

import {System} from "solecs/System.sol";
import {IWorld} from "solecs/interfaces/IWorld.sol";
import {getAddressById, getSystemAddressById} from "solecs/utils.sol";
import {Coord} from "std-contracts/components/CoordComponent.sol";

import {Letter} from "common/Letter.sol";
import {Tile} from "common/Tile.sol";
import {Score} from "common/Score.sol";
import {RewardsComponent, ID as RewardsComponentID} from "components/RewardsComponent.sol";
import {TileComponent, ID as TileComponentID} from "components/TileComponent.sol";
import {ScoreComponent, ID as ScoreComponentID} from "components/ScoreComponent.sol";
import {LetterWeightComponent, ID as LetterWeightComponentID} from "components/LetterWeightComponent.sol";
import {PlaceLetterSystem, ID as PlaceLetterSystemID} from "systems/PlaceLetterSystem.sol";

import {Direction} from "common/Direction.sol";
import {Bounds} from "common/Bounds.sol";
import {LibBoard} from "libraries/LibBoard.sol";
import {LibLetter} from "libraries/LibLetter.sol";
import {LibPlayer} from "libraries/LibPlayer.sol";
import {LibPrice} from "libraries/LibPrice.sol";
import {LibTile} from "libraries/LibTile.sol";
import {GameOver, PaymentTooLow, WordTooLong, InvalidWordStart, InvalidWordEnd, EmptyLetterNotOnExisting, LonelyWord, NoLettersPlayed, LetterOnExistingTile, BoundsDoNotMatch, InvalidBoundLength, InvalidBoundEdges, InvalidEmptyLetterBound, InvalidCrossProofs} from "common/Errors.sol";

uint256 constant ID = uint256(keccak256("system.Board"));

/// @title Game Board System for Words3
/// @author Small Brain Games
/// @notice Logic for placing words, scoring points, and claiming winnings
contract BoardSystem is System {
    /// ============ Immutable Storage ============

    /// @notice End time for game end
    uint256 public immutable endTime = block.timestamp + 86400 * 7;
    /// @notice End time for game start
    uint256 public immutable startTime = block.timestamp;
    /// @notice Amount of sales that go to rewards (1/4)
    uint256 public immutable rewardFraction = 4;
    /// @notice Total price of all letters scaled by 1e18
    int256 public immutable totalPrice = 25e14;

    /// @notice Treasury (mutable variable, sorry ECS)
    uint256 public treasury;

    /// @notice Merkle root for dictionary of words
    bytes32 private merkleRoot =
        0xacd24e8edae5cf4cdbc3ce0c196a670cbea1dbf37576112b0a3defac3318b432;

    constructor(
        IWorld _world,
        address _components
    ) System(_world, _components) {}

    /// ============ Public functions ============

    function execute(bytes memory arguments) public returns (bytes memory) {
        (
            Letter[] memory word,
            bytes32[] memory proof,
            Coord memory coord,
            Direction direction,
            Bounds memory bounds
        ) = abi.decode(
                arguments,
                (Letter[], bytes32[], Coord, Direction, Bounds)
            );
        executeInternal(word, proof, coord, direction, bounds);
    }

    /// @notice Checks if a move is valid and if so, plays a word on the board
    /// @param word The letters of the word being played, empty letters mean using existing letters on board
    /// @param proof The Merkle proof that the word is in the dictionary
    /// @param coord The starting coord that the word is being played from
    /// @param direction The direction the word is being played (top-down, or left-to-right)
    /// @param bounds The bounds of all other words on the cross axis this word makes
    function executeTyped(
        Letter[] memory word,
        bytes32[] memory proof,
        Coord memory coord,
        Direction direction,
        Bounds memory bounds
    ) public payable returns (bytes memory) {
        return execute(abi.encode(word, proof, coord, direction, bounds));
    }

    /// ============ Private functions ============

    /// @notice Internal function to check if a move is valid and if so, play it on the board
    /// @dev Making execute payable breaks the System interface, so executeInternal is needed
    function executeInternal(
        Letter[] memory word,
        bytes32[] memory proof,
        Coord memory coord,
        Direction direction,
        Bounds memory bounds
    ) private {
        // Ensure game is not ever
        if (isGameOver()) {
            revert GameOver();
        }

        // Ensure payment is sufficient
        uint256 price = getWordPrice(word);
        if (msg.value < price) {
            revert PaymentTooLow();
        }

        // Check if move is valid, and if so, make it
        makeMoveChecked(word, proof, coord, direction, bounds);
    }

    /// @notice Checks if a move is valid, and if so, update TileComponent and ScoreComponent
    function makeMoveChecked(
        Letter[] memory word,
        bytes32[] memory proof,
        Coord memory coord,
        Direction direction,
        Bounds memory bounds
    ) private {
        TileComponent tileComponent = TileComponent(
            getAddressById(components, TileComponentID)
        );
        checkWord(word, proof, coord, direction, tileComponent);
        checkBounds(word, coord, direction, bounds, tileComponent);
        Letter[] memory filledWord = processWord(
            word,
            coord,
            direction,
            tileComponent
        );
        countPointsChecked(filledWord, coord, direction, bounds, tileComponent);
    }

    /// @notice Checks if a word is 1) played on another word, 2) has at least one letter, 3) is a valid word, 4) has valid bounds, and 5) has not been played yet
    function checkWord(
        Letter[] memory word,
        bytes32[] memory proof,
        Coord memory coord,
        Direction direction,
        TileComponent tileComponent
    ) public view {
        // Ensure word is less than 200 letters
        if (word.length > 200) revert WordTooLong();
        // Ensure word isn't missing letters at edges
        if (
            LibTile.hasTileAtCoord(
                LibBoard.getLetterCoord(-1, coord, direction),
                tileComponent
            )
        ) {
            revert InvalidWordStart();
        }
        if (
            LibTile.hasTileAtCoord(
                LibBoard.getLetterCoord(
                    int32(uint32(word.length)),
                    coord,
                    direction
                ),
                tileComponent
            )
        ) {
            revert InvalidWordEnd();
        }

        bool emptyTile = false;
        bool nonEmptyTile = false;

        Letter[] memory filledWord = new Letter[](word.length);

        for (uint32 i = 0; i < word.length; i++) {
            Coord memory letterCoord = LibBoard.getLetterCoord(
                int32(i),
                coord,
                direction
            );
            if (word[i] == Letter.EMPTY) {
                emptyTile = true;

                // Ensure empty letter is played on existing letter
                if (!LibTile.hasTileAtCoord(letterCoord, tileComponent))
                    revert EmptyLetterNotOnExisting();

                filledWord[i] = LibTile
                    .getTileAtCoord(letterCoord, tileComponent)
                    .letter;
            } else {
                nonEmptyTile = true;

                // Ensure non-empty letter is played on empty tile
                if (LibTile.hasTileAtCoord(letterCoord, tileComponent))
                    revert LetterOnExistingTile();

                filledWord[i] = word[i];
            }
        }

        // Ensure word is played on another word
        if (!emptyTile) revert LonelyWord();
        // Ensure word has at least one letter
        if (!nonEmptyTile) revert NoLettersPlayed();
        // Ensure word is a valid word
        LibBoard.verifyWordProof(filledWord, proof, merkleRoot);
    }

    /// @notice Checks if the given bounds for other words on the cross axis are well formed
    function checkBounds(
        Letter[] memory word,
        Coord memory coord,
        Direction direction,
        Bounds memory bounds,
        TileComponent tileComponent
    ) private view {
        // Ensure bounds of equal length
        if (bounds.positive.length != bounds.negative.length)
            revert BoundsDoNotMatch();
        // Ensure bounds of correct length
        if (bounds.positive.length != word.length) revert InvalidBoundLength();
        // Ensure proof of correct length
        if (bounds.positive.length != bounds.proofs.length)
            revert InvalidCrossProofs();

        // Ensure positive and negative bounds are valid
        for (uint32 i; i < word.length; i++) {
            if (word[i] == Letter.EMPTY) {
                // Ensure bounds are 0 if letter is empty
                // since you cannot get points for words formed by letters you did not play
                if (bounds.positive[i] != 0 || bounds.negative[i] != 0)
                    revert InvalidEmptyLetterBound();
            } else {
                // Ensure bounds are valid (empty at edges) for nonempty letters
                // Bounds that are too large will be caught while verifying formed words
                (Coord memory start, Coord memory end) = LibBoard
                    .getOutsideBoundCoords(
                        LibBoard.getLetterCoord(int32(i), coord, direction),
                        direction,
                        bounds.positive[i],
                        bounds.negative[i]
                    );
                if (
                    LibTile.hasTileAtCoord(start, tileComponent) ||
                    LibTile.hasTileAtCoord(end, tileComponent)
                ) revert InvalidBoundEdges();
            }
        }
    }

    /// @notice 1) Places the word on the board, 2) adds word rewards to other players, and 3) returns a filled in word
    /// @return filledWord A word that has empty letters replaced with the underlying letters from the board
    function processWord(
        Letter[] memory word,
        Coord memory coord,
        Direction direction,
        TileComponent tileComponent
    ) private returns (Letter[] memory) {
        Letter[] memory filledWord = new Letter[](word.length);

        // Rewards are tracked in the score component
        RewardsComponent rewardsComponent = RewardsComponent(
            getAddressById(components, RewardsComponentID)
        );

        // The PlaceLetterSystem will place letters and increment weights
        PlaceLetterSystem placeLetterSystem = PlaceLetterSystem(
            getSystemAddressById(components, PlaceLetterSystemID)
        );
        // It needs daysSinceStart to do this
        int256 daysSinceStart = LibPrice.getDaysSinceStart(startTime);

        // Evenly split the reward fraction of among tiles the player used to create their word
        // Rewards are only awarded to players who are used in the "primary" word
        uint256 rewardPerEmptyTile = LibBoard.getRewardPerEmptyTile(
            word,
            rewardFraction,
            msg.value
        );

        // Place tiles and fill filledWord
        for (uint32 i = 0; i < word.length; i++) {
            Coord memory letterCoord = LibBoard.getLetterCoord(
                int32(i),
                coord,
                direction
            );
            if (word[i] == Letter.EMPTY) {
                Tile memory tile = LibTile.getTileAtCoord(
                    letterCoord,
                    tileComponent
                );
                LibPlayer.incrementRewards(
                    tile.player,
                    rewardPerEmptyTile,
                    rewardsComponent
                );
                filledWord[i] = tile.letter;
            } else {
                filledWord[i] = word[i];
                placeLetterSystem.executeTyped(
                    letterCoord,
                    msg.sender,
                    word[i],
                    daysSinceStart
                );
            }
        }
        return filledWord;
    }

    /// @notice Updates the score for a player for the main word and cross words and checks every cross word
    /// @dev Expects a word input with empty letters filled in
    function countPointsChecked(
        Letter[] memory filledWord,
        Coord memory coord,
        Direction direction,
        Bounds memory bounds,
        TileComponent tiles
    ) private {
        uint32 points = countPointsForWord(filledWord);
        // Count points for perpendicular word
        // This double counts points on purpose (points are recounted for every valid word)
        for (uint32 i; i < filledWord.length; i++) {
            if (bounds.positive[i] != 0 || bounds.negative[i] != 0) {
                Letter[] memory perpendicularWord = LibBoard
                    .getWordInBoundsChecked(
                        LibBoard.getLetterCoord(int32(i), coord, direction),
                        direction,
                        bounds.positive[i],
                        bounds.negative[i],
                        tiles
                    );
                LibBoard.verifyWordProof(
                    perpendicularWord,
                    bounds.proofs[i],
                    merkleRoot
                );
                points += countPointsForWord(perpendicularWord);
            }
        }
        ScoreComponent scoreComponent = ScoreComponent(
            getAddressById(components, ScoreComponentID)
        );
        LibPlayer.incrementScore(msg.sender, points, scoreComponent);
    }

    /// @notice Get the points for a given word, the points are simply a sum of the letter point values
    function countPointsForWord(
        Letter[] memory word
    ) private pure returns (uint32) {
        uint32 points;
        for (uint32 i; i < word.length; i++) {
            points += LibLetter.getPointsForLetter(word[i]);
        }
        return points;
    }

    /// @notice Get price for a letter
    function getLetterPrice(
        Letter letter,
        int256 totalWeight,
        LetterWeightComponent letterWeightComponent
    ) public view returns (uint256) {
        return
            uint256(
                LibPrice.getLetterPrice(
                    letter,
                    totalWeight,
                    totalPrice,
                    letterWeightComponent
                )
            );
    }

    /// @notice Get price for a word
    function getWordPrice(Letter[] memory word) public view returns (uint256) {
        LetterWeightComponent letterWeightComponent = LetterWeightComponent(
            getAddressById(components, LetterWeightComponentID)
        );
        uint256 price;
        int256 totalWeight = LibPrice.getTotalWeight(letterWeightComponent);
        for (uint32 i = 0; i < word.length; i++) {
            if (word[i] != Letter.EMPTY) {
                price += getLetterPrice(
                    word[i],
                    totalWeight,
                    letterWeightComponent
                );
            }
        }
        return price;
    }

    /// @notice Get if game is over.
    function isGameOver() private view returns (bool) {
        return block.timestamp >= endTime;
    }
}
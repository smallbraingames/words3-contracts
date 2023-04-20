// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0;

import {Letter} from "common/Letter.sol";
import {LetterWeightComponent} from "components/LetterWeightComponent.sol";
import {LibLetter} from "libraries/LibLetter.sol";
import {wadExp, wadMul, wadDiv, toWadUnsafe, toDaysWadUnsafe} from "utils/SignedWadMath.sol";

library LibPrice {
    function getLetterPrice(
        Letter letter,
        int256 totalWeight, // Total weight of all letters
        int256 totalPrice, // Total price of all letters, scaled by 1e18
        LetterWeightComponent letterWeightComponent
    ) internal view returns (int256) {
        int256 letterWeight = getLetterWeight(letter, letterWeightComponent);
        return wadMul(wadDiv(letterWeight, totalWeight), totalPrice);
    }

    function incrementLetterWeight(
        Letter letter,
        int256 daysSinceStart,
        LetterWeightComponent letterWeightComponent
    ) internal {
        uint256 letterEntity = getLetterWeightEntityForLetter(letter);
        int256 prevWeight = getLetterWeight(letter, letterWeightComponent);
        letterWeightComponent.set(
            letterEntity,
            prevWeight +
                wadMul(
                    wadExp(daysSinceStart),
                    toWadUnsafe(LibLetter.getPointsForLetter(letter))
                )
        );
    }

    function getLetterWeight(
        Letter letter,
        LetterWeightComponent letterWeightComponent
    ) internal view returns (int256) {
        uint256 letterEntity = getLetterWeightEntityForLetter(letter);
        return letterWeightComponent.getValue(letterEntity);
    }

    function getLetterWeightEntityForLetter(
        Letter letter
    ) internal pure returns (uint256) {
        return
            uint256(
                bytes32(
                    bytes.concat(
                        bytes1(uint8(letter)),
                        // All non-tile entities are players (address entities)
                        // or tiles (entities where the 22nd byte is all 1s), so
                        // this prevents collisions between entities
                        bytes20(type(uint160).max)
                    )
                )
            );
    }

    function getDaysSinceStart(
        uint256 startTime
    ) internal view returns (int256) {
        return toWadUnsafe(1) + toDaysWadUnsafe(block.timestamp - startTime);
    }

    function getTotalWeight(
        LetterWeightComponent letterWeightComponent
    ) internal view returns (int256) {
        int256 totalWeight = 0;
        for (uint8 i = 1; i <= 26; i++) {
            Letter letter = Letter(i);
            totalWeight += getLetterWeight(letter, letterWeightComponent);
        }
        return totalWeight;
    }

    function setupLetterWeights(
        LetterWeightComponent letterWeightComponent
    ) internal {
        for (uint8 i = 1; i <= 26; i++) {
            Letter letter = Letter(i);
            uint256 entity = getLetterWeightEntityForLetter(letter);
            letterWeightComponent.set(entity, toWadUnsafe(1));
        }
    }
}

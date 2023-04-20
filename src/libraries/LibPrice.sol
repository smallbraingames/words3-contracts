// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0;

import {Letter} from "codegen/Types.sol";
import {WeightTable} from "codegen/Tables.sol";

import {LibLetter} from "libraries/LibLetter.sol";

import {wadExp, wadMul, wadDiv, toWadUnsafe, toDaysWadUnsafe} from "utils/SignedWadMath.sol";

library LibPrice {
    function getLetterPrice(
        Letter letter,
        int256 totalWeight, // Total weight of all letters
        int256 totalPrice // Total price of all letters, scaled by 1e18
    ) internal view returns (int256) {
        int256 letterWeight = getLetterWeight(letter);
        return wadMul(wadDiv(letterWeight, totalWeight), totalPrice);
    }

    function incrementLetterWeight(
        Letter letter,
        int256 daysSinceStart
    ) internal {
        int256 prevWeight = getLetterWeight(letter);
        WeightTable.set(
            letter,
            prevWeight +
                wadMul(
                    wadExp(daysSinceStart),
                    toWadUnsafe(LibLetter.getPointsForLetter(letter))
                )
        );
    }

    function getLetterWeight(Letter letter) internal view returns (int256) {
        return WeightTable.get(letter);
    }

    function getDaysSinceStart(
        uint256 startTime
    ) internal view returns (int256) {
        return toWadUnsafe(1) + toDaysWadUnsafe(block.timestamp - startTime);
    }

    function getTotalWeight() internal view returns (int256) {
        int256 totalWeight = 0;
        for (uint8 i = 1; i <= 26; i++) {
            Letter letter = Letter(i);
            totalWeight += getLetterWeight(letter);
        }
        return totalWeight;
    }

    function setupLetterWeights() internal {
        for (uint8 i = 1; i <= 26; i++) {
            Letter letter = Letter(i);
            WeightTable.set(letter, toWadUnsafe(1));
        }
    }
}

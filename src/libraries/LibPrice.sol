// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {VRGDAConfig, VRGDAConfigData, LetterCount} from "codegen/Tables.sol";
import {Letter} from "codegen/Types.sol";

import {LETTER_WEIGHT_FRACTION} from "common/Constants.sol";
import {LibPoints} from "libraries/LibPoints.sol";

import {
    wadExp,
    wadLn,
    wadMul,
    unsafeWadMul,
    unsafeWadDiv,
    toWadUnsafe,
    toDaysWadUnsafe
} from "solmate/src/utils/SignedWadMath.sol";

library LibPrice {
    function getWordPrice(Letter[] memory word) internal view returns (uint256) {
        uint256 price = 0;
        for (uint256 i = 0; i < word.length; i++) {
            Letter letter = word[i];
            if (letter != Letter.EMPTY) {
                price += getLetterPrice(word[i]);
            }
        }
        return price;
    }

    // Adapted from transmissions11/VRGDAs (https://github.com/transmissions11/VRGDAs)
    function getLetterPrice(Letter letter) internal view returns (uint256) {
        VRGDAConfigData memory vrgdaConfig = VRGDAConfig.get();
        int256 decayConstant = wadLn(1e18 - vrgdaConfig.priceDecay);
        int256 daysSinceStart = toDaysWadUnsafe(block.timestamp - vrgdaConfig.startTime);
        uint256 letterCount = uint256(LetterCount.get(letter));
        uint256 letterWeight = (LibPoints.getBaseLetterPoints(letter) / LETTER_WEIGHT_FRACTION + 1) * letterCount;
        int256 nOverK = unsafeWadDiv(toWadUnsafe(letterWeight + 1), vrgdaConfig.perDay);
        unchecked {
            return
                uint256(wadMul(vrgdaConfig.targetPrice, wadExp(unsafeWadMul(decayConstant, daysSinceStart - nOverK))));
        }
    }
}

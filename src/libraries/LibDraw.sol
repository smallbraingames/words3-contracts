// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Letter } from "codegen/common.sol";
import { DrawLetterOdds } from "codegen/index.sol";

library LibDraw {
    function getDraw(uint8 numLetters, uint256 random) internal view returns (Letter[] memory) {
        uint8[] memory odds = DrawLetterOdds.get();

        // This sum is recomputed every function call to support overriding odds in the future
        uint256 sumOfOdds = 0;
        for (uint8 i = 0; i < odds.length; i++) {
            sumOfOdds += odds[i];
        }

        Letter[] memory bag = new Letter[](sumOfOdds);

        uint256 index = 0;
        for (uint256 i = 0; i < odds.length; i++) {
            Letter letter = Letter(i);
            uint8 letterOdds = odds[i];

            for (uint256 j = 0; j < letterOdds; j++) {
                bag[index] = letter;
                index++;
            }
        }

        Letter[] memory letters = new Letter[](numLetters);
        for (uint256 i = 0; i < numLetters; i++) {
            uint256 randomIndex = uint256(keccak256(abi.encodePacked(random + i))) % sumOfOdds;
            letters[i] = bag[randomIndex];
        }

        return letters;
    }
}

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0;

import {Letter} from "common/Letter.sol";
import {LetterCountComponent, ID as LetterCountComponentID} from "components/LetterCountComponent.sol";

library LibLetterCount {
    function incrementLetterCount(
        Letter letter,
        LetterCountComponent letterCountComponent
    ) internal {
        uint256 letterEntity = getLetterEntity(letter);
        if (letterCountComponent.has(letterEntity)) {
            uint32 previous = letterCountComponent.getValue(letterEntity);
            letterCountComponent.set(letterEntity, previous + 1);
        } else {
            letterCountComponent.set(letterEntity, 1);
        }
    }

    function getLetterEntity(Letter letter) internal pure returns (uint256) {
        return uint256(keccak256(abi.encode(LetterCountComponentID, letter)));
    }
}

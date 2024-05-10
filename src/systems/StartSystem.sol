// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { Letter, Status } from "codegen/common.sol";

import { PriceConfigData } from "codegen/index.sol";
import { MAX_WORD_LENGTH } from "common/Constants.sol";
import { Coord } from "common/Coord.sol";
import { LibGame } from "libraries/LibGame.sol";
import { LibLetters } from "libraries/LibLetters.sol";
import { LibTile } from "libraries/LibTile.sol";

contract StartSystem is System {
    error GameAlreadyStarted();
    error InitialWordTooLong();

    function start(
        Letter[] memory initialWord,
        uint32[26] memory initialLetterAllocation,
        address initialLettersTo,
        bytes32 merkleRoot,
        uint256 initialPrice,
        PriceConfigData memory priceConfig,
        uint32 crossWordRewardFraction,
        uint16 bonusDistance,
        uint8 numDrawLetters
    )
        public
    {
        if (LibGame.getGameStatus() != Status.NOT_STARTED) {
            revert GameAlreadyStarted();
        }
        writeInitialWordChecked({ initialWord: initialWord });
        allocateInitialLetters({ initialLetterAllocation: initialLetterAllocation, initialLettersTo: initialLettersTo });
        LibGame.startGame({
            merkleRoot: merkleRoot,
            initialPrice: initialPrice,
            priceConfig: priceConfig,
            crossWordRewardFraction: crossWordRewardFraction,
            bonusDistance: bonusDistance,
            numDrawLetters: numDrawLetters
        });
    }

    function writeInitialWordChecked(Letter[] memory initialWord) private {
        uint256 wordLength = initialWord.length;
        if (wordLength > MAX_WORD_LENGTH) {
            revert InitialWordTooLong();
        }
        int32 xOffset = int32(uint32(wordLength)) / 2;
        for (uint256 i = 0; i < initialWord.length; i++) {
            Coord memory coord = Coord({ x: int32(uint32(i)) - xOffset, y: 0 });
            LibTile.setTile({ coord: coord, letter: initialWord[i], player: address(0) });
        }
    }

    function allocateInitialLetters(uint32[26] memory initialLetterAllocation, address initialLettersTo) private {
        for (uint256 i = 0; i < 26; i++) {
            Letter letter = Letter(i + 1);
            uint32 count = initialLetterAllocation[i];
            for (uint32 j = 0; j < count; j++) {
                LibLetters.addLetter({ player: initialLettersTo, letter: letter });
            }
        }
    }
}

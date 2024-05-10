// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { Letter, Status } from "codegen/common.sol";
import { MAX_WORD_LENGTH } from "common/Constants.sol";
import { Coord } from "common/Coord.sol";
import { LibGame } from "libraries/LibGame.sol";
import { LibTile } from "libraries/LibTile.sol";

contract StartSystem is System {
    error GameAlreadyStarted();
    error WordTooLong();

    function start(
        Letter[] memory initialWord,
        bytes32 merkleRoot,
        uint256 initialPrice,
        uint256 minPrice,
        int256 wadFactor,
        int256 wadDurationRoot,
        int256 wadDurationScale,
        int256 wadDurationConstant,
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
        LibGame.startGame({
            merkleRoot: merkleRoot,
            initialPrice: initialPrice,
            minPrice: minPrice,
            wadFactor: wadFactor,
            wadDurationRoot: wadDurationRoot,
            wadDurationScale: wadDurationScale,
            wadDurationConstant: wadDurationConstant,
            crossWordRewardFraction: crossWordRewardFraction,
            bonusDistance: bonusDistance,
            numDrawLetters: numDrawLetters
        });
    }

    function writeInitialWordChecked(Letter[] memory initialWord) private {
        uint256 wordLength = initialWord.length;
        if (wordLength > MAX_WORD_LENGTH) {
            revert WordTooLong();
        }
        int32 xOffset = int32(uint32(wordLength)) / 2;
        for (uint256 i = 0; i < initialWord.length; i++) {
            Coord memory coord = Coord({ x: int32(uint32(i)) - xOffset, y: 0 });
            LibTile.setTile({ coord: coord, letter: initialWord[i], player: address(0) });
        }
    }
}

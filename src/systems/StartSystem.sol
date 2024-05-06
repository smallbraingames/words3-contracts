// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { Letter, Status } from "codegen/common.sol";

import { Coord } from "common/Coord.sol";
import { LibGame } from "libraries/LibGame.sol";
import { LibTile } from "libraries/LibTile.sol";

contract StartSystem is System {
    error GameAlreadyStarted();

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
        if (LibGame.getGameStatus() != Status.NOT_STARTED) {
            revert GameAlreadyStarted();
        }
        for (uint256 i = 0; i < initialWord.length; i++) {
            Coord memory coord = Coord({ x: int32(uint32(i)), y: 0 });
            LibTile.setTile({ coord: coord, letter: initialWord[i], player: address(0) });
        }
    }
}

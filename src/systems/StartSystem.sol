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
        int256 vrgdaTargetPrice,
        int256 vrgdaPriceDecay,
        int256 vrgdaPerDayInitial,
        int256 vrgdaPower,
        uint32 crossWordRewardFraction,
        uint16 bonusDistance,
        uint8 numDrawLetters
    )
        public
    {
        writeInitialWordChecked({ initialWord: initialWord });
        LibGame.startGame({
            merkleRoot: merkleRoot,
            vrgdaTargetPrice: vrgdaTargetPrice,
            vrgdaPriceDecay: vrgdaPriceDecay,
            vrgdaPerDayInitial: vrgdaPerDayInitial,
            vrgdaPower: vrgdaPower,
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

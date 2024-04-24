// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { Letter, Status } from "codegen/common.sol";
import { TileLetter, TilePlayer } from "codegen/index.sol";
import { Coord } from "common/Coord.sol";
import { LibGame } from "libraries/LibGame.sol";

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
        uint16 bonusDistance
    )
        public
    {
        checkStartInputs(initialWord);
        LibGame.startGame({
            merkleRoot: merkleRoot,
            vrgdaTargetPrice: vrgdaTargetPrice,
            vrgdaPriceDecay: vrgdaPriceDecay,
            vrgdaPerDayInitial: vrgdaPerDayInitial,
            vrgdaPower: vrgdaPower,
            crossWordRewardFraction: crossWordRewardFraction,
            bonusDistance: bonusDistance
        });
    }

    function checkStartInputs(Letter[] memory initialWord) private {
        if (LibGame.getGameStatus() != Status.NOT_STARTED) {
            revert GameAlreadyStarted();
        }
        for (uint256 i = 0; i < initialWord.length; i++) {
            Coord memory coord = Coord({ x: int32(uint32(i)), y: 0 });
            TileLetter.set(coord.x, coord.y, initialWord[i]);
            TilePlayer.set(coord.x, coord.y, address(0));
        }
    }
}

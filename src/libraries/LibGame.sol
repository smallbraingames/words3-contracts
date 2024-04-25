// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Status } from "codegen/common.sol";
import { GameConfig, MerkleRootConfig, VRGDAConfig } from "codegen/index.sol";

library LibGame {
    function getGameStatus() internal view returns (Status) {
        return GameConfig.getStatus();
    }

    function canPlay() internal view returns (bool) {
        return getGameStatus() == Status.STARTED;
    }

    function startGame(
        bytes32 merkleRoot,
        int256 vrgdaTargetPrice,
        int256 vrgdaPriceDecay,
        int256 vrgdaPerDayInitial,
        int256 vrgdaPower,
        uint32 crossWordRewardFraction,
        uint16 bonusDistance,
        uint8 numDrawLetters
    )
        internal
    {
        GameConfig.set({
            status: Status.STARTED,
            crossWordRewardFraction: crossWordRewardFraction,
            bonusDistance: bonusDistance,
            numDrawLetters: numDrawLetters
        });
        MerkleRootConfig.set({ value: merkleRoot });
        VRGDAConfig.set({
            startTime: block.timestamp,
            targetPrice: vrgdaTargetPrice,
            priceDecay: vrgdaPriceDecay,
            perDayInitial: vrgdaPerDayInitial,
            power: vrgdaPower
        });
    }
}

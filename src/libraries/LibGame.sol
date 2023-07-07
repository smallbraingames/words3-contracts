// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Status} from "codegen/Types.sol";
import {GameConfig, MerkleRootConfig, GameConfigData, VRGDAConfig, VRGDAConfigData} from "codegen/Tables.sol";

library LibGame {
    function getGameStatus() internal view returns (Status) {
        return GameConfig.getStatus();
    }

    function incrementWordsPlayed() internal {
        GameConfig.setWordsPlayed(GameConfig.getWordsPlayed() + 1);
    }

    function canPlay() internal view returns (bool) {
        return getGameStatus() == Status.STARTED && GameConfig.getWordsPlayed() < GameConfig.getMaxWords();
    }

    function startGame(
        uint16 maxWords,
        bytes32 merkleRoot,
        int256 vrgdaTargetPrice,
        int256 vrgdaPriceDecay,
        int256 vrgdaPerDay,
        uint32 crossWordRewardFraction
    ) internal {
        GameConfig.set(
            GameConfigData({
                status: Status.STARTED,
                maxWords: maxWords,
                wordsPlayed: 0,
                crossWordRewardFraction: crossWordRewardFraction
            })
        );
        MerkleRootConfig.set(merkleRoot);
        VRGDAConfig.set(
            VRGDAConfigData({
                startTime: block.timestamp,
                targetPrice: vrgdaTargetPrice,
                priceDecay: vrgdaPriceDecay,
                perDay: vrgdaPerDay
            })
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Status} from "codegen/Types.sol";
import {GameConfig, MerkleRootConfig, GameConfigData, VRGDAConfig, VRGDAConfigData} from "codegen/Tables.sol";

library LibGame {
    function getGameStatus() internal view returns (Status) {
        return GameConfig.get().status;
    }

    function startGame(
        uint16 maxWords,
        bytes32 merkleRoot,
        int256 vrgdaTargetPrice,
        int256 vrgdaPriceDecay,
        int256 vrgdaPerDay
    ) internal {
        GameConfig.set(GameConfigData({status: Status.STARTED, maxWords: maxWords, wordsPlayed: 0}));
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

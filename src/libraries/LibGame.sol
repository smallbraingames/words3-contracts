// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Status } from "codegen/common.sol";
import { DrawLastSold, GameConfig, MerkleRootConfig, PriceConfig } from "codegen/index.sol";

library LibGame {
    function getGameStatus() internal view returns (Status) {
        return GameConfig.getStatus();
    }

    function canPlay() internal view returns (bool) {
        return getGameStatus() == Status.STARTED;
    }

    function startGame(
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
        internal
    {
        GameConfig.set({
            status: Status.STARTED,
            crossWordRewardFraction: crossWordRewardFraction,
            bonusDistance: bonusDistance,
            numDrawLetters: numDrawLetters
        });
        MerkleRootConfig.set({ value: merkleRoot });
        DrawLastSold.set({ price: initialPrice, blockNumber: block.number });
        PriceConfig.set({
            minPrice: minPrice,
            wadFactor: wadFactor,
            wadDurationRoot: wadDurationRoot,
            wadDurationScale: wadDurationScale,
            wadDurationConstant: wadDurationConstant
        });
    }
}

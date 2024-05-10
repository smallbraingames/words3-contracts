// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Status } from "codegen/common.sol";
import {
    ClaimRestrictionConfig,
    DrawLastSold,
    FeeConfig,
    FeeConfigData,
    GameConfig,
    MerkleRootConfig,
    PriceConfig,
    PriceConfigData
} from "codegen/index.sol";

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
        uint256 claimRestrictionDurationBlocks,
        PriceConfigData memory priceConfig,
        FeeConfigData memory feeConfig,
        uint32 crossWordRewardFraction,
        uint16 bonusDistance,
        uint8 numDrawLetters
    )
        internal
    {
        uint256 blockNumber = block.number;
        ClaimRestrictionConfig.set({ claimRestrictionBlock: blockNumber + claimRestrictionDurationBlocks });
        GameConfig.set({
            status: Status.STARTED,
            crossWordRewardFraction: crossWordRewardFraction,
            bonusDistance: bonusDistance,
            numDrawLetters: numDrawLetters
        });
        MerkleRootConfig.set({ value: merkleRoot });
        DrawLastSold.set({ price: initialPrice, blockNumber: blockNumber });
        PriceConfig.set(priceConfig);
        FeeConfig.set(feeConfig);
    }
}

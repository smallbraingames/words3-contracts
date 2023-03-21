// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0;

import {addressToEntity} from "solecs/utils.sol";
import {IComponent} from "solecs/interfaces/IComponent.sol";

import {RewardsComponent} from "components/RewardsComponent.sol";
import {ScoreComponent} from "components/ScoreComponent.sol";
import {SpentComponent} from "components/SpentComponent.sol";

library LibPlayer {
    function incrementRewards(
        address player,
        uint256 increment,
        RewardsComponent rewardsComponent
    ) internal {
        uint256 playerEntity = getPlayerEntity(player);
        if (rewardsComponent.has(playerEntity)) {
            uint256 previous = rewardsComponent.getValue(playerEntity);
            rewardsComponent.set(playerEntity, previous + increment);
        } else {
            rewardsComponent.set(playerEntity, increment);
        }
    }

    function incrementSpent(
        address player,
        uint256 increment,
        SpentComponent spentComponent
    ) internal {
        uint256 playerEntity = getPlayerEntity(player);
        if (spentComponent.has(playerEntity)) {
            uint256 previous = spentComponent.getValue(playerEntity);
            spentComponent.set(playerEntity, previous + increment);
        } else {
            spentComponent.set(playerEntity, increment);
        }
    }

    function incrementScore(
        address player,
        uint32 increment,
        ScoreComponent scoreComponent
    ) internal {
        uint256 playerEntity = getPlayerEntity(player);
        if (scoreComponent.has(playerEntity)) {
            uint32 previous = scoreComponent.getValue(playerEntity);
            scoreComponent.set(playerEntity, previous + increment);
        } else {
            scoreComponent.set(playerEntity, increment);
        }
    }

    function getPlayerEntity(address player) internal pure returns (uint256) {
        return addressToEntity(player);
    }
}

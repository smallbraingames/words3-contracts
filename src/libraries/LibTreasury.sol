// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0;

import {TreasuryTable} from "codegen/Tables.sol";

bytes32 constant SingletonKey = bytes32(uint256(0x060D));

library LibTreasury {
    function incrementTreasury(
        uint256 msgValue,
        uint256 rewardFraction
    ) internal {
        uint256 increment = (msgValue * (rewardFraction - 1)) / rewardFraction;
        uint256 treasury = TreasuryTable.get(SingletonKey);
        uint256 incremented = treasury + increment;
        TreasuryTable.set(SingletonKey, incremented);
    }
}

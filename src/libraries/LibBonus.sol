// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {BonusType} from "codegen/common.sol";

import {Bonus} from "common/Bonus.sol";
import {Coord} from "common/Coord.sol";
import {BONUS_DISTANCE} from "common/Constants.sol";

library LibBonus {
    function isBonusTile(Coord memory coord) internal pure returns (bool) {
        int32 x = abs(coord.x);
        int32 y = abs(coord.y);
        return ((x - y) % int32(uint32(BONUS_DISTANCE))) == 0;
    }

    /// @notice Assumes that isBonusTile is called to check if the tile is a bonus tile first
    function getTileBonus(Coord memory coord) internal pure returns (Bonus memory) {
        uint256 n = uint256(keccak256(abi.encodePacked(coord.x, coord.y)));
        BonusType bonusType = n % 24 == 0 ? BonusType.MULTIPLY_WORD : BonusType.MULTIPLY_LETTER;
        n = n % 10;
        uint32 bonusValue = 2;
        if (n < 1) {
            bonusValue = 5;
        } else if (n < 3) {
            bonusValue = 4;
        } else if (n < 6) {
            bonusValue = 3;
        }
        return Bonus({bonusValue: bonusValue, bonusType: bonusType});
    }

    function abs(int32 x) private pure returns (int32) {
        if (x < 0) {
            return -x;
        }
        return x;
    }

    function max(int32 x, int32 y) private pure returns (int32) {
        if (x > y) {
            return x;
        }
        return y;
    }
}

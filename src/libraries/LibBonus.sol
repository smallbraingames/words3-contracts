// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { BonusType } from "codegen/common.sol";
import { Bonus } from "common/Bonus.sol";
import { Coord } from "common/Coord.sol";

library LibBonus {
    function isBonusTile(Coord memory coord, uint16 bonusDistance) internal pure returns (bool) {
        int32 x = abs(coord.x);
        int32 y = abs(coord.y);
        return ((x + y) % int32(uint32(bonusDistance))) == 0;
    }

    /// @notice Assumes that isBonusTile is called to check if the tile is a bonus tile first
    function getTileBonus(Coord memory coord) internal pure returns (Bonus memory) {
        uint256 n = uint256(keccak256(abi.encodePacked(coord.x, coord.y)));
        int32 dist = abs(coord.x) + abs(coord.y);

        uint256 bonusTypeThreshold = 3500 + min(uint256(uint32(dist)) * 5, 50_000);
        BonusType bonusType = n % 100_000 < bonusTypeThreshold ? BonusType.MULTIPLY_WORD : BonusType.MULTIPLY_LETTER;

        n = n % 100;
        uint32 bonusValue = 2;
        if (n < 1) {
            bonusValue = 5;
        } else if (n < 3) {
            bonusValue = 4;
        } else if (n < 10) {
            bonusValue = 3;
        }

        return Bonus({ bonusValue: bonusValue, bonusType: bonusType });
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

    function min(uint256 x, uint256 y) private pure returns (uint256) {
        if (x < y) {
            return x;
        }
        return y;
    }
}

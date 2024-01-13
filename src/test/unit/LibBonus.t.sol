// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { BonusType } from "codegen/common.sol";
import { IWorld } from "codegen/world/IWorld.sol";

import { Bonus } from "common/Bonus.sol";

import { BONUS_DISTANCE } from "common/Constants.sol";
import { Coord } from "common/Coord.sol";
import { LibBonus } from "libraries/LibBonus.sol";

import { Words3Test } from "../Words3Test.t.sol";
import "forge-std/Test.sol";

contract LibBonusTest is Words3Test {
    function testIsBonusTile() public {
        int32 bonusDistance = int32(uint32(BONUS_DISTANCE));
        // Bonus tiles
        Coord memory coord = Coord({ x: 0, y: 0 });
        Coord memory coord2 = Coord({ x: 0, y: bonusDistance });
        Coord memory coord3 = Coord({ x: 0, y: bonusDistance * 2 });
        Coord memory coord4 = Coord({ x: -bonusDistance - 12, y: 12 });

        // Not bonus tiles
        Coord memory coord5 = Coord({ x: 0, y: bonusDistance * 3 + 1 });
        Coord memory coord6 = Coord({ x: 0, y: bonusDistance * 4 + 1 });

        assertTrue(LibBonus.isBonusTile(coord));
        assertTrue(LibBonus.isBonusTile(coord2));
        assertTrue(LibBonus.isBonusTile(coord3));
        assertTrue(LibBonus.isBonusTile(coord4));

        assertFalse(LibBonus.isBonusTile(coord5));
        assertFalse(LibBonus.isBonusTile(coord6));
    }

    function testFuzzIsBonusTile(int32 x, int32 y) public {
        vm.assume(x >= -1e9 && x <= 1e9);
        vm.assume(y >= -1e9 && y <= 1e9);
        Coord memory coord = Coord({ x: x, y: y });
        bool isBonus = LibBonus.isBonusTile(coord);
        if (isBonus) {
            int32 absX = x < 0 ? -x : x;
            int32 absY = y < 0 ? -y : y;
            assertTrue(absX >= 0);
            assertTrue(absY >= 0);
            assertEq((absX - absY) % int32(uint32(BONUS_DISTANCE)), 0);
        }
    }

    function testFuzzIsBonusTileCross(int32 bonusDistanceMultiple, int32 diff) public {
        int32 bonusDistance = int32(uint32(BONUS_DISTANCE));

        vm.assume(bonusDistance > 1);
        vm.assume(bonusDistanceMultiple >= 0 && bonusDistanceMultiple <= 1e3);
        vm.assume(diff >= 0 && diff <= 1e8);

        // Bonus Tiles
        Coord memory coord = Coord({ x: diff, y: bonusDistance * bonusDistanceMultiple + diff });
        Coord memory coord2 = Coord({ x: -diff, y: bonusDistance * bonusDistanceMultiple + diff });
        Coord memory coord3 = Coord({ x: bonusDistance * bonusDistanceMultiple, y: 0 });

        // Not bonus tiles
        Coord memory coord4 = Coord({ x: bonusDistance * bonusDistanceMultiple + diff, y: diff + 1 });
        Coord memory coord5 = Coord({ x: bonusDistance * bonusDistanceMultiple + diff, y: -diff - 1 });

        assertTrue(LibBonus.isBonusTile(coord));
        assertTrue(LibBonus.isBonusTile(coord2));
        assertTrue(LibBonus.isBonusTile(coord3));

        assertFalse(LibBonus.isBonusTile(coord4));
        assertFalse(LibBonus.isBonusTile(coord5));
    }

    function testFuzzGetTileBonusWithinBounds(int32 x, int32 y) public {
        vm.assume(x >= -1e9 && x <= 1e9);
        vm.assume(y >= -1e9 && y <= 1e9);
        vm.assume(LibBonus.isBonusTile(Coord({ x: x, y: y })));
        Bonus memory bonus = LibBonus.getTileBonus(Coord({ x: x, y: y }));
        assertTrue(bonus.bonusValue >= 2 && bonus.bonusValue <= 5);
        assertTrue(bonus.bonusType == BonusType.MULTIPLY_LETTER || bonus.bonusType == BonusType.MULTIPLY_WORD);
    }
}

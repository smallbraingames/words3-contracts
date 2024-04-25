// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;
/* solhint-disable no-global-import */
/* solhint-disable func-name-mixedcase */

import { Words3Test } from "../Words3Test.t.sol";
import { BonusType } from "codegen/common.sol";
import { Bonus } from "common/Bonus.sol";
import { Coord } from "common/Coord.sol";
import "forge-std/Test.sol";
import { LibBonus } from "libraries/LibBonus.sol";

contract LibBonusTest is Words3Test {
    function test_IsBonusTile() public {
        int32 bonusDistance = int32(uint32(8));
        // Bonus tiles
        Coord memory coord = Coord({ x: 0, y: 0 });
        Coord memory coord2 = Coord({ x: 0, y: bonusDistance });
        Coord memory coord3 = Coord({ x: 0, y: bonusDistance * 2 });
        Coord memory coord4 = Coord({ x: -bonusDistance - 12, y: 12 });

        // Not bonus tiles
        Coord memory coord5 = Coord({ x: 0, y: bonusDistance * 3 + 1 });
        Coord memory coord6 = Coord({ x: 0, y: bonusDistance * 4 + 1 });

        assertTrue(LibBonus.isBonusTile(coord, 8));
        assertTrue(LibBonus.isBonusTile(coord2, 8));
        assertTrue(LibBonus.isBonusTile(coord3, 8));
        assertTrue(LibBonus.isBonusTile(coord4, 8));

        assertFalse(LibBonus.isBonusTile(coord5, 8));
        assertFalse(LibBonus.isBonusTile(coord6, 8));
    }

    function testFuzz_IsBonusTile(int32 x, int32 y) public {
        uint16 bonusDistance = 3;
        vm.assume(x >= -1e9 && x <= 1e9);
        vm.assume(y >= -1e9 && y <= 1e9);
        Coord memory coord = Coord({ x: x, y: y });
        bool isBonus = LibBonus.isBonusTile(coord, bonusDistance);
        if (isBonus) {
            int32 absX = x < 0 ? -x : x;
            int32 absY = y < 0 ? -y : y;
            assertTrue(absX >= 0);
            assertTrue(absY >= 0);
            assertEq((absX - absY) % int32(uint32(bonusDistance)), 0);
        }
    }

    function testFuzz_IsBonusTileCross(int32 bonusDistanceMultiple, int32 diff) public {
        int32 bonusDistance = int32(uint32(6));

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

        assertTrue(LibBonus.isBonusTile(coord, 6));
        assertTrue(LibBonus.isBonusTile(coord2, 6));
        assertTrue(LibBonus.isBonusTile(coord3, 6));

        assertFalse(LibBonus.isBonusTile(coord4, 6));
        assertFalse(LibBonus.isBonusTile(coord5, 6));
    }

    function testFuzz_GetTileBonusWithinBounds(int32 x, int32 y, uint16 bonusDistance) public {
        vm.assume(x >= -1e9 && x <= 1e9);
        vm.assume(y >= -1e9 && y <= 1e9);
        bonusDistance = uint16(bound(bonusDistance, 1, 1000));
        vm.assume(LibBonus.isBonusTile(Coord({ x: x, y: y }), bonusDistance));
        Bonus memory bonus = LibBonus.getTileBonus(Coord({ x: x, y: y }));
        assertTrue(bonus.bonusValue >= 2 && bonus.bonusValue <= 5);
        assertTrue(bonus.bonusType == BonusType.MULTIPLY_LETTER || bonus.bonusType == BonusType.MULTIPLY_WORD);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IWorld} from "codegen/world/IWorld.sol";
import {TileTable, TileTableData} from "codegen/Tables.sol";
import {Letter} from "codegen/Types.sol";

import {Coord} from "common/Coord.sol";

import "forge-std/Test.sol";
import {MudV2Test} from "@latticexyz/std-contracts/src/test/MudV2Test.t.sol";
import {getKeysWithValue} from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";

contract SetupBoardTest is MudV2Test {
    IWorld world;

    function setUp() public override {
        super.setUp();
        world = IWorld(worldAddress);
    }

    function testWorldExists() public {
        uint256 codeSize;
        address addr = worldAddress;
        assembly {
            codeSize := extcodesize(addr)
        }
        assertTrue(codeSize > 0);
    }

    function testFirstWord() public {
        world.playFirstWord();
        TileTableData memory firstTile = TileTable.get(world, 0, 0);
        assertEq(uint8(firstTile.letter), uint8(Letter.I));
        TileTableData memory thirdTile = TileTable.get(world, 2, 0);
        assertEq(uint8(thirdTile.letter), uint8(Letter.F));
    }
}

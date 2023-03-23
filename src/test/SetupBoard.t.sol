// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "std-contracts/test/MudTest.t.sol";
import {Coord} from "std-contracts/components/CoordComponent.sol";

import {Deploy} from "./Deploy.sol";
import {Letter} from "common/Letter.sol";
import {TileComponent, ID as TileComponentID} from "components/TileComponent.sol";
import {SetupBoardSystem, ID as SetupBoardSystemID} from "systems/SetupBoardSystem.sol";
import {LibTile} from "libraries/LibTile.sol";

contract SetupBoardTest is MudTest {
    constructor() MudTest(new Deploy()) {}

    function testSetupBoard() public {
        SetupBoardSystem setupBoardSystem = SetupBoardSystem(
            system(SetupBoardSystemID)
        );
        TileComponent tileComponent = TileComponent(
            getAddressById(components, TileComponentID)
        );
        setupBoardSystem.executeTyped();
        assertEq(
            uint8(
                LibTile
                    .getTileAtCoord(Coord({x: 0, y: 0}), tileComponent)
                    .letter
            ),
            uint8(Letter.I)
        );
        assertEq(
            uint8(
                LibTile
                    .getTileAtCoord(Coord({x: 4, y: 0}), tileComponent)
                    .letter
            ),
            uint8(Letter.N)
        );
    }
}

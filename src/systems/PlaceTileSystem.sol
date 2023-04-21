// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Letter} from "codegen/Types.sol";
import {TileTableData} from "codegen/Tables.sol";

import {Coord} from "common/Coord.sol";
import {LibPrice} from "libraries/LibPrice.sol";
import {LibTile} from "libraries/LibTile.sol";

import {System} from "@latticexyz/world/src/System.sol";

contract PlaceTileSystem is System {
    function placeTile(
        Coord memory coord,
        address player,
        Letter letter,
        int256 daysSinceStart
    ) public {
        LibPrice.incrementLetterWeight(letter, daysSinceStart);
        LibTile.setTileAtCoord(
            coord,
            TileTableData({player: player, letter: letter})
        );
    }
}

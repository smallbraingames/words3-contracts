// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0;

import {Letter} from "codegen/Types.sol";
import {TileTable, TileTableData} from "codegen/Tables.sol";

import {Coord} from "common/Coord.sol";

library LibTile {
    function setTileAtCoord(
        Coord memory coord,
        TileTableData memory tile
    ) internal {
        TileTable.set(coord.x, coord.y, tile);
    }

    function getTileAtCoord(
        Coord memory coord
    ) internal view returns (TileTableData memory) {
        return TileTable.get(coord.x, coord.y);
    }

    function hasTileAtCoord(Coord memory coord) internal view returns (bool) {
        return TileTable.get(coord.x, coord.y).letter != Letter.EMPTY;
    }
}

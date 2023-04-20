// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0;

import {Coord} from "std-contracts/components/CoordComponent.sol";
import {TileComponent} from "components/TileComponent.sol";

import {Tile} from "common/Tile.sol";

library LibTile {
    function setTileAtCoord(
        Coord memory coord,
        Tile memory tile,
        TileComponent tileComponent
    ) internal {
        tileComponent.set(getTileEntityAtCoord(coord), tile);
    }

    function getTileAtCoord(
        Coord memory coord,
        TileComponent tileComponent
    ) internal view returns (Tile memory) {
        return tileComponent.getValue(getTileEntityAtCoord(coord));
    }

    function hasTileAtCoord(
        Coord memory coord,
        TileComponent tileComponent
    ) internal view returns (bool) {
        return tileComponent.has(getTileEntityAtCoord(coord));
    }

    function getTileEntityAtCoord(
        Coord memory coord
    ) internal pure returns (uint256) {
        return
            uint256(
                bytes32(
                    bytes.concat(
                        bytes4(uint32(coord.x)),
                        bytes4(uint32(coord.y)),
                        // All non-tile entities are players (address entities)
                        // This prevents collisions between entities
                        bytes20(type(uint160).max)
                    )
                )
            );
    }
}

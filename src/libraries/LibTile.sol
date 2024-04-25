// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Letter } from "codegen/common.sol";
import { TileLetter, TilePlayer } from "codegen/index.sol";
import { Coord } from "common/Coord.sol";

library LibTile {
    function setTile(Coord memory coord, Letter letter, address player) internal {
        TileLetter.set({ x: coord.x, y: coord.y, value: letter });
        TilePlayer.set({ x: coord.x, y: coord.y, value: player });
    }

    function getLetter(Coord memory coord) internal view returns (Letter) {
        return TileLetter.get({ x: coord.x, y: coord.y });
    }

    function getPlayer(Coord memory coord) internal view returns (address) {
        return TilePlayer.get({ x: coord.x, y: coord.y });
    }
}

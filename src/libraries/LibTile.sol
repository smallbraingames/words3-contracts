// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Direction, Letter, BonusType} from "codegen/common.sol";
import {TileLetter, TilePlayer, LetterCount} from "codegen/index.sol";

import {Coord} from "common/Coord.sol";

library LibTile {
    function setTile(Coord memory coord, Letter letter, address player) internal {
        TileLetter.set(coord.x, coord.y, letter);
        TilePlayer.set(coord.x, coord.y, player);
        LetterCount.set(letter, LetterCount.get(letter) + 1);
    }

    function getLetter(Coord memory coord) internal view returns (Letter) {
        return TileLetter.get(coord.x, coord.y);
    }

    function getPlayer(Coord memory coord) internal view returns (address) {
        return TilePlayer.get(coord.x, coord.y);
    }
}

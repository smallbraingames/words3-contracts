// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {Letter} from "./Letter.sol";

struct Tile {
    address player;
    Letter letter;
}

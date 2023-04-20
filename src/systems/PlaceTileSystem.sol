// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Coord} from "common/Coord.sol";
import {Letter} from "common/Letter.sol";
import {Tile} from "common/Tile.sol";
import {LibPrice} from "libraries/LibPrice.sol";
import {LibTile} from "libraries/LibTile.sol";

import {System, IWorld} from "solecs/System.sol";
import {getAddressById} from "solecs/utils.sol";

uint256 constant ID = uint256(keccak256("system.PlaceTile"));

contract PlaceTileSystem is System {
    constructor(
        IWorld _world,
        address _components
    ) System(_world, _components) {}

    function execute(bytes memory arguments) public returns (bytes memory) {
        (
            Coord memory coord,
            address player,
            Letter letter,
            int256 daysSinceStart
        ) = abi.decode(arguments, (Coord, address, Letter, int256));
        TileComponent tileComponent = TileComponent(
            getAddressById(components, TileComponentID)
        );
        LetterWeightComponent letterWeightComponent = LetterWeightComponent(
            getAddressById(components, LetterWeightComponentID)
        );
        LibPrice.incrementLetterWeight(
            letter,
            daysSinceStart,
            letterWeightComponent
        );
        LibTile.setTileAtCoord(
            coord,
            Tile({player: player, letter: letter}),
            tileComponent
        );
    }

    function executeTyped(
        Coord memory coord,
        address player,
        Letter letter,
        int256 daysSinceStart
    ) public returns (bytes memory) {
        return execute(abi.encode(coord, player, letter, daysSinceStart));
    }
}

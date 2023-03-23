// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0;

import {BareComponent, LibTypes} from "solecs/BareComponent.sol";
import {split} from "solecs/utils.sol";

import {Letter} from "common/Letter.sol";
import {Tile} from "common/Tile.sol";

uint256 constant ID = uint256(keccak256("component.Tile"));

contract TileComponent is BareComponent {
    constructor(address world) BareComponent(world, ID) {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        keys = new string[](1);
        values = new LibTypes.SchemaValue[](1);

        keys[0] = "value";
        values[0] = LibTypes.SchemaValue.UINT256;
    }

    function set(uint256 entity, Tile memory value) public {
        set(
            entity,
            abi.encode(
                bytes32(
                    bytes.concat(
                        bytes20(value.player),
                        bytes1(uint8(value.letter))
                    )
                )
            )
        );
    }

    function getValue(uint256 entity) public view returns (Tile memory) {
        bytes memory rawData = getRawValue(entity);
        uint8[] memory lengths = new uint8[](2);
        lengths[0] = 20;
        lengths[1] = 1;
        bytes[] memory unpacked = split(rawData, lengths);
        address player = address(bytes20(unpacked[0]));
        Letter letter = Letter(uint8(bytes1(unpacked[1])));
        return Tile(player, letter);
    }
}

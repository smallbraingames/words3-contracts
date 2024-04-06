// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

// Import store internals

import { Bytes } from "@latticexyz/store/src/Bytes.sol";

import { EncodedLengths, EncodedLengthsLib } from "@latticexyz/store/src/EncodedLengths.sol";
import { FieldLayout } from "@latticexyz/store/src/FieldLayout.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { Memory } from "@latticexyz/store/src/Memory.sol";

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { Schema } from "@latticexyz/store/src/Schema.sol";
import { SliceLib } from "@latticexyz/store/src/Slice.sol";
import { StoreCore } from "@latticexyz/store/src/StoreCore.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

import { EncodeArray } from "@latticexyz/store/src/tightcoder/EncodeArray.sol";

struct PointsResultData {
    address player;
    int16 pointsId;
    uint32 points;
}

library PointsResult {
    // Hex below is the result of `WorldResourceIdLib.encode({ namespace: "", name: "PointsResult", typeId:
    // RESOURCE_OFFCHAIN_TABLE });`
    ResourceId constant _tableId = ResourceId.wrap(0x6f740000000000000000000000000000506f696e7473526573756c7400000000);

    FieldLayout constant _fieldLayout =
        FieldLayout.wrap(0x001a030014020400000000000000000000000000000000000000000000000000);

    // Hex-encoded key schema of (uint256)
    Schema constant _keySchema = Schema.wrap(0x002001001f000000000000000000000000000000000000000000000000000000);
    // Hex-encoded value schema of (address, int16, uint32)
    Schema constant _valueSchema = Schema.wrap(0x001a030061210300000000000000000000000000000000000000000000000000);

    /**
     * @notice Get the table's key field names.
     * @return keyNames An array of strings with the names of key fields.
     */
    function getKeyNames() internal pure returns (string[] memory keyNames) {
        keyNames = new string[](1);
        keyNames[0] = "id";
    }

    /**
     * @notice Get the table's value field names.
     * @return fieldNames An array of strings with the names of value fields.
     */
    function getFieldNames() internal pure returns (string[] memory fieldNames) {
        fieldNames = new string[](3);
        fieldNames[0] = "player";
        fieldNames[1] = "pointsId";
        fieldNames[2] = "points";
    }

    /**
     * @notice Register the table with its config.
     */
    function register() internal {
        StoreSwitch.registerTable(_tableId, _fieldLayout, _keySchema, _valueSchema, getKeyNames(), getFieldNames());
    }

    /**
     * @notice Register the table with its config.
     */
    function _register() internal {
        StoreCore.registerTable(_tableId, _fieldLayout, _keySchema, _valueSchema, getKeyNames(), getFieldNames());
    }

    /**
     * @notice Set player.
     */
    function setPlayer(uint256 id, address player) internal {
        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = bytes32(uint256(id));

        StoreSwitch.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((player)), _fieldLayout);
    }

    /**
     * @notice Set player.
     */
    function _setPlayer(uint256 id, address player) internal {
        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = bytes32(uint256(id));

        StoreCore.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((player)), _fieldLayout);
    }

    /**
     * @notice Set pointsId.
     */
    function setPointsId(uint256 id, int16 pointsId) internal {
        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = bytes32(uint256(id));

        StoreSwitch.setStaticField(_tableId, _keyTuple, 1, abi.encodePacked((pointsId)), _fieldLayout);
    }

    /**
     * @notice Set pointsId.
     */
    function _setPointsId(uint256 id, int16 pointsId) internal {
        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = bytes32(uint256(id));

        StoreCore.setStaticField(_tableId, _keyTuple, 1, abi.encodePacked((pointsId)), _fieldLayout);
    }

    /**
     * @notice Set points.
     */
    function setPoints(uint256 id, uint32 points) internal {
        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = bytes32(uint256(id));

        StoreSwitch.setStaticField(_tableId, _keyTuple, 2, abi.encodePacked((points)), _fieldLayout);
    }

    /**
     * @notice Set points.
     */
    function _setPoints(uint256 id, uint32 points) internal {
        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = bytes32(uint256(id));

        StoreCore.setStaticField(_tableId, _keyTuple, 2, abi.encodePacked((points)), _fieldLayout);
    }

    /**
     * @notice Set the full data using individual values.
     */
    function set(uint256 id, address player, int16 pointsId, uint32 points) internal {
        bytes memory _staticData = encodeStatic(player, pointsId, points);

        EncodedLengths _encodedLengths;
        bytes memory _dynamicData;

        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = bytes32(uint256(id));

        StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
    }

    /**
     * @notice Set the full data using individual values.
     */
    function _set(uint256 id, address player, int16 pointsId, uint32 points) internal {
        bytes memory _staticData = encodeStatic(player, pointsId, points);

        EncodedLengths _encodedLengths;
        bytes memory _dynamicData;

        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = bytes32(uint256(id));

        StoreCore.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData, _fieldLayout);
    }

    /**
     * @notice Set the full data using the data struct.
     */
    function set(uint256 id, PointsResultData memory _table) internal {
        bytes memory _staticData = encodeStatic(_table.player, _table.pointsId, _table.points);

        EncodedLengths _encodedLengths;
        bytes memory _dynamicData;

        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = bytes32(uint256(id));

        StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
    }

    /**
     * @notice Set the full data using the data struct.
     */
    function _set(uint256 id, PointsResultData memory _table) internal {
        bytes memory _staticData = encodeStatic(_table.player, _table.pointsId, _table.points);

        EncodedLengths _encodedLengths;
        bytes memory _dynamicData;

        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = bytes32(uint256(id));

        StoreCore.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData, _fieldLayout);
    }

    /**
     * @notice Decode the tightly packed blob of static data using this table's field layout.
     */
    function decodeStatic(bytes memory _blob) internal pure returns (address player, int16 pointsId, uint32 points) {
        player = (address(Bytes.getBytes20(_blob, 0)));

        pointsId = (int16(uint16(Bytes.getBytes2(_blob, 20))));

        points = (uint32(Bytes.getBytes4(_blob, 22)));
    }

    /**
     * @notice Decode the tightly packed blobs using this table's field layout.
     * @param _staticData Tightly packed static fields.
     *
     *
     */
    function decode(
        bytes memory _staticData,
        EncodedLengths,
        bytes memory
    )
        internal
        pure
        returns (PointsResultData memory _table)
    {
        (_table.player, _table.pointsId, _table.points) = decodeStatic(_staticData);
    }

    /**
     * @notice Delete all data for given keys.
     */
    function deleteRecord(uint256 id) internal {
        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = bytes32(uint256(id));

        StoreSwitch.deleteRecord(_tableId, _keyTuple);
    }

    /**
     * @notice Delete all data for given keys.
     */
    function _deleteRecord(uint256 id) internal {
        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = bytes32(uint256(id));

        StoreCore.deleteRecord(_tableId, _keyTuple, _fieldLayout);
    }

    /**
     * @notice Tightly pack static (fixed length) data using this table's schema.
     * @return The static data, encoded into a sequence of bytes.
     */
    function encodeStatic(address player, int16 pointsId, uint32 points) internal pure returns (bytes memory) {
        return abi.encodePacked(player, pointsId, points);
    }

    /**
     * @notice Encode all of a record's fields.
     * @return The static (fixed length) data, encoded into a sequence of bytes.
     * @return The lengths of the dynamic fields (packed into a single bytes32 value).
     * @return The dynamic (variable length) data, encoded into a sequence of bytes.
     */
    function encode(
        address player,
        int16 pointsId,
        uint32 points
    )
        internal
        pure
        returns (bytes memory, EncodedLengths, bytes memory)
    {
        bytes memory _staticData = encodeStatic(player, pointsId, points);

        EncodedLengths _encodedLengths;
        bytes memory _dynamicData;

        return (_staticData, _encodedLengths, _dynamicData);
    }

    /**
     * @notice Encode keys as a bytes32 array using this table's field layout.
     */
    function encodeKeyTuple(uint256 id) internal pure returns (bytes32[] memory) {
        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = bytes32(uint256(id));

        return _keyTuple;
    }
}

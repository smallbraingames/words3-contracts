// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

/* Autogenerated file. Do not edit manually. */

// Import schema type
import { SchemaType } from "@latticexyz/schema-type/src/solidity/SchemaType.sol";

// Import store internals

import { Bytes } from "@latticexyz/store/src/Bytes.sol";

import { FieldLayout, FieldLayoutLib } from "@latticexyz/store/src/FieldLayout.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { Memory } from "@latticexyz/store/src/Memory.sol";

import { PackedCounter, PackedCounterLib } from "@latticexyz/store/src/PackedCounter.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { Schema, SchemaLib } from "@latticexyz/store/src/Schema.sol";
import { SliceLib } from "@latticexyz/store/src/Slice.sol";
import { StoreCore } from "@latticexyz/store/src/StoreCore.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

import { RESOURCE_OFFCHAIN_TABLE, RESOURCE_TABLE } from "@latticexyz/store/src/storeResourceTypes.sol";
import { EncodeArray } from "@latticexyz/store/src/tightcoder/EncodeArray.sol";

ResourceId constant _tableId =
    ResourceId.wrap(bytes32(abi.encodePacked(RESOURCE_OFFCHAIN_TABLE, bytes14(""), bytes16("SpentMove"))));
ResourceId constant SpentMoveTableId = _tableId;

FieldLayout constant _fieldLayout = FieldLayout.wrap(0x0020010020000000000000000000000000000000000000000000000000000000);

library SpentMove {
    /**
     * @notice Get the table values' field layout.
     * @return _fieldLayout The field layout for the table.
     */
    function getFieldLayout() internal pure returns (FieldLayout) {
        return _fieldLayout;
    }

    /**
     * @notice Get the table's key schema.
     * @return _keySchema The key schema for the table.
     */
    function getKeySchema() internal pure returns (Schema) {
        SchemaType[] memory _keySchema = new SchemaType[](2);
        _keySchema[0] = SchemaType.ADDRESS;
        _keySchema[1] = SchemaType.UINT256;

        return SchemaLib.encode(_keySchema);
    }

    /**
     * @notice Get the table's value schema.
     * @return _valueSchema The value schema for the table.
     */
    function getValueSchema() internal pure returns (Schema) {
        SchemaType[] memory _valueSchema = new SchemaType[](1);
        _valueSchema[0] = SchemaType.UINT256;

        return SchemaLib.encode(_valueSchema);
    }

    /**
     * @notice Get the table's key field names.
     * @return keyNames An array of strings with the names of key fields.
     */
    function getKeyNames() internal pure returns (string[] memory keyNames) {
        keyNames = new string[](2);
        keyNames[0] = "player";
        keyNames[1] = "id";
    }

    /**
     * @notice Get the table's value field names.
     * @return fieldNames An array of strings with the names of value fields.
     */
    function getFieldNames() internal pure returns (string[] memory fieldNames) {
        fieldNames = new string[](1);
        fieldNames[0] = "value";
    }

    /**
     * @notice Register the table with its config.
     */
    function register() internal {
        StoreSwitch.registerTable(
            _tableId, _fieldLayout, getKeySchema(), getValueSchema(), getKeyNames(), getFieldNames()
        );
    }

    /**
     * @notice Register the table with its config.
     */
    function _register() internal {
        StoreCore.registerTable(
            _tableId, _fieldLayout, getKeySchema(), getValueSchema(), getKeyNames(), getFieldNames()
        );
    }

    /**
     * @notice Set value.
     */
    function setValue(address player, uint256 id, uint256 value) internal {
        bytes32[] memory _keyTuple = new bytes32[](2);
        _keyTuple[0] = bytes32(uint256(uint160(player)));
        _keyTuple[1] = bytes32(uint256(id));

        StoreSwitch.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((value)), _fieldLayout);
    }

    /**
     * @notice Set value.
     */
    function _setValue(address player, uint256 id, uint256 value) internal {
        bytes32[] memory _keyTuple = new bytes32[](2);
        _keyTuple[0] = bytes32(uint256(uint160(player)));
        _keyTuple[1] = bytes32(uint256(id));

        StoreCore.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((value)), _fieldLayout);
    }

    /**
     * @notice Set the full data using individual values.
     */
    function set(address player, uint256 id, uint256 value) internal {
        bytes memory _staticData = encodeStatic(value);

        PackedCounter _encodedLengths;
        bytes memory _dynamicData;

        bytes32[] memory _keyTuple = new bytes32[](2);
        _keyTuple[0] = bytes32(uint256(uint160(player)));
        _keyTuple[1] = bytes32(uint256(id));

        StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
    }

    /**
     * @notice Set the full data using individual values.
     */
    function _set(address player, uint256 id, uint256 value) internal {
        bytes memory _staticData = encodeStatic(value);

        PackedCounter _encodedLengths;
        bytes memory _dynamicData;

        bytes32[] memory _keyTuple = new bytes32[](2);
        _keyTuple[0] = bytes32(uint256(uint160(player)));
        _keyTuple[1] = bytes32(uint256(id));

        StoreCore.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData, _fieldLayout);
    }

    /**
     * @notice Decode the tightly packed blob of static data using this table's field layout.
     */
    function decodeStatic(bytes memory _blob) internal pure returns (uint256 value) {
        value = (uint256(Bytes.slice32(_blob, 0)));
    }

    /**
     * @notice Decode the tightly packed blobs using this table's field layout.
     * @param _staticData Tightly packed static fields.
     *
     *
     */
    function decode(bytes memory _staticData, PackedCounter, bytes memory) internal pure returns (uint256 value) {
        (value) = decodeStatic(_staticData);
    }

    /**
     * @notice Delete all data for given keys.
     */
    function deleteRecord(address player, uint256 id) internal {
        bytes32[] memory _keyTuple = new bytes32[](2);
        _keyTuple[0] = bytes32(uint256(uint160(player)));
        _keyTuple[1] = bytes32(uint256(id));

        StoreSwitch.deleteRecord(_tableId, _keyTuple);
    }

    /**
     * @notice Delete all data for given keys.
     */
    function _deleteRecord(address player, uint256 id) internal {
        bytes32[] memory _keyTuple = new bytes32[](2);
        _keyTuple[0] = bytes32(uint256(uint160(player)));
        _keyTuple[1] = bytes32(uint256(id));

        StoreCore.deleteRecord(_tableId, _keyTuple, _fieldLayout);
    }

    /**
     * @notice Tightly pack static (fixed length) data using this table's schema.
     * @return The static data, encoded into a sequence of bytes.
     */
    function encodeStatic(uint256 value) internal pure returns (bytes memory) {
        return abi.encodePacked(value);
    }

    /**
     * @notice Encode all of a record's fields.
     * @return The static (fixed length) data, encoded into a sequence of bytes.
     * @return The lengths of the dynamic fields (packed into a single bytes32 value).
     * @return The dyanmic (variable length) data, encoded into a sequence of bytes.
     */
    function encode(uint256 value) internal pure returns (bytes memory, PackedCounter, bytes memory) {
        bytes memory _staticData = encodeStatic(value);

        PackedCounter _encodedLengths;
        bytes memory _dynamicData;

        return (_staticData, _encodedLengths, _dynamicData);
    }

    /**
     * @notice Encode keys as a bytes32 array using this table's field layout.
     */
    function encodeKeyTuple(address player, uint256 id) internal pure returns (bytes32[] memory) {
        bytes32[] memory _keyTuple = new bytes32[](2);
        _keyTuple[0] = bytes32(uint256(uint160(player)));
        _keyTuple[1] = bytes32(uint256(id));

        return _keyTuple;
    }
}

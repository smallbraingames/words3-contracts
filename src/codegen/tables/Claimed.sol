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

library Claimed {
    // Hex below is the result of `WorldResourceIdLib.encode({ namespace: "", name: "Claimed", typeId: RESOURCE_TABLE
    // });`
    ResourceId constant _tableId = ResourceId.wrap(0x74620000000000000000000000000000436c61696d6564000000000000000000);

    FieldLayout constant _fieldLayout =
        FieldLayout.wrap(0x0001010001000000000000000000000000000000000000000000000000000000);

    // Hex-encoded key schema of (address)
    Schema constant _keySchema = Schema.wrap(0x0014010061000000000000000000000000000000000000000000000000000000);
    // Hex-encoded value schema of (bool)
    Schema constant _valueSchema = Schema.wrap(0x0001010060000000000000000000000000000000000000000000000000000000);

    /**
     * @notice Get the table's key field names.
     * @return keyNames An array of strings with the names of key fields.
     */
    function getKeyNames() internal pure returns (string[] memory keyNames) {
        keyNames = new string[](1);
        keyNames[0] = "player";
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
        StoreSwitch.registerTable(_tableId, _fieldLayout, _keySchema, _valueSchema, getKeyNames(), getFieldNames());
    }

    /**
     * @notice Register the table with its config.
     */
    function _register() internal {
        StoreCore.registerTable(_tableId, _fieldLayout, _keySchema, _valueSchema, getKeyNames(), getFieldNames());
    }

    /**
     * @notice Get value.
     */
    function getValue(address player) internal view returns (bool value) {
        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = bytes32(uint256(uint160(player)));

        bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
        return (_toBool(uint8(bytes1(_blob))));
    }

    /**
     * @notice Get value.
     */
    function _getValue(address player) internal view returns (bool value) {
        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = bytes32(uint256(uint160(player)));

        bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
        return (_toBool(uint8(bytes1(_blob))));
    }

    /**
     * @notice Get value.
     */
    function get(address player) internal view returns (bool value) {
        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = bytes32(uint256(uint160(player)));

        bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
        return (_toBool(uint8(bytes1(_blob))));
    }

    /**
     * @notice Get value.
     */
    function _get(address player) internal view returns (bool value) {
        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = bytes32(uint256(uint160(player)));

        bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
        return (_toBool(uint8(bytes1(_blob))));
    }

    /**
     * @notice Set value.
     */
    function setValue(address player, bool value) internal {
        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = bytes32(uint256(uint160(player)));

        StoreSwitch.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((value)), _fieldLayout);
    }

    /**
     * @notice Set value.
     */
    function _setValue(address player, bool value) internal {
        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = bytes32(uint256(uint160(player)));

        StoreCore.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((value)), _fieldLayout);
    }

    /**
     * @notice Set value.
     */
    function set(address player, bool value) internal {
        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = bytes32(uint256(uint160(player)));

        StoreSwitch.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((value)), _fieldLayout);
    }

    /**
     * @notice Set value.
     */
    function _set(address player, bool value) internal {
        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = bytes32(uint256(uint160(player)));

        StoreCore.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((value)), _fieldLayout);
    }

    /**
     * @notice Delete all data for given keys.
     */
    function deleteRecord(address player) internal {
        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = bytes32(uint256(uint160(player)));

        StoreSwitch.deleteRecord(_tableId, _keyTuple);
    }

    /**
     * @notice Delete all data for given keys.
     */
    function _deleteRecord(address player) internal {
        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = bytes32(uint256(uint160(player)));

        StoreCore.deleteRecord(_tableId, _keyTuple, _fieldLayout);
    }

    /**
     * @notice Tightly pack static (fixed length) data using this table's schema.
     * @return The static data, encoded into a sequence of bytes.
     */
    function encodeStatic(bool value) internal pure returns (bytes memory) {
        return abi.encodePacked(value);
    }

    /**
     * @notice Encode all of a record's fields.
     * @return The static (fixed length) data, encoded into a sequence of bytes.
     * @return The lengths of the dynamic fields (packed into a single bytes32 value).
     * @return The dynamic (variable length) data, encoded into a sequence of bytes.
     */
    function encode(bool value) internal pure returns (bytes memory, EncodedLengths, bytes memory) {
        bytes memory _staticData = encodeStatic(value);

        EncodedLengths _encodedLengths;
        bytes memory _dynamicData;

        return (_staticData, _encodedLengths, _dynamicData);
    }

    /**
     * @notice Encode keys as a bytes32 array using this table's field layout.
     */
    function encodeKeyTuple(address player) internal pure returns (bytes32[] memory) {
        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = bytes32(uint256(uint160(player)));

        return _keyTuple;
    }
}

/**
 * @notice Cast a value to a bool.
 * @dev Boolean values are encoded as uint8 (1 = true, 0 = false), but Solidity doesn't allow casting between uint8 and
 * bool.
 * @param value The uint8 value to convert.
 * @return result The boolean value.
 */
function _toBool(uint8 value) pure returns (bool result) {
    assembly {
        result := value
    }
}

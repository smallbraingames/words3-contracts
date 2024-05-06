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

struct PriceConfigData {
    uint256 minPrice;
    int256 wadFactor;
    int256 wadDurationRoot;
    int256 wadDurationScale;
    int256 wadDurationConstant;
}

library PriceConfig {
    // Hex below is the result of `WorldResourceIdLib.encode({ namespace: "", name: "PriceConfig", typeId:
    // RESOURCE_TABLE });`
    ResourceId constant _tableId = ResourceId.wrap(0x746200000000000000000000000000005072696365436f6e6669670000000000);

    FieldLayout constant _fieldLayout =
        FieldLayout.wrap(0x00a0050020202020200000000000000000000000000000000000000000000000);

    // Hex-encoded key schema of ()
    Schema constant _keySchema = Schema.wrap(0x0000000000000000000000000000000000000000000000000000000000000000);
    // Hex-encoded value schema of (uint256, int256, int256, int256, int256)
    Schema constant _valueSchema = Schema.wrap(0x00a005001f3f3f3f3f0000000000000000000000000000000000000000000000);

    /**
     * @notice Get the table's key field names.
     * @return keyNames An array of strings with the names of key fields.
     */
    function getKeyNames() internal pure returns (string[] memory keyNames) {
        keyNames = new string[](0);
    }

    /**
     * @notice Get the table's value field names.
     * @return fieldNames An array of strings with the names of value fields.
     */
    function getFieldNames() internal pure returns (string[] memory fieldNames) {
        fieldNames = new string[](5);
        fieldNames[0] = "minPrice";
        fieldNames[1] = "wadFactor";
        fieldNames[2] = "wadDurationRoot";
        fieldNames[3] = "wadDurationScale";
        fieldNames[4] = "wadDurationConstant";
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
     * @notice Get minPrice.
     */
    function getMinPrice() internal view returns (uint256 minPrice) {
        bytes32[] memory _keyTuple = new bytes32[](0);

        bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
        return (uint256(bytes32(_blob)));
    }

    /**
     * @notice Get minPrice.
     */
    function _getMinPrice() internal view returns (uint256 minPrice) {
        bytes32[] memory _keyTuple = new bytes32[](0);

        bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
        return (uint256(bytes32(_blob)));
    }

    /**
     * @notice Set minPrice.
     */
    function setMinPrice(uint256 minPrice) internal {
        bytes32[] memory _keyTuple = new bytes32[](0);

        StoreSwitch.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((minPrice)), _fieldLayout);
    }

    /**
     * @notice Set minPrice.
     */
    function _setMinPrice(uint256 minPrice) internal {
        bytes32[] memory _keyTuple = new bytes32[](0);

        StoreCore.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((minPrice)), _fieldLayout);
    }

    /**
     * @notice Get wadFactor.
     */
    function getWadFactor() internal view returns (int256 wadFactor) {
        bytes32[] memory _keyTuple = new bytes32[](0);

        bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 1, _fieldLayout);
        return (int256(uint256(bytes32(_blob))));
    }

    /**
     * @notice Get wadFactor.
     */
    function _getWadFactor() internal view returns (int256 wadFactor) {
        bytes32[] memory _keyTuple = new bytes32[](0);

        bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 1, _fieldLayout);
        return (int256(uint256(bytes32(_blob))));
    }

    /**
     * @notice Set wadFactor.
     */
    function setWadFactor(int256 wadFactor) internal {
        bytes32[] memory _keyTuple = new bytes32[](0);

        StoreSwitch.setStaticField(_tableId, _keyTuple, 1, abi.encodePacked((wadFactor)), _fieldLayout);
    }

    /**
     * @notice Set wadFactor.
     */
    function _setWadFactor(int256 wadFactor) internal {
        bytes32[] memory _keyTuple = new bytes32[](0);

        StoreCore.setStaticField(_tableId, _keyTuple, 1, abi.encodePacked((wadFactor)), _fieldLayout);
    }

    /**
     * @notice Get wadDurationRoot.
     */
    function getWadDurationRoot() internal view returns (int256 wadDurationRoot) {
        bytes32[] memory _keyTuple = new bytes32[](0);

        bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 2, _fieldLayout);
        return (int256(uint256(bytes32(_blob))));
    }

    /**
     * @notice Get wadDurationRoot.
     */
    function _getWadDurationRoot() internal view returns (int256 wadDurationRoot) {
        bytes32[] memory _keyTuple = new bytes32[](0);

        bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 2, _fieldLayout);
        return (int256(uint256(bytes32(_blob))));
    }

    /**
     * @notice Set wadDurationRoot.
     */
    function setWadDurationRoot(int256 wadDurationRoot) internal {
        bytes32[] memory _keyTuple = new bytes32[](0);

        StoreSwitch.setStaticField(_tableId, _keyTuple, 2, abi.encodePacked((wadDurationRoot)), _fieldLayout);
    }

    /**
     * @notice Set wadDurationRoot.
     */
    function _setWadDurationRoot(int256 wadDurationRoot) internal {
        bytes32[] memory _keyTuple = new bytes32[](0);

        StoreCore.setStaticField(_tableId, _keyTuple, 2, abi.encodePacked((wadDurationRoot)), _fieldLayout);
    }

    /**
     * @notice Get wadDurationScale.
     */
    function getWadDurationScale() internal view returns (int256 wadDurationScale) {
        bytes32[] memory _keyTuple = new bytes32[](0);

        bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 3, _fieldLayout);
        return (int256(uint256(bytes32(_blob))));
    }

    /**
     * @notice Get wadDurationScale.
     */
    function _getWadDurationScale() internal view returns (int256 wadDurationScale) {
        bytes32[] memory _keyTuple = new bytes32[](0);

        bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 3, _fieldLayout);
        return (int256(uint256(bytes32(_blob))));
    }

    /**
     * @notice Set wadDurationScale.
     */
    function setWadDurationScale(int256 wadDurationScale) internal {
        bytes32[] memory _keyTuple = new bytes32[](0);

        StoreSwitch.setStaticField(_tableId, _keyTuple, 3, abi.encodePacked((wadDurationScale)), _fieldLayout);
    }

    /**
     * @notice Set wadDurationScale.
     */
    function _setWadDurationScale(int256 wadDurationScale) internal {
        bytes32[] memory _keyTuple = new bytes32[](0);

        StoreCore.setStaticField(_tableId, _keyTuple, 3, abi.encodePacked((wadDurationScale)), _fieldLayout);
    }

    /**
     * @notice Get wadDurationConstant.
     */
    function getWadDurationConstant() internal view returns (int256 wadDurationConstant) {
        bytes32[] memory _keyTuple = new bytes32[](0);

        bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 4, _fieldLayout);
        return (int256(uint256(bytes32(_blob))));
    }

    /**
     * @notice Get wadDurationConstant.
     */
    function _getWadDurationConstant() internal view returns (int256 wadDurationConstant) {
        bytes32[] memory _keyTuple = new bytes32[](0);

        bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 4, _fieldLayout);
        return (int256(uint256(bytes32(_blob))));
    }

    /**
     * @notice Set wadDurationConstant.
     */
    function setWadDurationConstant(int256 wadDurationConstant) internal {
        bytes32[] memory _keyTuple = new bytes32[](0);

        StoreSwitch.setStaticField(_tableId, _keyTuple, 4, abi.encodePacked((wadDurationConstant)), _fieldLayout);
    }

    /**
     * @notice Set wadDurationConstant.
     */
    function _setWadDurationConstant(int256 wadDurationConstant) internal {
        bytes32[] memory _keyTuple = new bytes32[](0);

        StoreCore.setStaticField(_tableId, _keyTuple, 4, abi.encodePacked((wadDurationConstant)), _fieldLayout);
    }

    /**
     * @notice Get the full data.
     */
    function get() internal view returns (PriceConfigData memory _table) {
        bytes32[] memory _keyTuple = new bytes32[](0);

        (bytes memory _staticData, EncodedLengths _encodedLengths, bytes memory _dynamicData) =
            StoreSwitch.getRecord(_tableId, _keyTuple, _fieldLayout);
        return decode(_staticData, _encodedLengths, _dynamicData);
    }

    /**
     * @notice Get the full data.
     */
    function _get() internal view returns (PriceConfigData memory _table) {
        bytes32[] memory _keyTuple = new bytes32[](0);

        (bytes memory _staticData, EncodedLengths _encodedLengths, bytes memory _dynamicData) =
            StoreCore.getRecord(_tableId, _keyTuple, _fieldLayout);
        return decode(_staticData, _encodedLengths, _dynamicData);
    }

    /**
     * @notice Set the full data using individual values.
     */
    function set(
        uint256 minPrice,
        int256 wadFactor,
        int256 wadDurationRoot,
        int256 wadDurationScale,
        int256 wadDurationConstant
    )
        internal
    {
        bytes memory _staticData =
            encodeStatic(minPrice, wadFactor, wadDurationRoot, wadDurationScale, wadDurationConstant);

        EncodedLengths _encodedLengths;
        bytes memory _dynamicData;

        bytes32[] memory _keyTuple = new bytes32[](0);

        StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
    }

    /**
     * @notice Set the full data using individual values.
     */
    function _set(
        uint256 minPrice,
        int256 wadFactor,
        int256 wadDurationRoot,
        int256 wadDurationScale,
        int256 wadDurationConstant
    )
        internal
    {
        bytes memory _staticData =
            encodeStatic(minPrice, wadFactor, wadDurationRoot, wadDurationScale, wadDurationConstant);

        EncodedLengths _encodedLengths;
        bytes memory _dynamicData;

        bytes32[] memory _keyTuple = new bytes32[](0);

        StoreCore.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData, _fieldLayout);
    }

    /**
     * @notice Set the full data using the data struct.
     */
    function set(PriceConfigData memory _table) internal {
        bytes memory _staticData = encodeStatic(
            _table.minPrice,
            _table.wadFactor,
            _table.wadDurationRoot,
            _table.wadDurationScale,
            _table.wadDurationConstant
        );

        EncodedLengths _encodedLengths;
        bytes memory _dynamicData;

        bytes32[] memory _keyTuple = new bytes32[](0);

        StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
    }

    /**
     * @notice Set the full data using the data struct.
     */
    function _set(PriceConfigData memory _table) internal {
        bytes memory _staticData = encodeStatic(
            _table.minPrice,
            _table.wadFactor,
            _table.wadDurationRoot,
            _table.wadDurationScale,
            _table.wadDurationConstant
        );

        EncodedLengths _encodedLengths;
        bytes memory _dynamicData;

        bytes32[] memory _keyTuple = new bytes32[](0);

        StoreCore.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData, _fieldLayout);
    }

    /**
     * @notice Decode the tightly packed blob of static data using this table's field layout.
     */
    function decodeStatic(bytes memory _blob)
        internal
        pure
        returns (
            uint256 minPrice,
            int256 wadFactor,
            int256 wadDurationRoot,
            int256 wadDurationScale,
            int256 wadDurationConstant
        )
    {
        minPrice = (uint256(Bytes.getBytes32(_blob, 0)));

        wadFactor = (int256(uint256(Bytes.getBytes32(_blob, 32))));

        wadDurationRoot = (int256(uint256(Bytes.getBytes32(_blob, 64))));

        wadDurationScale = (int256(uint256(Bytes.getBytes32(_blob, 96))));

        wadDurationConstant = (int256(uint256(Bytes.getBytes32(_blob, 128))));
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
        returns (PriceConfigData memory _table)
    {
        (_table.minPrice, _table.wadFactor, _table.wadDurationRoot, _table.wadDurationScale, _table.wadDurationConstant)
        = decodeStatic(_staticData);
    }

    /**
     * @notice Delete all data for given keys.
     */
    function deleteRecord() internal {
        bytes32[] memory _keyTuple = new bytes32[](0);

        StoreSwitch.deleteRecord(_tableId, _keyTuple);
    }

    /**
     * @notice Delete all data for given keys.
     */
    function _deleteRecord() internal {
        bytes32[] memory _keyTuple = new bytes32[](0);

        StoreCore.deleteRecord(_tableId, _keyTuple, _fieldLayout);
    }

    /**
     * @notice Tightly pack static (fixed length) data using this table's schema.
     * @return The static data, encoded into a sequence of bytes.
     */
    function encodeStatic(
        uint256 minPrice,
        int256 wadFactor,
        int256 wadDurationRoot,
        int256 wadDurationScale,
        int256 wadDurationConstant
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodePacked(minPrice, wadFactor, wadDurationRoot, wadDurationScale, wadDurationConstant);
    }

    /**
     * @notice Encode all of a record's fields.
     * @return The static (fixed length) data, encoded into a sequence of bytes.
     * @return The lengths of the dynamic fields (packed into a single bytes32 value).
     * @return The dynamic (variable length) data, encoded into a sequence of bytes.
     */
    function encode(
        uint256 minPrice,
        int256 wadFactor,
        int256 wadDurationRoot,
        int256 wadDurationScale,
        int256 wadDurationConstant
    )
        internal
        pure
        returns (bytes memory, EncodedLengths, bytes memory)
    {
        bytes memory _staticData =
            encodeStatic(minPrice, wadFactor, wadDurationRoot, wadDurationScale, wadDurationConstant);

        EncodedLengths _encodedLengths;
        bytes memory _dynamicData;

        return (_staticData, _encodedLengths, _dynamicData);
    }

    /**
     * @notice Encode keys as a bytes32 array using this table's field layout.
     */
    function encodeKeyTuple() internal pure returns (bytes32[] memory) {
        bytes32[] memory _keyTuple = new bytes32[](0);

        return _keyTuple;
    }
}

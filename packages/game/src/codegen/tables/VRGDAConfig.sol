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

struct VRGDAConfigData {
    uint256 startTime;
    int256 targetPrice;
    int256 priceDecay;
    int256 perDayInitial;
    int256 power;
}

library VRGDAConfig {
    // Hex below is the result of `WorldResourceIdLib.encode({ namespace: "", name: "VRGDAConfig", typeId:
    // RESOURCE_TABLE });`
    ResourceId constant _tableId = ResourceId.wrap(0x746200000000000000000000000000005652474441436f6e6669670000000000);

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
        fieldNames[0] = "startTime";
        fieldNames[1] = "targetPrice";
        fieldNames[2] = "priceDecay";
        fieldNames[3] = "perDayInitial";
        fieldNames[4] = "power";
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
     * @notice Get startTime.
     */
    function getStartTime() internal view returns (uint256 startTime) {
        bytes32[] memory _keyTuple = new bytes32[](0);

        bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
        return (uint256(bytes32(_blob)));
    }

    /**
     * @notice Get startTime.
     */
    function _getStartTime() internal view returns (uint256 startTime) {
        bytes32[] memory _keyTuple = new bytes32[](0);

        bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
        return (uint256(bytes32(_blob)));
    }

    /**
     * @notice Set startTime.
     */
    function setStartTime(uint256 startTime) internal {
        bytes32[] memory _keyTuple = new bytes32[](0);

        StoreSwitch.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((startTime)), _fieldLayout);
    }

    /**
     * @notice Set startTime.
     */
    function _setStartTime(uint256 startTime) internal {
        bytes32[] memory _keyTuple = new bytes32[](0);

        StoreCore.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked((startTime)), _fieldLayout);
    }

    /**
     * @notice Get targetPrice.
     */
    function getTargetPrice() internal view returns (int256 targetPrice) {
        bytes32[] memory _keyTuple = new bytes32[](0);

        bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 1, _fieldLayout);
        return (int256(uint256(bytes32(_blob))));
    }

    /**
     * @notice Get targetPrice.
     */
    function _getTargetPrice() internal view returns (int256 targetPrice) {
        bytes32[] memory _keyTuple = new bytes32[](0);

        bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 1, _fieldLayout);
        return (int256(uint256(bytes32(_blob))));
    }

    /**
     * @notice Set targetPrice.
     */
    function setTargetPrice(int256 targetPrice) internal {
        bytes32[] memory _keyTuple = new bytes32[](0);

        StoreSwitch.setStaticField(_tableId, _keyTuple, 1, abi.encodePacked((targetPrice)), _fieldLayout);
    }

    /**
     * @notice Set targetPrice.
     */
    function _setTargetPrice(int256 targetPrice) internal {
        bytes32[] memory _keyTuple = new bytes32[](0);

        StoreCore.setStaticField(_tableId, _keyTuple, 1, abi.encodePacked((targetPrice)), _fieldLayout);
    }

    /**
     * @notice Get priceDecay.
     */
    function getPriceDecay() internal view returns (int256 priceDecay) {
        bytes32[] memory _keyTuple = new bytes32[](0);

        bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 2, _fieldLayout);
        return (int256(uint256(bytes32(_blob))));
    }

    /**
     * @notice Get priceDecay.
     */
    function _getPriceDecay() internal view returns (int256 priceDecay) {
        bytes32[] memory _keyTuple = new bytes32[](0);

        bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 2, _fieldLayout);
        return (int256(uint256(bytes32(_blob))));
    }

    /**
     * @notice Set priceDecay.
     */
    function setPriceDecay(int256 priceDecay) internal {
        bytes32[] memory _keyTuple = new bytes32[](0);

        StoreSwitch.setStaticField(_tableId, _keyTuple, 2, abi.encodePacked((priceDecay)), _fieldLayout);
    }

    /**
     * @notice Set priceDecay.
     */
    function _setPriceDecay(int256 priceDecay) internal {
        bytes32[] memory _keyTuple = new bytes32[](0);

        StoreCore.setStaticField(_tableId, _keyTuple, 2, abi.encodePacked((priceDecay)), _fieldLayout);
    }

    /**
     * @notice Get perDayInitial.
     */
    function getPerDayInitial() internal view returns (int256 perDayInitial) {
        bytes32[] memory _keyTuple = new bytes32[](0);

        bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 3, _fieldLayout);
        return (int256(uint256(bytes32(_blob))));
    }

    /**
     * @notice Get perDayInitial.
     */
    function _getPerDayInitial() internal view returns (int256 perDayInitial) {
        bytes32[] memory _keyTuple = new bytes32[](0);

        bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 3, _fieldLayout);
        return (int256(uint256(bytes32(_blob))));
    }

    /**
     * @notice Set perDayInitial.
     */
    function setPerDayInitial(int256 perDayInitial) internal {
        bytes32[] memory _keyTuple = new bytes32[](0);

        StoreSwitch.setStaticField(_tableId, _keyTuple, 3, abi.encodePacked((perDayInitial)), _fieldLayout);
    }

    /**
     * @notice Set perDayInitial.
     */
    function _setPerDayInitial(int256 perDayInitial) internal {
        bytes32[] memory _keyTuple = new bytes32[](0);

        StoreCore.setStaticField(_tableId, _keyTuple, 3, abi.encodePacked((perDayInitial)), _fieldLayout);
    }

    /**
     * @notice Get power.
     */
    function getPower() internal view returns (int256 power) {
        bytes32[] memory _keyTuple = new bytes32[](0);

        bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 4, _fieldLayout);
        return (int256(uint256(bytes32(_blob))));
    }

    /**
     * @notice Get power.
     */
    function _getPower() internal view returns (int256 power) {
        bytes32[] memory _keyTuple = new bytes32[](0);

        bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 4, _fieldLayout);
        return (int256(uint256(bytes32(_blob))));
    }

    /**
     * @notice Set power.
     */
    function setPower(int256 power) internal {
        bytes32[] memory _keyTuple = new bytes32[](0);

        StoreSwitch.setStaticField(_tableId, _keyTuple, 4, abi.encodePacked((power)), _fieldLayout);
    }

    /**
     * @notice Set power.
     */
    function _setPower(int256 power) internal {
        bytes32[] memory _keyTuple = new bytes32[](0);

        StoreCore.setStaticField(_tableId, _keyTuple, 4, abi.encodePacked((power)), _fieldLayout);
    }

    /**
     * @notice Get the full data.
     */
    function get() internal view returns (VRGDAConfigData memory _table) {
        bytes32[] memory _keyTuple = new bytes32[](0);

        (bytes memory _staticData, EncodedLengths _encodedLengths, bytes memory _dynamicData) =
            StoreSwitch.getRecord(_tableId, _keyTuple, _fieldLayout);
        return decode(_staticData, _encodedLengths, _dynamicData);
    }

    /**
     * @notice Get the full data.
     */
    function _get() internal view returns (VRGDAConfigData memory _table) {
        bytes32[] memory _keyTuple = new bytes32[](0);

        (bytes memory _staticData, EncodedLengths _encodedLengths, bytes memory _dynamicData) =
            StoreCore.getRecord(_tableId, _keyTuple, _fieldLayout);
        return decode(_staticData, _encodedLengths, _dynamicData);
    }

    /**
     * @notice Set the full data using individual values.
     */
    function set(
        uint256 startTime,
        int256 targetPrice,
        int256 priceDecay,
        int256 perDayInitial,
        int256 power
    )
        internal
    {
        bytes memory _staticData = encodeStatic(startTime, targetPrice, priceDecay, perDayInitial, power);

        EncodedLengths _encodedLengths;
        bytes memory _dynamicData;

        bytes32[] memory _keyTuple = new bytes32[](0);

        StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
    }

    /**
     * @notice Set the full data using individual values.
     */
    function _set(
        uint256 startTime,
        int256 targetPrice,
        int256 priceDecay,
        int256 perDayInitial,
        int256 power
    )
        internal
    {
        bytes memory _staticData = encodeStatic(startTime, targetPrice, priceDecay, perDayInitial, power);

        EncodedLengths _encodedLengths;
        bytes memory _dynamicData;

        bytes32[] memory _keyTuple = new bytes32[](0);

        StoreCore.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData, _fieldLayout);
    }

    /**
     * @notice Set the full data using the data struct.
     */
    function set(VRGDAConfigData memory _table) internal {
        bytes memory _staticData =
            encodeStatic(_table.startTime, _table.targetPrice, _table.priceDecay, _table.perDayInitial, _table.power);

        EncodedLengths _encodedLengths;
        bytes memory _dynamicData;

        bytes32[] memory _keyTuple = new bytes32[](0);

        StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
    }

    /**
     * @notice Set the full data using the data struct.
     */
    function _set(VRGDAConfigData memory _table) internal {
        bytes memory _staticData =
            encodeStatic(_table.startTime, _table.targetPrice, _table.priceDecay, _table.perDayInitial, _table.power);

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
        returns (uint256 startTime, int256 targetPrice, int256 priceDecay, int256 perDayInitial, int256 power)
    {
        startTime = (uint256(Bytes.getBytes32(_blob, 0)));

        targetPrice = (int256(uint256(Bytes.getBytes32(_blob, 32))));

        priceDecay = (int256(uint256(Bytes.getBytes32(_blob, 64))));

        perDayInitial = (int256(uint256(Bytes.getBytes32(_blob, 96))));

        power = (int256(uint256(Bytes.getBytes32(_blob, 128))));
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
        returns (VRGDAConfigData memory _table)
    {
        (_table.startTime, _table.targetPrice, _table.priceDecay, _table.perDayInitial, _table.power) =
            decodeStatic(_staticData);
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
        uint256 startTime,
        int256 targetPrice,
        int256 priceDecay,
        int256 perDayInitial,
        int256 power
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodePacked(startTime, targetPrice, priceDecay, perDayInitial, power);
    }

    /**
     * @notice Encode all of a record's fields.
     * @return The static (fixed length) data, encoded into a sequence of bytes.
     * @return The lengths of the dynamic fields (packed into a single bytes32 value).
     * @return The dynamic (variable length) data, encoded into a sequence of bytes.
     */
    function encode(
        uint256 startTime,
        int256 targetPrice,
        int256 priceDecay,
        int256 perDayInitial,
        int256 power
    )
        internal
        pure
        returns (bytes memory, EncodedLengths, bytes memory)
    {
        bytes memory _staticData = encodeStatic(startTime, targetPrice, priceDecay, perDayInitial, power);

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

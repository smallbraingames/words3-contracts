// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

/* Autogenerated file. Do not edit manually. */

// Import schema type
import { SchemaType } from "@latticexyz/schema-type/src/solidity/SchemaType.sol";

// Import store internals
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { StoreCore } from "@latticexyz/store/src/StoreCore.sol";
import { Bytes } from "@latticexyz/store/src/Bytes.sol";
import { Memory } from "@latticexyz/store/src/Memory.sol";
import { SliceLib } from "@latticexyz/store/src/Slice.sol";
import { EncodeArray } from "@latticexyz/store/src/tightcoder/EncodeArray.sol";
import { FieldLayout, FieldLayoutLib } from "@latticexyz/store/src/FieldLayout.sol";
import { Schema, SchemaLib } from "@latticexyz/store/src/Schema.sol";
import { PackedCounter, PackedCounterLib } from "@latticexyz/store/src/PackedCounter.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { RESOURCE_TABLE, RESOURCE_OFFCHAIN_TABLE } from "@latticexyz/store/src/storeResourceTypes.sol";

ResourceId constant _tableId = ResourceId.wrap(
  bytes32(abi.encodePacked(RESOURCE_TABLE, bytes14(""), bytes16("VRGDAConfig")))
);
ResourceId constant VRGDAConfigTableId = _tableId;

FieldLayout constant _fieldLayout = FieldLayout.wrap(
  0x00a0050020202020200000000000000000000000000000000000000000000000
);

struct VRGDAConfigData {
  uint256 startTime;
  int256 targetPrice;
  int256 priceDecay;
  int256 perDayInitial;
  int256 power;
}

library VRGDAConfig {
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
    SchemaType[] memory _keySchema = new SchemaType[](0);

    return SchemaLib.encode(_keySchema);
  }

  /**
   * @notice Get the table's value schema.
   * @return _valueSchema The value schema for the table.
   */
  function getValueSchema() internal pure returns (Schema) {
    SchemaType[] memory _valueSchema = new SchemaType[](5);
    _valueSchema[0] = SchemaType.UINT256;
    _valueSchema[1] = SchemaType.INT256;
    _valueSchema[2] = SchemaType.INT256;
    _valueSchema[3] = SchemaType.INT256;
    _valueSchema[4] = SchemaType.INT256;

    return SchemaLib.encode(_valueSchema);
  }

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
    StoreSwitch.registerTable(_tableId, _fieldLayout, getKeySchema(), getValueSchema(), getKeyNames(), getFieldNames());
  }

  /**
   * @notice Register the table with its config.
   */
  function _register() internal {
    StoreCore.registerTable(_tableId, _fieldLayout, getKeySchema(), getValueSchema(), getKeyNames(), getFieldNames());
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

    (bytes memory _staticData, PackedCounter _encodedLengths, bytes memory _dynamicData) = StoreSwitch.getRecord(
      _tableId,
      _keyTuple,
      _fieldLayout
    );
    return decode(_staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Get the full data.
   */
  function _get() internal view returns (VRGDAConfigData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    (bytes memory _staticData, PackedCounter _encodedLengths, bytes memory _dynamicData) = StoreCore.getRecord(
      _tableId,
      _keyTuple,
      _fieldLayout
    );
    return decode(_staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using individual values.
   */
  function set(uint256 startTime, int256 targetPrice, int256 priceDecay, int256 perDayInitial, int256 power) internal {
    bytes memory _staticData = encodeStatic(startTime, targetPrice, priceDecay, perDayInitial, power);

    PackedCounter _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using individual values.
   */
  function _set(uint256 startTime, int256 targetPrice, int256 priceDecay, int256 perDayInitial, int256 power) internal {
    bytes memory _staticData = encodeStatic(startTime, targetPrice, priceDecay, perDayInitial, power);

    PackedCounter _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreCore.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData, _fieldLayout);
  }

  /**
   * @notice Set the full data using the data struct.
   */
  function set(VRGDAConfigData memory _table) internal {
    bytes memory _staticData = encodeStatic(
      _table.startTime,
      _table.targetPrice,
      _table.priceDecay,
      _table.perDayInitial,
      _table.power
    );

    PackedCounter _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using the data struct.
   */
  function _set(VRGDAConfigData memory _table) internal {
    bytes memory _staticData = encodeStatic(
      _table.startTime,
      _table.targetPrice,
      _table.priceDecay,
      _table.perDayInitial,
      _table.power
    );

    PackedCounter _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreCore.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData, _fieldLayout);
  }

  /**
   * @notice Decode the tightly packed blob of static data using this table's field layout.
   */
  function decodeStatic(
    bytes memory _blob
  )
    internal
    pure
    returns (uint256 startTime, int256 targetPrice, int256 priceDecay, int256 perDayInitial, int256 power)
  {
    startTime = (uint256(Bytes.slice32(_blob, 0)));

    targetPrice = (int256(uint256(Bytes.slice32(_blob, 32))));

    priceDecay = (int256(uint256(Bytes.slice32(_blob, 64))));

    perDayInitial = (int256(uint256(Bytes.slice32(_blob, 96))));

    power = (int256(uint256(Bytes.slice32(_blob, 128))));
  }

  /**
   * @notice Decode the tightly packed blobs using this table's field layout.
   * @param _staticData Tightly packed static fields.
   *
   *
   */
  function decode(
    bytes memory _staticData,
    PackedCounter,
    bytes memory
  ) internal pure returns (VRGDAConfigData memory _table) {
    (_table.startTime, _table.targetPrice, _table.priceDecay, _table.perDayInitial, _table.power) = decodeStatic(
      _staticData
    );
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
  ) internal pure returns (bytes memory) {
    return abi.encodePacked(startTime, targetPrice, priceDecay, perDayInitial, power);
  }

  /**
   * @notice Encode all of a record's fields.
   * @return The static (fixed length) data, encoded into a sequence of bytes.
   * @return The lengths of the dynamic fields (packed into a single bytes32 value).
   * @return The dyanmic (variable length) data, encoded into a sequence of bytes.
   */
  function encode(
    uint256 startTime,
    int256 targetPrice,
    int256 priceDecay,
    int256 perDayInitial,
    int256 power
  ) internal pure returns (bytes memory, PackedCounter, bytes memory) {
    bytes memory _staticData = encodeStatic(startTime, targetPrice, priceDecay, perDayInitial, power);

    PackedCounter _encodedLengths;
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

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

// Import store internals
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { StoreCore } from "@latticexyz/store/src/StoreCore.sol";
import { Bytes } from "@latticexyz/store/src/Bytes.sol";
import { Memory } from "@latticexyz/store/src/Memory.sol";
import { SliceLib } from "@latticexyz/store/src/Slice.sol";
import { EncodeArray } from "@latticexyz/store/src/tightcoder/EncodeArray.sol";
import { FieldLayout } from "@latticexyz/store/src/FieldLayout.sol";
import { Schema } from "@latticexyz/store/src/Schema.sol";
import { EncodedLengths, EncodedLengthsLib } from "@latticexyz/store/src/EncodedLengths.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

// Import user types
import { Status } from "./../common.sol";

struct GameConfigData {
  Status status;
  uint256 endTime;
  uint32 crossWordRewardFraction;
  uint256 maxPlayerSpend;
  uint16 bonusDistance;
}

library GameConfig {
  // Hex below is the result of `WorldResourceIdLib.encode({ namespace: "", name: "GameConfig", typeId: RESOURCE_TABLE });`
  ResourceId constant _tableId = ResourceId.wrap(0x7462000000000000000000000000000047616d65436f6e666967000000000000);

  FieldLayout constant _fieldLayout =
    FieldLayout.wrap(0x0047050001200420020000000000000000000000000000000000000000000000);

  // Hex-encoded key schema of ()
  Schema constant _keySchema = Schema.wrap(0x0000000000000000000000000000000000000000000000000000000000000000);
  // Hex-encoded value schema of (uint8, uint256, uint32, uint256, uint16)
  Schema constant _valueSchema = Schema.wrap(0x00470500001f031f010000000000000000000000000000000000000000000000);

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
    fieldNames[0] = "status";
    fieldNames[1] = "endTime";
    fieldNames[2] = "crossWordRewardFraction";
    fieldNames[3] = "maxPlayerSpend";
    fieldNames[4] = "bonusDistance";
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
   * @notice Get status.
   */
  function getStatus() internal view returns (Status status) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return Status(uint8(bytes1(_blob)));
  }

  /**
   * @notice Get status.
   */
  function _getStatus() internal view returns (Status status) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 0, _fieldLayout);
    return Status(uint8(bytes1(_blob)));
  }

  /**
   * @notice Set status.
   */
  function setStatus(Status status) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked(uint8(status)), _fieldLayout);
  }

  /**
   * @notice Set status.
   */
  function _setStatus(Status status) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreCore.setStaticField(_tableId, _keyTuple, 0, abi.encodePacked(uint8(status)), _fieldLayout);
  }

  /**
   * @notice Get endTime.
   */
  function getEndTime() internal view returns (uint256 endTime) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 1, _fieldLayout);
    return (uint256(bytes32(_blob)));
  }

  /**
   * @notice Get endTime.
   */
  function _getEndTime() internal view returns (uint256 endTime) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 1, _fieldLayout);
    return (uint256(bytes32(_blob)));
  }

  /**
   * @notice Set endTime.
   */
  function setEndTime(uint256 endTime) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.setStaticField(_tableId, _keyTuple, 1, abi.encodePacked((endTime)), _fieldLayout);
  }

  /**
   * @notice Set endTime.
   */
  function _setEndTime(uint256 endTime) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreCore.setStaticField(_tableId, _keyTuple, 1, abi.encodePacked((endTime)), _fieldLayout);
  }

  /**
   * @notice Get crossWordRewardFraction.
   */
  function getCrossWordRewardFraction() internal view returns (uint32 crossWordRewardFraction) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 2, _fieldLayout);
    return (uint32(bytes4(_blob)));
  }

  /**
   * @notice Get crossWordRewardFraction.
   */
  function _getCrossWordRewardFraction() internal view returns (uint32 crossWordRewardFraction) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 2, _fieldLayout);
    return (uint32(bytes4(_blob)));
  }

  /**
   * @notice Set crossWordRewardFraction.
   */
  function setCrossWordRewardFraction(uint32 crossWordRewardFraction) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.setStaticField(_tableId, _keyTuple, 2, abi.encodePacked((crossWordRewardFraction)), _fieldLayout);
  }

  /**
   * @notice Set crossWordRewardFraction.
   */
  function _setCrossWordRewardFraction(uint32 crossWordRewardFraction) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreCore.setStaticField(_tableId, _keyTuple, 2, abi.encodePacked((crossWordRewardFraction)), _fieldLayout);
  }

  /**
   * @notice Get maxPlayerSpend.
   */
  function getMaxPlayerSpend() internal view returns (uint256 maxPlayerSpend) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 3, _fieldLayout);
    return (uint256(bytes32(_blob)));
  }

  /**
   * @notice Get maxPlayerSpend.
   */
  function _getMaxPlayerSpend() internal view returns (uint256 maxPlayerSpend) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 3, _fieldLayout);
    return (uint256(bytes32(_blob)));
  }

  /**
   * @notice Set maxPlayerSpend.
   */
  function setMaxPlayerSpend(uint256 maxPlayerSpend) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.setStaticField(_tableId, _keyTuple, 3, abi.encodePacked((maxPlayerSpend)), _fieldLayout);
  }

  /**
   * @notice Set maxPlayerSpend.
   */
  function _setMaxPlayerSpend(uint256 maxPlayerSpend) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreCore.setStaticField(_tableId, _keyTuple, 3, abi.encodePacked((maxPlayerSpend)), _fieldLayout);
  }

  /**
   * @notice Get bonusDistance.
   */
  function getBonusDistance() internal view returns (uint16 bonusDistance) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes32 _blob = StoreSwitch.getStaticField(_tableId, _keyTuple, 4, _fieldLayout);
    return (uint16(bytes2(_blob)));
  }

  /**
   * @notice Get bonusDistance.
   */
  function _getBonusDistance() internal view returns (uint16 bonusDistance) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes32 _blob = StoreCore.getStaticField(_tableId, _keyTuple, 4, _fieldLayout);
    return (uint16(bytes2(_blob)));
  }

  /**
   * @notice Set bonusDistance.
   */
  function setBonusDistance(uint16 bonusDistance) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.setStaticField(_tableId, _keyTuple, 4, abi.encodePacked((bonusDistance)), _fieldLayout);
  }

  /**
   * @notice Set bonusDistance.
   */
  function _setBonusDistance(uint16 bonusDistance) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreCore.setStaticField(_tableId, _keyTuple, 4, abi.encodePacked((bonusDistance)), _fieldLayout);
  }

  /**
   * @notice Get the full data.
   */
  function get() internal view returns (GameConfigData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    (bytes memory _staticData, EncodedLengths _encodedLengths, bytes memory _dynamicData) = StoreSwitch.getRecord(
      _tableId,
      _keyTuple,
      _fieldLayout
    );
    return decode(_staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Get the full data.
   */
  function _get() internal view returns (GameConfigData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    (bytes memory _staticData, EncodedLengths _encodedLengths, bytes memory _dynamicData) = StoreCore.getRecord(
      _tableId,
      _keyTuple,
      _fieldLayout
    );
    return decode(_staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using individual values.
   */
  function set(
    Status status,
    uint256 endTime,
    uint32 crossWordRewardFraction,
    uint256 maxPlayerSpend,
    uint16 bonusDistance
  ) internal {
    bytes memory _staticData = encodeStatic(status, endTime, crossWordRewardFraction, maxPlayerSpend, bonusDistance);

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using individual values.
   */
  function _set(
    Status status,
    uint256 endTime,
    uint32 crossWordRewardFraction,
    uint256 maxPlayerSpend,
    uint16 bonusDistance
  ) internal {
    bytes memory _staticData = encodeStatic(status, endTime, crossWordRewardFraction, maxPlayerSpend, bonusDistance);

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreCore.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData, _fieldLayout);
  }

  /**
   * @notice Set the full data using the data struct.
   */
  function set(GameConfigData memory _table) internal {
    bytes memory _staticData = encodeStatic(
      _table.status,
      _table.endTime,
      _table.crossWordRewardFraction,
      _table.maxPlayerSpend,
      _table.bonusDistance
    );

    EncodedLengths _encodedLengths;
    bytes memory _dynamicData;

    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.setRecord(_tableId, _keyTuple, _staticData, _encodedLengths, _dynamicData);
  }

  /**
   * @notice Set the full data using the data struct.
   */
  function _set(GameConfigData memory _table) internal {
    bytes memory _staticData = encodeStatic(
      _table.status,
      _table.endTime,
      _table.crossWordRewardFraction,
      _table.maxPlayerSpend,
      _table.bonusDistance
    );

    EncodedLengths _encodedLengths;
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
    returns (
      Status status,
      uint256 endTime,
      uint32 crossWordRewardFraction,
      uint256 maxPlayerSpend,
      uint16 bonusDistance
    )
  {
    status = Status(uint8(Bytes.getBytes1(_blob, 0)));

    endTime = (uint256(Bytes.getBytes32(_blob, 1)));

    crossWordRewardFraction = (uint32(Bytes.getBytes4(_blob, 33)));

    maxPlayerSpend = (uint256(Bytes.getBytes32(_blob, 37)));

    bonusDistance = (uint16(Bytes.getBytes2(_blob, 69)));
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
  ) internal pure returns (GameConfigData memory _table) {
    (
      _table.status,
      _table.endTime,
      _table.crossWordRewardFraction,
      _table.maxPlayerSpend,
      _table.bonusDistance
    ) = decodeStatic(_staticData);
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
    Status status,
    uint256 endTime,
    uint32 crossWordRewardFraction,
    uint256 maxPlayerSpend,
    uint16 bonusDistance
  ) internal pure returns (bytes memory) {
    return abi.encodePacked(status, endTime, crossWordRewardFraction, maxPlayerSpend, bonusDistance);
  }

  /**
   * @notice Encode all of a record's fields.
   * @return The static (fixed length) data, encoded into a sequence of bytes.
   * @return The lengths of the dynamic fields (packed into a single bytes32 value).
   * @return The dynamic (variable length) data, encoded into a sequence of bytes.
   */
  function encode(
    Status status,
    uint256 endTime,
    uint32 crossWordRewardFraction,
    uint256 maxPlayerSpend,
    uint16 bonusDistance
  ) internal pure returns (bytes memory, EncodedLengths, bytes memory) {
    bytes memory _staticData = encodeStatic(status, endTime, crossWordRewardFraction, maxPlayerSpend, bonusDistance);

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

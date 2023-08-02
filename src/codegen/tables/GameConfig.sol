// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

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
import { Schema, SchemaLib } from "@latticexyz/store/src/Schema.sol";
import { PackedCounter, PackedCounterLib } from "@latticexyz/store/src/PackedCounter.sol";

// Import user types
import { Status } from "./../Types.sol";

bytes32 constant _tableId = bytes32(abi.encodePacked(bytes16(""), bytes16("GameConfig")));
bytes32 constant GameConfigTableId = _tableId;

struct GameConfigData {
  Status status;
  uint256 endTime;
  uint32 crossWordRewardFraction;
}

library GameConfig {
  /** Get the table's schema */
  function getSchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](3);
    _schema[0] = SchemaType.UINT8;
    _schema[1] = SchemaType.UINT256;
    _schema[2] = SchemaType.UINT32;

    return SchemaLib.encode(_schema);
  }

  function getKeySchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](0);

    return SchemaLib.encode(_schema);
  }

  /** Get the table's metadata */
  function getMetadata() internal pure returns (string memory, string[] memory) {
    string[] memory _fieldNames = new string[](3);
    _fieldNames[0] = "status";
    _fieldNames[1] = "endTime";
    _fieldNames[2] = "crossWordRewardFraction";
    return ("GameConfig", _fieldNames);
  }

  /** Register the table's schema */
  function registerSchema() internal {
    StoreSwitch.registerSchema(_tableId, getSchema(), getKeySchema());
  }

  /** Register the table's schema (using the specified store) */
  function registerSchema(IStore _store) internal {
    _store.registerSchema(_tableId, getSchema(), getKeySchema());
  }

  /** Set the table's metadata */
  function setMetadata() internal {
    (string memory _tableName, string[] memory _fieldNames) = getMetadata();
    StoreSwitch.setMetadata(_tableId, _tableName, _fieldNames);
  }

  /** Set the table's metadata (using the specified store) */
  function setMetadata(IStore _store) internal {
    (string memory _tableName, string[] memory _fieldNames) = getMetadata();
    _store.setMetadata(_tableId, _tableName, _fieldNames);
  }

  /** Get status */
  function getStatus() internal view returns (Status status) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 0);
    return Status(uint8(Bytes.slice1(_blob, 0)));
  }

  /** Get status (using the specified store) */
  function getStatus(IStore _store) internal view returns (Status status) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 0);
    return Status(uint8(Bytes.slice1(_blob, 0)));
  }

  /** Set status */
  function setStatus(Status status) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.setField(_tableId, _keyTuple, 0, abi.encodePacked(uint8(status)));
  }

  /** Set status (using the specified store) */
  function setStatus(IStore _store, Status status) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    _store.setField(_tableId, _keyTuple, 0, abi.encodePacked(uint8(status)));
  }

  /** Get endTime */
  function getEndTime() internal view returns (uint256 endTime) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 1);
    return (uint256(Bytes.slice32(_blob, 0)));
  }

  /** Get endTime (using the specified store) */
  function getEndTime(IStore _store) internal view returns (uint256 endTime) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 1);
    return (uint256(Bytes.slice32(_blob, 0)));
  }

  /** Set endTime */
  function setEndTime(uint256 endTime) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.setField(_tableId, _keyTuple, 1, abi.encodePacked((endTime)));
  }

  /** Set endTime (using the specified store) */
  function setEndTime(IStore _store, uint256 endTime) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    _store.setField(_tableId, _keyTuple, 1, abi.encodePacked((endTime)));
  }

  /** Get crossWordRewardFraction */
  function getCrossWordRewardFraction() internal view returns (uint32 crossWordRewardFraction) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 2);
    return (uint32(Bytes.slice4(_blob, 0)));
  }

  /** Get crossWordRewardFraction (using the specified store) */
  function getCrossWordRewardFraction(IStore _store) internal view returns (uint32 crossWordRewardFraction) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 2);
    return (uint32(Bytes.slice4(_blob, 0)));
  }

  /** Set crossWordRewardFraction */
  function setCrossWordRewardFraction(uint32 crossWordRewardFraction) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.setField(_tableId, _keyTuple, 2, abi.encodePacked((crossWordRewardFraction)));
  }

  /** Set crossWordRewardFraction (using the specified store) */
  function setCrossWordRewardFraction(IStore _store, uint32 crossWordRewardFraction) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    _store.setField(_tableId, _keyTuple, 2, abi.encodePacked((crossWordRewardFraction)));
  }

  /** Get the full data */
  function get() internal view returns (GameConfigData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes memory _blob = StoreSwitch.getRecord(_tableId, _keyTuple, getSchema());
    return decode(_blob);
  }

  /** Get the full data (using the specified store) */
  function get(IStore _store) internal view returns (GameConfigData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](0);

    bytes memory _blob = _store.getRecord(_tableId, _keyTuple, getSchema());
    return decode(_blob);
  }

  /** Set the full data using individual values */
  function set(Status status, uint256 endTime, uint32 crossWordRewardFraction) internal {
    bytes memory _data = encode(status, endTime, crossWordRewardFraction);

    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.setRecord(_tableId, _keyTuple, _data);
  }

  /** Set the full data using individual values (using the specified store) */
  function set(IStore _store, Status status, uint256 endTime, uint32 crossWordRewardFraction) internal {
    bytes memory _data = encode(status, endTime, crossWordRewardFraction);

    bytes32[] memory _keyTuple = new bytes32[](0);

    _store.setRecord(_tableId, _keyTuple, _data);
  }

  /** Set the full data using the data struct */
  function set(GameConfigData memory _table) internal {
    set(_table.status, _table.endTime, _table.crossWordRewardFraction);
  }

  /** Set the full data using the data struct (using the specified store) */
  function set(IStore _store, GameConfigData memory _table) internal {
    set(_store, _table.status, _table.endTime, _table.crossWordRewardFraction);
  }

  /** Decode the tightly packed blob using this table's schema */
  function decode(bytes memory _blob) internal pure returns (GameConfigData memory _table) {
    _table.status = Status(uint8(Bytes.slice1(_blob, 0)));

    _table.endTime = (uint256(Bytes.slice32(_blob, 1)));

    _table.crossWordRewardFraction = (uint32(Bytes.slice4(_blob, 33)));
  }

  /** Tightly pack full data using this table's schema */
  function encode(Status status, uint256 endTime, uint32 crossWordRewardFraction) internal pure returns (bytes memory) {
    return abi.encodePacked(status, endTime, crossWordRewardFraction);
  }

  /** Encode keys as a bytes32 array using this table's schema */
  function encodeKeyTuple() internal pure returns (bytes32[] memory _keyTuple) {
    _keyTuple = new bytes32[](0);
  }

  /* Delete all data for given keys */
  function deleteRecord() internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    StoreSwitch.deleteRecord(_tableId, _keyTuple);
  }

  /* Delete all data for given keys (using the specified store) */
  function deleteRecord(IStore _store) internal {
    bytes32[] memory _keyTuple = new bytes32[](0);

    _store.deleteRecord(_tableId, _keyTuple);
  }
}

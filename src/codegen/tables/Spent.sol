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

bytes32 constant _tableId = bytes32(abi.encodePacked(bytes16(""), bytes16("Spent")));
bytes32 constant SpentTableId = _tableId;

library Spent {
  /** Get the table's schema */
  function getSchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](1);
    _schema[0] = SchemaType.UINT256;

    return SchemaLib.encode(_schema);
  }

  function getKeySchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](3);
    _schema[0] = SchemaType.ADDRESS;
    _schema[1] = SchemaType.UINT256;
    _schema[2] = SchemaType.UINT256;

    return SchemaLib.encode(_schema);
  }

  /** Get the table's metadata */
  function getMetadata() internal pure returns (string memory, string[] memory) {
    string[] memory _fieldNames = new string[](1);
    _fieldNames[0] = "value";
    return ("Spent", _fieldNames);
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

  /** Emit the ephemeral event using individual values */
  function emitEphemeral(address player, uint256 id, uint256 time, uint256 value) internal {
    bytes memory _data = encode(value);

    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = bytes32(uint256(uint160(player)));
    _keyTuple[1] = bytes32(uint256(id));
    _keyTuple[2] = bytes32(uint256(time));

    StoreSwitch.emitEphemeralRecord(_tableId, _keyTuple, _data);
  }

  /** Emit the ephemeral event using individual values (using the specified store) */
  function emitEphemeral(IStore _store, address player, uint256 id, uint256 time, uint256 value) internal {
    bytes memory _data = encode(value);

    bytes32[] memory _keyTuple = new bytes32[](3);
    _keyTuple[0] = bytes32(uint256(uint160(player)));
    _keyTuple[1] = bytes32(uint256(id));
    _keyTuple[2] = bytes32(uint256(time));

    _store.emitEphemeralRecord(_tableId, _keyTuple, _data);
  }

  /** Tightly pack full data using this table's schema */
  function encode(uint256 value) internal view returns (bytes memory) {
    return abi.encodePacked(value);
  }

  /** Encode keys as a bytes32 array using this table's schema */
  function encodeKeyTuple(address player, uint256 id, uint256 time) internal pure returns (bytes32[] memory _keyTuple) {
    _keyTuple = new bytes32[](3);
    _keyTuple[0] = bytes32(uint256(uint160(player)));
    _keyTuple[1] = bytes32(uint256(id));
    _keyTuple[2] = bytes32(uint256(time));
  }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {DEBUG_UNGATE_WORLD} from "common/Constants.sol";
import {Stop} from "common/Errors.sol";

import {World} from "@latticexyz/world/src/World.sol";

contract GatedWorld is World {
    function setRecord(bytes16 namespace, bytes16 name, bytes32[] calldata key, bytes calldata data) public override {
        if (DEBUG_UNGATE_WORLD) {
            super.setRecord(namespace, name, key, data);
        } else {
            revert Stop();
        }
    }

    function setField(bytes16 namespace, bytes16 name, bytes32[] calldata key, uint8 schemaIndex, bytes calldata data)
        public
        override
    {
        if (DEBUG_UNGATE_WORLD) {
            super.setField(namespace, name, key, schemaIndex, data);
        } else {
            revert Stop();
        }
    }

    function pushToField(
        bytes16 namespace,
        bytes16 name,
        bytes32[] calldata key,
        uint8 schemaIndex,
        bytes calldata dataToPush
    ) public pure override {
        revert Stop();
    }

    function popFromField(
        bytes16 namespace,
        bytes16 name,
        bytes32[] calldata key,
        uint8 schemaIndex,
        uint256 byteLengthToPop
    ) public pure override {
        revert Stop();
    }

    function updateInField(
        bytes16 namespace,
        bytes16 name,
        bytes32[] calldata key,
        uint8 schemaIndex,
        uint256 startByteIndex,
        bytes calldata dataToSet
    ) public pure override {
        revert Stop();
    }

    function deleteRecord(bytes16 namespace, bytes16 name, bytes32[] calldata key) public pure override {
        revert Stop();
    }
}

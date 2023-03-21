// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0;

import {System, IWorld} from "solecs/System.sol";
import {getAddressById} from "solecs/utils.sol";

import {TileComponent, ID as TileComponentID} from "components/TileComponent.sol";
import {LibBoard} from "libraries/LibBoard.sol";

uint256 constant ID = uint256(keccak256("system.SetupBoard"));

contract SetupBoardSystem is System {
    constructor(
        IWorld _world,
        address _components
    ) System(_world, _components) {}

    function execute(bytes memory) public returns (bytes memory) {
        TileComponent tileComponent = TileComponent(
            getAddressById(components, TileComponentID)
        );
        LibBoard.playInfinite(tileComponent);
    }

    function executeTyped() public returns (bytes memory) {
        return execute(abi.encode());
    }
}

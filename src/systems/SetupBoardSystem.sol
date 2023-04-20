// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0;

import {System, IWorld} from "solecs/System.sol";
import {getAddressById} from "solecs/utils.sol";

import {LetterWeightComponent, ID as LetterWeightComponentID} from "components/LetterWeightComponent.sol";
import {TileComponent, ID as TileComponentID} from "components/TileComponent.sol";
import {AlreadySetupGrid} from "common/Errors.sol";
import {LibBoard} from "libraries/LibBoard.sol";
import {LibPrice} from "libraries/LibPrice.sol";

uint256 constant ID = uint256(keccak256("system.SetupBoard"));

contract SetupBoardSystem is System {
    bool private setup = false;

    constructor(
        IWorld _world,
        address _components
    ) System(_world, _components) {}

    function execute(bytes memory) public returns (bytes memory) {
        if (setup) {
            revert AlreadySetupGrid();
        }
        setup = true;
        TileComponent tileComponent = TileComponent(
            getAddressById(components, TileComponentID)
        );
        LetterWeightComponent letterWeightComponent = LetterWeightComponent(
            getAddressById(components, LetterWeightComponentID)
        );
        LibBoard.playInfinite(tileComponent);
        LibPrice.setupLetterWeights(letterWeightComponent);
    }

    function executeTyped() public returns (bytes memory) {
        return execute(abi.encode());
    }
}

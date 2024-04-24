// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { IWorld } from "codegen/world/IWorld.sol";

contract HelperSystem is System {
    function instantDraw(address player) public payable {
        IWorld world = IWorld(_world());
        uint256 id = world.words3__requestDraw({player: player});
        world.words3__fulfillDraw({id: id});
    }
}

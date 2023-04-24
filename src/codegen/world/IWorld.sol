// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

import { IBaseWorld } from "@latticexyz/world/src/interfaces/IBaseWorld.sol";

import { IBoardSystem } from "./IBoardSystem.sol";
import { IPlaceTileSystem } from "./IPlaceTileSystem.sol";
import { ISetupBoardSystem } from "./ISetupBoardSystem.sol";

/**
 * The IWorld interface includes all systems dynamically added to the World
 * during the deploy process.
 */
interface IWorld is IBaseWorld, IBoardSystem, IPlaceTileSystem, ISetupBoardSystem {

}
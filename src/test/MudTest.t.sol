// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import { DSTest } from "ds-test/test.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { Cheats } from "./utils/Cheats.sol";
import { Utilities } from "./utils/Utilities.sol";
import { Deploy } from "./utils/Deploy.sol";
import { componentsComponentId, systemsComponentId } from "solecs/constants.sol";
import { getAddressById } from "solecs/utils.sol";
import { console } from "forge-std/console.sol";

contract MudTest is DSTest {
  Cheats internal immutable vm = Cheats(HEVM_ADDRESS);
  Utilities internal immutable utils = new Utilities();

  address payable internal alice;
  address payable internal bob;
  address payable internal eve;
  address internal deployer;

  IWorld internal world;
  IUint256Component internal components;
  IUint256Component internal systems;
  Deploy internal deploy = new Deploy();

  modifier prank(address sender) {
    vm.startPrank(sender);
    _;
    vm.stopPrank();
  }

  function component(uint256 id) public view returns (address) {
    return getAddressById(components, id);
  }

  function system(uint256 id) public view returns (address) {
    return getAddressById(systems, id);
  }

  function setUp() public virtual {
    world = deploy.deploy(address(0), address(0), false);
    components = world.components();
    systems = world.systems();
    deployer = deploy.deployer();
    alice = utils.getNextUserAddress();
    bob = utils.getNextUserAddress();
    eve = utils.getNextUserAddress();
  }
}

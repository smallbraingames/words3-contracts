// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IWorld} from "codegen/world/IWorld.sol";
import {VRGDAConfig, VRGDAConfigData, GameConfig, GameConfigData, MerkleRootConfig} from "codegen/Tables.sol";
import {Status, Letter} from "codegen/Types.sol";

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {ResourceSelector} from "@latticexyz/world/src/ResourceSelector.sol";

contract PostDeploy is Script {
    function run(address worldAddress) external {
        // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        // vm.startBroadcast(deployerPrivateKey);

        // IWorld world = IWorld(worldAddress);

        // Letter[] memory infinite = new Letter[](8);
        // infinite[0] = Letter.I;
        // infinite[1] = Letter.N;
        // infinite[2] = Letter.F;
        // infinite[3] = Letter.I;
        // infinite[4] = Letter.N;
        // infinite[5] = Letter.I;
        // infinite[6] = Letter.T;
        // infinite[7] = Letter.E;
        // world.start(
        //     infinite,
        //     block.timestamp + 3600 * 20,
        //     0xacd24e8edae5cf4cdbc3ce0c196a670cbea1dbf37576112b0a3defac3318b432,
        //     5e14,
        //     95e16,
        //     20e18,
        //     3
        // );

        // vm.stopBroadcast();
    }
}

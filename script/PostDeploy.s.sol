// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Letter, Status } from "codegen/common.sol";
import { GameConfig, GameConfigData, MerkleRootConfig, VRGDAConfig, VRGDAConfigData } from "codegen/index.sol";
import { IWorld } from "codegen/world/IWorld.sol";

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

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

        // world.start({
        //     initialWord: infinite,
        //     endTime: block.timestamp + 3600 * 20,
        //     maxPlayerSpend: 0,
        //     merkleRoot: 0xacd24e8edae5cf4cdbc3ce0c196a670cbea1dbf37576112b0a3defac3318b432,
        //     vrgdaTargetPrice: 5e14,
        //     vrgdaPriceDecay: 5e17,
        //     vrgdaPerDayInitial: 3e18,
        //     vrgdaPower: 2e18,
        //     host: address(0),
        //     crossWordRewardFraction: 3,
        //     hostFeeBps: 0
        // });

        // vm.stopBroadcast();
    }
}

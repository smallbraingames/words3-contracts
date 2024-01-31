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
        //     endTime: block.timestamp + 45 * 60,
        //     maxPlayerSpend: 0.5 ether,
        //     merkleRoot: 0xacd24e8edae5cf4cdbc3ce0c196a670cbea1dbf37576112b0a3defac3318b432,
        //     vrgdaTargetPrice: 25e13,
        //     vrgdaPriceDecay: 99999e13,
        //     vrgdaPerDayInitial: 800e18,
        //     vrgdaPower: 1e18,
        //     host: address(0x817a70B945DdaAFD58D71adF66fE9A82fCCaa049),
        //     crossWordRewardFraction: 3,
        //     hostFeeBps: 1_000
        // });

        // vm.stopBroadcast();
    }
}

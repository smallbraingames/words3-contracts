// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Letter, Status } from "codegen/common.sol";
import { GameConfig, GameConfigData, MerkleRootConfig, VRGDAConfig, VRGDAConfigData } from "codegen/index.sol";
import { IWorld } from "codegen/world/IWorld.sol";

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

contract PostDeploy is Script {
    function run(address worldAddress) external {
        IWorld world = IWorld(worldAddress);

        /// START GAME

        // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        // vm.startBroadcast(deployerPrivateKey);

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
        //     merkleRoot: 0xacd24e8edae5cf4cdbc3ce0c196a670cbea1dbf37576112b0a3defac3318b432,
        //     vrgdaTargetPrice: 40e13,
        //     vrgdaPriceDecay: 99_999e13,
        //     vrgdaPerDayInitial: 700e18,
        //     vrgdaPower: 1e18,
        //     crossWordRewardFraction: 3,
        //     bonusDistance: 10
        // });

        // /// SET ODDS

        // uint8[] memory odds = new uint8[](27);
        // odds[0] = 0;
        // odds[uint8(Letter.A)] = 9;
        // odds[uint8(Letter.B)] = 2;
        // odds[uint8(Letter.C)] = 2;
        // odds[uint8(Letter.D)] = 4;
        // odds[uint8(Letter.E)] = 12;
        // odds[uint8(Letter.F)] = 2;
        // odds[uint8(Letter.G)] = 3;
        // odds[uint8(Letter.H)] = 2;
        // odds[uint8(Letter.I)] = 9;
        // odds[uint8(Letter.J)] = 1;
        // odds[uint8(Letter.K)] = 1;
        // odds[uint8(Letter.L)] = 4;
        // odds[uint8(Letter.M)] = 2;
        // odds[uint8(Letter.N)] = 6;
        // odds[uint8(Letter.O)] = 8;
        // odds[uint8(Letter.P)] = 2;
        // odds[uint8(Letter.Q)] = 1;
        // odds[uint8(Letter.R)] = 6;
        // odds[uint8(Letter.S)] = 4;
        // odds[uint8(Letter.T)] = 6;
        // odds[uint8(Letter.U)] = 4;
        // odds[uint8(Letter.V)] = 2;
        // odds[uint8(Letter.W)] = 2;
        // odds[uint8(Letter.X)] = 1;
        // odds[uint8(Letter.Y)] = 2;
        // odds[uint8(Letter.Z)] = 1;

        // world.setDrawLetterOdds(odds);

        // vm.stopBroadcast();
    }
}

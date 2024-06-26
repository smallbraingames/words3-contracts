// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Letter } from "codegen/common.sol";

import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { ROOT_NAMESPACE } from "@latticexyz/world/src/constants.sol";
import { FeeConfigData, PriceConfigData } from "codegen/index.sol";
import { IWorld } from "codegen/world/IWorld.sol";

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

contract PostDeploy is Script {
    function run(address worldAddress) external {
        IWorld world = IWorld(worldAddress);

        // START GAME
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Letter[] memory words = new Letter[](5);
        words[0] = Letter.W;
        words[1] = Letter.O;
        words[2] = Letter.R;
        words[3] = Letter.D;
        words[4] = Letter.S;

        uint32[26] memory initialLetterAllocation;
        for (uint8 i = 0; i < 26; i++) {
            initialLetterAllocation[i] = 350;
        }

        world.start({
            initialWord: words,
            initialLetterAllocation: initialLetterAllocation,
            initialLettersTo: address(0xA9656f80CF8fba7618455e1c904EA30aA6C70F94),
            merkleRoot: 0xacd24e8edae5cf4cdbc3ce0c196a670cbea1dbf37576112b0a3defac3318b432,
            initialPrice: 0.0015 ether,
            claimRestrictionDurationBlocks: 0,
            priceConfig: PriceConfigData({
                minPrice: 0.001 ether,
                wadPriceIncreaseFactor: 1.115e18,
                wadPower: 0.95e18,
                wadScale: 1.1715e37
            }),
            feeConfig: FeeConfigData({ feeBps: 690, feeTaker: address(0x7078272d7AbB477aed006190678054bB654815f4) }),
            crossWordRewardFraction: 3,
            bonusDistance: 4,
            numDrawLetters: 7
        });

        /// SET ODDS

        uint8[] memory odds = new uint8[](27);
        odds[0] = 0;
        odds[uint8(Letter.A)] = 9;
        odds[uint8(Letter.B)] = 2;
        odds[uint8(Letter.C)] = 2;
        odds[uint8(Letter.D)] = 4;
        odds[uint8(Letter.E)] = 12;
        odds[uint8(Letter.F)] = 2;
        odds[uint8(Letter.G)] = 3;
        odds[uint8(Letter.H)] = 2;
        odds[uint8(Letter.I)] = 9;
        odds[uint8(Letter.J)] = 1;
        odds[uint8(Letter.K)] = 1;
        odds[uint8(Letter.L)] = 4;
        odds[uint8(Letter.M)] = 2;
        odds[uint8(Letter.N)] = 6;
        odds[uint8(Letter.O)] = 8;
        odds[uint8(Letter.P)] = 2;
        odds[uint8(Letter.Q)] = 1;
        odds[uint8(Letter.R)] = 6;
        odds[uint8(Letter.S)] = 4;
        odds[uint8(Letter.T)] = 6;
        odds[uint8(Letter.U)] = 4;
        odds[uint8(Letter.V)] = 2;
        odds[uint8(Letter.W)] = 2;
        odds[uint8(Letter.X)] = 1;
        odds[uint8(Letter.Y)] = 2;
        odds[uint8(Letter.Z)] = 1;

        world.setDrawLetterOdds(odds);

        // SET ROOT OWNER

        address latticeOwner = address(0xa726A58346e27616b56C6EF9Fccd1241E5EbFbb1);
        world.transferOwnership(WorldResourceIdLib.encodeNamespace(ROOT_NAMESPACE), latticeOwner);

        vm.stopBroadcast();
    }
}

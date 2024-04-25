// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;
/* solhint-disable no-global-import */
/* solhint-disable func-name-mixedcase */

import { Status } from "codegen/common.sol";
import { GameConfig, MerkleRootConfig, VRGDAConfig } from "codegen/index.sol";
import { IWorld } from "codegen/world/IWorld.sol";
import { LibGame } from "libraries/LibGame.sol";
import { Words3Test } from "../Words3Test.t.sol";
import "forge-std/Test.sol";

contract LibGameTest is Words3Test {

    function test_CanPlay() public {
        assertFalse(LibGame.canPlay());
        vm.startPrank(deployerAddress);
        GameConfig.setStatus(Status.STARTED);
        vm.stopPrank();
        assertTrue(LibGame.canPlay());
    }

    function testFuzzStartGame(
        bytes32 merkleRoot,
        int256 vrgdaTargetPrice,
        int256 vrgdaPriceDecay,
        int256 vrgdaPerDayInitial,
        int256 vrgdaPower,
        uint32 crossWordRewardFraction,
        uint16 bonusDistance,
        uint8 numDrawLetters
    )
        public
    {
        vm.startPrank(deployerAddress);
        LibGame.startGame(
            merkleRoot, vrgdaTargetPrice, vrgdaPriceDecay, vrgdaPerDayInitial, vrgdaPower, crossWordRewardFraction,
            bonusDistance, numDrawLetters
        );
        vm.stopPrank();
        assertEq(merkleRoot, MerkleRootConfig.get());
        assertEq(vrgdaTargetPrice, VRGDAConfig.getTargetPrice());
        assertEq(vrgdaPriceDecay, VRGDAConfig.getPriceDecay());
        assertEq(vrgdaPerDayInitial, VRGDAConfig.getPerDayInitial());
        assertEq(vrgdaPower, VRGDAConfig.getPower());
        assertEq(crossWordRewardFraction, GameConfig.getCrossWordRewardFraction());
        assertEq(bonusDistance, GameConfig.getBonusDistance());
        assertEq(numDrawLetters, GameConfig.getNumDrawLetters());
    }
}

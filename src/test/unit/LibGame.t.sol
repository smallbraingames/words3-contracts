// // SPDX-License-Identifier: MIT
// pragma solidity >=0.8.24;
// /* solhint-disable no-global-import */
// /* solhint-disable func-name-mixedcase */

// import { Words3Test } from "../Words3Test.t.sol";
// import { Status } from "codegen/common.sol";
// import {
//     DrawLastSold, FeeConfigData, GameConfig, MerkleRootConfig, PriceConfig, PriceConfigData
// } from "codegen/index.sol";
// import "forge-std/Test.sol";
// import { LibGame } from "libraries/LibGame.sol";

// contract LibGameTest is Words3Test {
//     function test_CanPlay() public {
//         assertFalse(LibGame.canPlay());
//         vm.startPrank(deployerAddress);
//         GameConfig.setStatus(Status.STARTED);
//         vm.stopPrank();
//         assertTrue(LibGame.canPlay());
//     }

//     function testFuzz_StartGame(
//         bytes32 merkleRoot,
//         uint256 initialPrice,
//         uint256 minPrice,
//         int256 wadFactor,
//         int256 wadDurationRoot,
//         int256 wadDurationScale,
//         int256 wadDurationConstant,
//         uint32 crossWordRewardFraction,
//         uint16 bonusDistance,
//         uint8 numDrawLetters
//     )
//         public
//     {
//         vm.startPrank(deployerAddress);
//         LibGame.startGame({
//             merkleRoot: merkleRoot,
//             initialPrice: initialPrice,
//             claimRestrictionDurationBlocks: 0,
//             priceConfig: PriceConfigData({
//                 minPrice: minPrice,
//                 wadFactor: wadFactor,
//                 wadDurationRoot: wadDurationRoot,
//                 wadDurationScale: wadDurationScale,
//                 wadDurationConstant: wadDurationConstant
//             }),
//             feeConfig: FeeConfigData({ feeBps: 0, feeTaker: address(0) }),
//             crossWordRewardFraction: crossWordRewardFraction,
//             bonusDistance: bonusDistance,
//             numDrawLetters: numDrawLetters
//         });
//         vm.stopPrank();
//         assertEq(merkleRoot, MerkleRootConfig.get());
//         assertEq(minPrice, PriceConfig.getMinPrice());
//         assertEq(wadDurationRoot, PriceConfig.getWadDurationRoot());
//         assertEq(wadDurationScale, PriceConfig.getWadDurationScale());
//         assertEq(wadDurationConstant, PriceConfig.getWadDurationConstant());
//         assertEq(initialPrice, DrawLastSold.getPrice());
//         assertEq(block.number, DrawLastSold.getBlockNumber());
//         assertEq(crossWordRewardFraction, GameConfig.getCrossWordRewardFraction());
//         assertEq(bonusDistance, GameConfig.getBonusDistance());
//         assertEq(numDrawLetters, GameConfig.getNumDrawLetters());
//     }
// }

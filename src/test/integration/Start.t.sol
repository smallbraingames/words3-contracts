// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;
/* solhint-disable no-global-import */
/* solhint-disable func-name-mixedcase */

import { Words3Test } from "../Words3Test.t.sol";
import { Letter } from "codegen/common.sol";

import {
    DrawLastSold, FeeConfigData, GameConfig, MerkleRootConfig, PriceConfig, PriceConfigData
} from "codegen/index.sol";
import { Coord } from "common/Coord.sol";
import "forge-std/Test.sol";

import { LibGame } from "libraries/LibGame.sol";
import { LibTile } from "libraries/LibTile.sol";
import { StartSystem } from "systems/StartSystem.sol";

contract StartTest is Words3Test {
    function testFuzz_SystemStartGame(
        bytes32 merkleRoot,
        uint256 initialPrice,
        int256 wadScale,
        int256 wadPower,
        uint32 crossWordRewardFraction,
        uint16 bonusDistance,
        uint8 numDrawLetters
    )
        public
    {
        uint32[26] memory initialLetterAllocation;
        world.start({
            initialWord: new Letter[](0),
            initialLetterAllocation: initialLetterAllocation,
            initialLettersTo: address(0),
            merkleRoot: merkleRoot,
            initialPrice: initialPrice,
            claimRestrictionDurationBlocks: 0,
            priceConfig: PriceConfigData({
                minPrice: 3,
                wadPriceIncreaseFactor: 1.1e18,
                wadPower: wadPower,
                wadScale: wadScale
            }),
            feeConfig: FeeConfigData({ feeBps: 0, feeTaker: address(0) }),
            crossWordRewardFraction: crossWordRewardFraction,
            bonusDistance: bonusDistance,
            numDrawLetters: numDrawLetters
        });
        assertEq(merkleRoot, MerkleRootConfig.get());
        assertEq(3, PriceConfig.getMinPrice());
        assertEq(wadScale, PriceConfig.getWadScale());
        assertEq(wadPower, PriceConfig.getWadPower());
        assertEq(initialPrice, DrawLastSold.getPrice());
        assertEq(block.number, DrawLastSold.getBlockNumber());
        assertEq(crossWordRewardFraction, GameConfig.getCrossWordRewardFraction());
        assertEq(bonusDistance, GameConfig.getBonusDistance());
        assertEq(numDrawLetters, GameConfig.getNumDrawLetters());
        assertTrue(LibGame.canPlay());
    }

    function testFuzz_InitialWordOffset(uint256 offset) public {
        offset = bound(offset, 1, 25);
        Letter[] memory initialWord = new Letter[](offset * 2);
        for (uint256 i = 0; i < initialWord.length; i++) {
            initialWord[i] = Letter.A;
        }
        uint32[26] memory initialLetterAllocation;
        world.start({
            initialWord: initialWord,
            initialLetterAllocation: initialLetterAllocation,
            initialLettersTo: address(0),
            merkleRoot: keccak256("merkleRoot"),
            initialPrice: 1,
            claimRestrictionDurationBlocks: 0,
            priceConfig: PriceConfigData({
                minPrice: 0.001 ether,
                wadPriceIncreaseFactor: 1.115e18,
                wadPower: 0.9e18,
                wadScale: 9.96e36
            }),
            feeConfig: FeeConfigData({ feeBps: 0, feeTaker: address(0) }),
            crossWordRewardFraction: 1,
            bonusDistance: 1,
            numDrawLetters: 1
        });
        for (uint256 i = 0; i < initialWord.length; i++) {
            assertEq(
                uint8(LibTile.getLetter({ coord: Coord({ x: int32(uint32(i)) - int32(uint32(offset)), y: 0 }) })),
                uint8(Letter.A)
            );
        }
    }

    function test_RevertsWhen_StartTwice() public {
        uint32[26] memory initialLetterAllocation;

        world.start({
            initialWord: new Letter[](0),
            initialLetterAllocation: initialLetterAllocation,
            initialLettersTo: address(0),
            merkleRoot: keccak256("merkleRoot"),
            initialPrice: 1,
            claimRestrictionDurationBlocks: 0,
            priceConfig: PriceConfigData({
                minPrice: 0.001 ether,
                wadPriceIncreaseFactor: 1.115e18,
                wadPower: 0.9e18,
                wadScale: 9.96e36
            }),
            feeConfig: FeeConfigData({ feeBps: 0, feeTaker: address(0) }),
            crossWordRewardFraction: 1,
            bonusDistance: 1,
            numDrawLetters: 1
        });
        vm.expectRevert(StartSystem.GameAlreadyStarted.selector);
        world.start({
            initialWord: new Letter[](0),
            initialLetterAllocation: initialLetterAllocation,
            initialLettersTo: address(0),
            merkleRoot: keccak256("merkleRoot"),
            initialPrice: 1,
            claimRestrictionDurationBlocks: 0,
            priceConfig: PriceConfigData({
                minPrice: 0.001 ether,
                wadPriceIncreaseFactor: 1.115e18,
                wadPower: 0.9e18,
                wadScale: 9.96e36
            }),
            feeConfig: FeeConfigData({ feeBps: 0, feeTaker: address(0) }),
            crossWordRewardFraction: 1,
            bonusDistance: 1,
            numDrawLetters: 1
        });
    }

    function test_RevertsWhen_InitialWordTooLong() public {
        uint32[26] memory initialLetterAllocation;

        vm.expectRevert(StartSystem.InitialWordTooLong.selector);
        world.start({
            initialWord: new Letter[](90),
            initialLetterAllocation: initialLetterAllocation,
            initialLettersTo: address(0),
            merkleRoot: keccak256("merkleRoot"),
            initialPrice: 1,
            claimRestrictionDurationBlocks: 0,
            priceConfig: PriceConfigData({
                minPrice: 0.001 ether,
                wadPriceIncreaseFactor: 1.115e18,
                wadPower: 0.9e18,
                wadScale: 9.96e36
            }),
            feeConfig: FeeConfigData({ feeBps: 0, feeTaker: address(0) }),
            crossWordRewardFraction: 1,
            bonusDistance: 1,
            numDrawLetters: 1
        });
    }
}

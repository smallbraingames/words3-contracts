// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;
/* solhint-disable no-global-import */
/* solhint-disable func-name-mixedcase */

import { Words3Test } from "../Words3Test.t.sol";
import { Letter } from "codegen/common.sol";

import { DrawLastSold, GameConfig, MerkleRootConfig, PriceConfig } from "codegen/index.sol";
import { Coord } from "common/Coord.sol";
import "forge-std/Test.sol";

import { LibGame } from "libraries/LibGame.sol";
import { LibTile } from "libraries/LibTile.sol";
import { StartSystem } from "systems/StartSystem.sol";

contract StartTest is Words3Test {
    function testFuzz_SystemStartGame(
        bytes32 merkleRoot,
        uint256 initialPrice,
        uint256 minPrice,
        int256 wadFactor,
        int256 wadDurationRoot,
        int256 wadDurationScale,
        int256 wadDurationConstant,
        uint32 crossWordRewardFraction,
        uint16 bonusDistance,
        uint8 numDrawLetters
    )
        public
    {
        world.start({
            initialWord: new Letter[](0),
            merkleRoot: merkleRoot,
            initialPrice: initialPrice,
            minPrice: minPrice,
            wadFactor: wadFactor,
            wadDurationRoot: wadDurationRoot,
            wadDurationScale: wadDurationScale,
            wadDurationConstant: wadDurationConstant,
            crossWordRewardFraction: crossWordRewardFraction,
            bonusDistance: bonusDistance,
            numDrawLetters: numDrawLetters
        });
        assertEq(merkleRoot, MerkleRootConfig.get());
        assertEq(minPrice, PriceConfig.getMinPrice());
        assertEq(wadDurationRoot, PriceConfig.getWadDurationRoot());
        assertEq(wadDurationScale, PriceConfig.getWadDurationScale());
        assertEq(wadDurationConstant, PriceConfig.getWadDurationConstant());
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
        world.start({
            initialWord: initialWord,
            merkleRoot: keccak256("merkleRoot"),
            initialPrice: 1,
            minPrice: 1,
            wadFactor: 1,
            wadDurationRoot: 1,
            wadDurationScale: 1,
            wadDurationConstant: 1,
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
        world.start({
            initialWord: new Letter[](0),
            merkleRoot: keccak256("merkleRoot"),
            initialPrice: 1,
            minPrice: 1,
            wadFactor: 1,
            wadDurationRoot: 1,
            wadDurationScale: 1,
            wadDurationConstant: 1,
            crossWordRewardFraction: 1,
            bonusDistance: 1,
            numDrawLetters: 1
        });
        vm.expectRevert(StartSystem.GameAlreadyStarted.selector);
        world.start({
            initialWord: new Letter[](0),
            merkleRoot: keccak256("merkleRoot"),
            initialPrice: 1,
            minPrice: 1,
            wadFactor: 1,
            wadDurationRoot: 1,
            wadDurationScale: 1,
            wadDurationConstant: 1,
            crossWordRewardFraction: 1,
            bonusDistance: 1,
            numDrawLetters: 1
        });
    }

    function test_RevertsWhen_InitialWordTooLong() public {
        vm.expectRevert(StartSystem.InitialWordTooLong.selector);
        world.start({
            initialWord: new Letter[](90),
            merkleRoot: keccak256("merkleRoot"),
            initialPrice: 1,
            minPrice: 1,
            wadFactor: 1,
            wadDurationRoot: 1,
            wadDurationScale: 1,
            wadDurationConstant: 1,
            crossWordRewardFraction: 1,
            bonusDistance: 1,
            numDrawLetters: 1
        });
    }
}

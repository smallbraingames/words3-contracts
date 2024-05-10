// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;
/* solhint-disable no-global-import */
/* solhint-disable func-name-mixedcase */

import { Words3Test } from "../Words3Test.t.sol";
import { Merkle } from "../murky/src/Merkle.sol";
import { Direction, Letter } from "codegen/common.sol";
import { PriceConfigData, TileLetter } from "codegen/index.sol";
import { IWorld } from "codegen/world/IWorld.sol";
import { Bound } from "common/Bound.sol";
import { Coord } from "common/Coord.sol";
import "forge-std/Test.sol";

contract SimpleWord is Words3Test {
    bytes32[] private words;
    Merkle private m;
    Letter[] private initialWord;

    function setUp() public override {
        super.setUp();
        world = IWorld(worldAddress);

        m = new Merkle();
        Letter[] memory hi = new Letter[](2);
        hi[0] = Letter.H;
        hi[1] = Letter.I;
        Letter[] memory go = new Letter[](2);
        go[0] = Letter.G;
        go[1] = Letter.O;
        words.push(keccak256(bytes.concat(keccak256(abi.encode(hi))))); // hi
        words.push(keccak256(bytes.concat(keccak256(abi.encode(go))))); // go

        setDefaultLetterOdds();
    }

    function test_Setup() public {
        initialWord = new Letter[](2);
        initialWord[0] = Letter.H;
        initialWord[1] = Letter.I;

        uint32[26] memory initialLetterAllocation;
        world.start({
            initialWord: initialWord,
            initialLetterAllocation: initialLetterAllocation,
            initialLettersTo: address(0),
            merkleRoot: m.getRoot(words),
            initialPrice: 0.001 ether,
            claimRestrictionDurationBlocks: 0,
            priceConfig: PriceConfigData({
                minPrice: 0.0001 ether,
                wadFactor: 1.3e18,
                wadDurationRoot: 2e18,
                wadDurationScale: 3000e18,
                wadDurationConstant: 0
            }),
            crossWordRewardFraction: 3,
            bonusDistance: 10,
            numDrawLetters: 7
        });
        assertEq(uint8(TileLetter.get(-1, 0)), uint8(Letter.H));
        assertEq(uint8(TileLetter.get(0, 0)), uint8(Letter.I));
    }

    function test_PlayHi() public {
        initialWord = new Letter[](2);
        initialWord[0] = Letter.H;
        initialWord[1] = Letter.I;

        uint32[26] memory initialLetterAllocation;
        world.start({
            initialWord: initialWord,
            initialLetterAllocation: initialLetterAllocation,
            initialLettersTo: address(0),
            merkleRoot: m.getRoot(words),
            initialPrice: 0.001 ether,
            claimRestrictionDurationBlocks: 0,
            priceConfig: PriceConfigData({
                minPrice: 0.0001 ether,
                wadFactor: 1.3e18,
                wadDurationRoot: 2e18,
                wadDurationScale: 3000e18,
                wadDurationConstant: 0
            }),
            crossWordRewardFraction: 3,
            bonusDistance: 3,
            numDrawLetters: 8
        });

        Letter[] memory word = new Letter[](2);
        word[0] = Letter.EMPTY;
        word[1] = Letter.I;
        Bound[] memory bounds = new Bound[](2);
        bytes32[] memory proof = m.getProof(words, 0);

        address player = address(0x123);
        vm.startPrank(player);
        for (uint256 i = 0; i < 50; i++) {
            uint256 price = world.getDrawPrice();
            vm.deal(player, price);
            vm.roll(block.number + 100);
            world.draw{ value: price }(player);
        }
        world.play(word, proof, Coord({ x: -1, y: 0 }), Direction.TOP_TO_BOTTOM, bounds);
        vm.stopPrank();
    }

    function test_MultipleDraws() public {
        uint32[26] memory initialLetterAllocation;
        world.start({
            initialWord: initialWord,
            initialLetterAllocation: initialLetterAllocation,
            initialLettersTo: address(0),
            merkleRoot: m.getRoot(words),
            initialPrice: 0.001 ether,
            claimRestrictionDurationBlocks: 0,
            priceConfig: PriceConfigData({
                minPrice: 0.0001 ether,
                wadFactor: 1.3e18,
                wadDurationRoot: 2e18,
                wadDurationScale: 3000e18,
                wadDurationConstant: 0
            }),
            crossWordRewardFraction: 3,
            bonusDistance: 10,
            numDrawLetters: 7
        });

        address player = address(0x123);
        vm.deal(player, 50 ether);
        vm.startPrank(player);

        world.draw{ value: world.getDrawPrice() }(player);
        world.draw{ value: world.getDrawPrice() }(player);
        vm.roll(block.number + 5);
        world.draw{ value: world.getDrawPrice() }(player);
        vm.roll(block.number + 10);
        world.draw{ value: world.getDrawPrice() }(player);
        world.draw{ value: world.getDrawPrice() }(player);
        world.draw{ value: world.getDrawPrice() }(player);
        vm.roll(block.number + 10);
        world.draw{ value: world.getDrawPrice() }(player);
        world.draw{ value: world.getDrawPrice() }(player);
        world.draw{ value: world.getDrawPrice() }(player);
        world.draw{ value: world.getDrawPrice() }(player);
        world.draw{ value: world.getDrawPrice() }(player);
        vm.roll(block.number + 3);
        world.draw{ value: world.getDrawPrice() }(player);
        world.draw{ value: world.getDrawPrice() }(player);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;
/* solhint-disable no-global-import */
/* solhint-disable func-name-mixedcase */

import { Words3Test } from "../Words3Test.t.sol";
import { Letter } from "codegen/common.sol";
import { FeeConfigData, PlayerLetters, PriceConfigData } from "codegen/index.sol";
import "forge-std/Test.sol";
import { TransferLettersSystem } from "systems/TransferLettersSystem.sol";

contract Transfer is Words3Test {
    function setUp() public override {
        super.setUp();
        setDefaultLetterOdds();
    }

    function test_Transfer() public {
        Letter[] memory initialWord = new Letter[](2);
        initialWord[0] = Letter.H;
        initialWord[1] = Letter.I;
        uint32[26] memory initialLetterAllocation;
        world.start({
            initialWord: initialWord,
            initialLetterAllocation: initialLetterAllocation,
            initialLettersTo: address(0),
            merkleRoot: bytes32(0),
            initialPrice: 0.001 ether,
            claimRestrictionDurationBlocks: 0,
            priceConfig: PriceConfigData({
                minPrice: 0.001 ether,
                wadPriceIncreaseFactor: 1.115e18,
                wadPower: 0.9e18,
                wadScale: 9.96e36
            }),
            feeConfig: FeeConfigData({ feeBps: 0, feeTaker: address(0) }),
            crossWordRewardFraction: 3,
            bonusDistance: 3,
            numDrawLetters: 8
        });

        address player = address(0x123);
        address to = address(0x456);
        vm.startPrank(player);
        for (uint256 i = 0; i < 50; i++) {
            uint256 price = world.getDrawPrice();
            vm.deal(player, price);
            vm.roll(block.number + 100);
            world.draw{ value: price }(player);
        }
        assertEq(PlayerLetters.get({ player: to, letter: Letter.A }), 0);
        Letter[] memory transferLetters = new Letter[](2);
        transferLetters[0] = Letter.A;
        transferLetters[1] = Letter.B;
        world.transfer({ letters: transferLetters, to: to });
        assertEq(PlayerLetters.get({ player: to, letter: Letter.A }), 1);
        assertEq(PlayerLetters.get({ player: to, letter: Letter.B }), 1);
        vm.stopPrank();
    }

    function test_InitialLetterAllocationAndTransfer() public {
        Letter[] memory initialWord = new Letter[](2);
        initialWord[0] = Letter.H;
        initialWord[1] = Letter.I;
        uint32[26] memory initialLetterAllocation;
        initialLetterAllocation[0] = 1; // 1 A
        initialLetterAllocation[1] = 2; // 2 Bs
        initialLetterAllocation[3] = 40; // 40 Ds
        initialLetterAllocation[4] = 50; // 50 Es
        initialLetterAllocation[5] = 60; // 60 Fs
        initialLetterAllocation[25] = 2383; // 2383 Zs

        address initialLettersTo = address(0x123);

        world.start({
            initialWord: initialWord,
            initialLetterAllocation: initialLetterAllocation,
            initialLettersTo: initialLettersTo,
            merkleRoot: bytes32(0),
            initialPrice: 0.001 ether,
            claimRestrictionDurationBlocks: 0,
            priceConfig: PriceConfigData({
                minPrice: 0.001 ether,
                wadPriceIncreaseFactor: 1.115e18,
                wadPower: 0.9e18,
                wadScale: 9.96e36
            }),
            feeConfig: FeeConfigData({ feeBps: 0, feeTaker: address(0) }),
            crossWordRewardFraction: 3,
            bonusDistance: 3,
            numDrawLetters: 8
        });

        // Check to see if initial letters to has the letters
        assertEq(PlayerLetters.get({ player: initialLettersTo, letter: Letter.A }), 1);
        assertEq(PlayerLetters.get({ player: initialLettersTo, letter: Letter.B }), 2);
        assertEq(PlayerLetters.get({ player: initialLettersTo, letter: Letter.D }), 40);
        assertEq(PlayerLetters.get({ player: initialLettersTo, letter: Letter.E }), 50);
        assertEq(PlayerLetters.get({ player: initialLettersTo, letter: Letter.F }), 60);
        assertEq(PlayerLetters.get({ player: initialLettersTo, letter: Letter.Z }), 2383);

        // Transfer some letters to a new player
        address to = address(0x456);
        Letter[] memory transferLetters = new Letter[](2);
        transferLetters[0] = Letter.A;
        transferLetters[1] = Letter.B;
        vm.prank(initialLettersTo);
        world.transfer({ letters: transferLetters, to: to });

        // Check to see if the new player has the letters
        assertEq(PlayerLetters.get({ player: to, letter: Letter.A }), 1);
        assertEq(PlayerLetters.get({ player: to, letter: Letter.B }), 1);

        // Check that the initial allocation player has the correct amount of letters
        assertEq(PlayerLetters.get({ player: initialLettersTo, letter: Letter.A }), 0);
        assertEq(PlayerLetters.get({ player: initialLettersTo, letter: Letter.B }), 1);
        assertEq(PlayerLetters.get({ player: initialLettersTo, letter: Letter.D }), 40);
        assertEq(PlayerLetters.get({ player: initialLettersTo, letter: Letter.E }), 50);
        assertEq(PlayerLetters.get({ player: initialLettersTo, letter: Letter.F }), 60);
        assertEq(PlayerLetters.get({ player: initialLettersTo, letter: Letter.Z }), 2383);
    }

    function test_RevertsWhen_NoLetters() public {
        Letter[] memory initialWord = new Letter[](2);
        initialWord[0] = Letter.H;
        initialWord[1] = Letter.I;
        uint32[26] memory initialLetterAllocation;
        world.start({
            initialWord: initialWord,
            initialLetterAllocation: initialLetterAllocation,
            initialLettersTo: address(0),
            merkleRoot: bytes32(0),
            initialPrice: 0.001 ether,
            claimRestrictionDurationBlocks: 0,
            priceConfig: PriceConfigData({
                minPrice: 0.001 ether,
                wadPriceIncreaseFactor: 1.115e18,
                wadPower: 0.95e18,
                wadScale: 1.1715e37
            }),
            feeConfig: FeeConfigData({ feeBps: 0, feeTaker: address(0) }),
            crossWordRewardFraction: 3,
            bonusDistance: 3,
            numDrawLetters: 8
        });

        address to = address(0x456);
        Letter[] memory transferLetters = new Letter[](2);
        transferLetters[0] = Letter.A;
        transferLetters[1] = Letter.B;
        vm.prank(to);
        vm.expectRevert(TransferLettersSystem.TransferMissingLetters.selector);
        world.transfer({ letters: transferLetters, to: to });
    }
}

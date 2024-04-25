// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;
/* solhint-disable no-global-import */
/* solhint-disable func-name-mixedcase */

import { Words3Test } from "../Words3Test.t.sol";
import { Letter } from "codegen/common.sol";
import { PlayerLetters } from "codegen/index.sol";
import "forge-std/Test.sol";

contract Transfer is Words3Test {
    function setUp() public override {
        super.setUp();
        setDefaultLetterOdds();
    }

    function test_Transfer() public {
        Letter[] memory initialWord = new Letter[](2);
        initialWord[0] = Letter.H;
        initialWord[1] = Letter.I;
        world.start({
            initialWord: initialWord,
            merkleRoot: bytes32(0),
            vrgdaTargetPrice: 12e14,
            vrgdaPriceDecay: 2e17,
            vrgdaPerDayInitial: 10e18,
            vrgdaPower: 2e18,
            crossWordRewardFraction: 3,
            bonusDistance: 3,
            numDrawLetters: 8
        });

        address player = address(0x123);
        address to = address(0x456);
        vm.deal(player, 50 ether);
        vm.startPrank(player);
        for (uint256 i = 0; i < 50; i++) {
            uint256 price = world.getDrawPrice();
            vm.warp(block.timestamp + 1 days);
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
}

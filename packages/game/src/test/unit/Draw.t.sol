// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Words3Test } from "../Words3Test.t.sol";
import "forge-std/Test.sol";

contract DrawTest is Words3Test {
    bytes32[] public words;

    function setUp() public override {
        super.setUp();
        setDefaultLetterOdds();
    }

    function test_Draw() public {
        address player = address(0x123face);
        startEmpty();
        vm.deal(player, 100 ether);

        vm.prank(player);
        uint256 id = world.words3__requestDraw{ value: 100 ether }(player);

        vm.roll(block.number + 1);
        world.words3__fulfillDraw(id);
    }
}

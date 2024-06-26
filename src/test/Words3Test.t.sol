// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { MudTest } from "@latticexyz/world/test/MudTest.t.sol";
import { Letter } from "codegen/common.sol";
import { IWorld } from "codegen/world/IWorld.sol";

contract Words3Test is MudTest {
    IWorld public world;
    address public deployerAddress;

    function setUp() public virtual override {
        super.setUp();
        world = IWorld(worldAddress);
        deployerAddress = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    }

    function setDefaultLetterOdds() public {
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
    }
}

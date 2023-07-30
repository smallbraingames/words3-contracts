// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IWorld} from "codegen/world/IWorld.sol";

import {Direction, Letter} from "codegen/Types.sol";
import {TileLetter} from "codegen/Tables.sol";

import {Coord} from "common/Coord.sol";
import {Bound} from "common/Bound.sol";
import {BoundTooLong} from "common/Errors.sol";
import {LibBoard} from "libraries/LibBoard.sol";

import "forge-std/Test.sol";
import {MudTest} from "@latticexyz/store/src/MudTest.sol";

contract LibBoardTest is MudTest {
    IWorld world;

    function setUp() public override {
        super.setUp();
        world = IWorld(worldAddress);
    }

    function testGetRelativeCoord() public {
        Coord memory startCoord = Coord({x: 0, y: 0});
        Coord memory expectedCoord = Coord({x: 0, y: 1});
        Coord memory actualCoord = LibBoard.getRelativeCoord(startCoord, 1, Direction.TOP_TO_BOTTOM);
        assertEq(abi.encode(actualCoord), abi.encode(expectedCoord));

        startCoord = Coord({x: 0, y: 0});
        expectedCoord = Coord({x: 1, y: 0});
        actualCoord = LibBoard.getRelativeCoord(startCoord, 1, Direction.LEFT_TO_RIGHT);
        assertEq(abi.encode(actualCoord), abi.encode(expectedCoord));

        startCoord = Coord({x: 0, y: 0});
        expectedCoord = Coord({x: 0, y: -1});
        actualCoord = LibBoard.getRelativeCoord(startCoord, -1, Direction.TOP_TO_BOTTOM);
        assertEq(abi.encode(actualCoord), abi.encode(expectedCoord));

        startCoord = Coord({x: 0, y: 0});
        expectedCoord = Coord({x: -1, y: 0});
        actualCoord = LibBoard.getRelativeCoord(startCoord, -1, Direction.LEFT_TO_RIGHT);
        assertEq(abi.encode(actualCoord), abi.encode(expectedCoord));
        assertEq(abi.encode(startCoord), abi.encode(Coord({x: 0, y: 0})));
    }

    function testFuzzGetRelativeCoord(int32 diff, int32 startX, int32 startY) public {
        vm.assume(diff >= -1e8 && diff <= 1e8);
        vm.assume(startX >= -1e8 && startX <= 1e8);
        vm.assume(startY >= -1e8 && startY <= 1e8);
        Coord memory startCoord = Coord({x: startX, y: startY});
        Coord memory expectedCoordLeftToRight = Coord({x: startX + diff, y: startY});
        Coord memory expectedCoordTopToBottom = Coord({x: startX, y: startY + diff});
        assertEq(abi.encode(startCoord), abi.encode(Coord({x: startX, y: startY})));
        assertEq(
            abi.encode(LibBoard.getRelativeCoord(startCoord, diff, Direction.LEFT_TO_RIGHT)),
            abi.encode(expectedCoordLeftToRight)
        );
        assertEq(
            abi.encode(LibBoard.getRelativeCoord(startCoord, diff, Direction.TOP_TO_BOTTOM)),
            abi.encode(expectedCoordTopToBottom)
        );
    }

    function testGetCoordsOutsideBound() public {
        bytes32[] memory proof = new bytes32[](1);
        Coord memory letterCoord = Coord({x: 0, y: 0});
        Bound memory bound = Bound({positive: 1, negative: 1, proof: proof});
        Coord memory expectedStart = Coord({x: 0, y: -2});
        Coord memory expectedEnd = Coord({x: 0, y: 2});
        (Coord memory actualStart, Coord memory actualEnd) =
            LibBoard.getCoordsOutsideBound(letterCoord, Direction.LEFT_TO_RIGHT, bound);
        assertEq(abi.encode(actualStart), abi.encode(expectedStart));
        assertEq(abi.encode(actualEnd), abi.encode(expectedEnd));

        assertEq(abi.encode(letterCoord), abi.encode(Coord({x: 0, y: 0})));
        assertEq(abi.encode(bound), abi.encode(Bound({positive: 1, negative: 1, proof: proof})));

        letterCoord = Coord({x: 0, y: 0});
        bound = Bound({positive: 1, negative: 1, proof: proof});
        expectedStart = Coord({x: -2, y: 0});
        expectedEnd = Coord({x: 2, y: 0});
        (actualStart, actualEnd) = LibBoard.getCoordsOutsideBound(letterCoord, Direction.TOP_TO_BOTTOM, bound);
        assertEq(abi.encode(actualStart), abi.encode(expectedStart));
        assertEq(abi.encode(actualEnd), abi.encode(expectedEnd));

        bound = Bound({positive: 100, negative: 1, proof: proof});
        vm.expectRevert(BoundTooLong.selector);
        LibBoard.getCoordsOutsideBound(letterCoord, Direction.TOP_TO_BOTTOM, bound);
        vm.expectRevert(BoundTooLong.selector);
        LibBoard.getCoordsOutsideBound(letterCoord, Direction.LEFT_TO_RIGHT, bound);
        bound = Bound({positive: 1, negative: 100, proof: proof});
        vm.expectRevert(BoundTooLong.selector);
        LibBoard.getCoordsOutsideBound(letterCoord, Direction.TOP_TO_BOTTOM, bound);
        vm.expectRevert(BoundTooLong.selector);
        LibBoard.getCoordsOutsideBound(letterCoord, Direction.LEFT_TO_RIGHT, bound);
    }

    function testFuzzGetCoordsOutsideBound(uint16 boundPositive, uint16 boundNegative, int32 startX, int32 startY)
        public
    {
        if (boundPositive > 50 || boundNegative > 50) {
            bytes32[] memory emptyProof = new bytes32[](1);
            vm.expectRevert(BoundTooLong.selector);
            LibBoard.getCoordsOutsideBound(
                Coord({x: startX, y: startY}),
                Direction.TOP_TO_BOTTOM,
                Bound({positive: boundPositive, negative: boundNegative, proof: emptyProof})
            );
            vm.expectRevert(BoundTooLong.selector);
            LibBoard.getCoordsOutsideBound(
                Coord({x: startX, y: startY}),
                Direction.LEFT_TO_RIGHT,
                Bound({positive: boundPositive, negative: boundNegative, proof: emptyProof})
            );
            return;
        }
        vm.assume(startX >= -1e8 && startX <= 1e8);
        vm.assume(startY >= -1e8 && startY <= 1e8);
        bytes32[] memory proof = new bytes32[](1);
        Coord memory letterCoord = Coord({x: startX, y: startY});
        Bound memory bound = Bound({positive: boundPositive, negative: boundNegative, proof: proof});
        Coord memory expectedStartLeftToRight = Coord({x: startX - int32(uint32(boundNegative)) - 1, y: startY});
        Coord memory expectedEndLeftToRight = Coord({x: startX + int32(uint32(boundPositive)) + 1, y: startY});
        Coord memory expectedStartTopToBottom = Coord({x: startX, y: startY - int32(uint32(boundNegative)) - 1});
        Coord memory expectedEndTopToBottom = Coord({x: startX, y: startY + int32(uint32(boundPositive)) + 1});
        (Coord memory actualStartLeftToRight, Coord memory actualEndLeftToRight) =
            LibBoard.getCoordsOutsideBound(letterCoord, Direction.TOP_TO_BOTTOM, bound);
        (Coord memory actualStartTopToBottom, Coord memory actualEndTopToBottom) =
            LibBoard.getCoordsOutsideBound(letterCoord, Direction.LEFT_TO_RIGHT, bound);
        assertEq(abi.encode(actualStartLeftToRight), abi.encode(expectedStartLeftToRight));
        assertEq(abi.encode(actualEndLeftToRight), abi.encode(expectedEndLeftToRight));
        assertEq(abi.encode(actualStartTopToBottom), abi.encode(expectedStartTopToBottom));
        assertEq(abi.encode(actualEndTopToBottom), abi.encode(expectedEndTopToBottom));
    }

    function testFuzzGetCoordsOutsideBoundDoesNotMutate(
        uint16 boundPositive,
        uint16 boundNegative,
        int32 startX,
        int32 startY
    ) public {
        vm.assume(boundPositive <= 50 && boundNegative <= 50);
        vm.assume(startX >= -1e8 && startX <= 1e8);
        vm.assume(startY >= -1e8 && startY <= 1e8);
        bytes32[] memory proof = new bytes32[](1);
        Coord memory letterCoord = Coord({x: startX, y: startY});
        Bound memory bound = Bound({positive: boundPositive, negative: boundNegative, proof: proof});
        LibBoard.getCoordsOutsideBound(letterCoord, Direction.TOP_TO_BOTTOM, bound);
        assertEq(abi.encode(letterCoord), abi.encode(Coord({x: startX, y: startY})));
        assertEq(abi.encode(bound), abi.encode(Bound({positive: boundPositive, negative: boundNegative, proof: proof})));
        LibBoard.getCoordsOutsideBound(letterCoord, Direction.LEFT_TO_RIGHT, bound);
        assertEq(abi.encode(letterCoord), abi.encode(Coord({x: startX, y: startY})));
        assertEq(abi.encode(bound), abi.encode(Bound({positive: boundPositive, negative: boundNegative, proof: proof})));
    }

    function testGetCrossWord() public {
        vm.prank(worldAddress);
        TileLetter.get(0, 5);
    }
}
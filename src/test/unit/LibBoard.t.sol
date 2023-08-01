// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IWorld} from "codegen/world/IWorld.sol";

import {Direction, Letter} from "codegen/Types.sol";
import {TileLetter} from "codegen/Tables.sol";

import {Coord} from "common/Coord.sol";
import {Bound} from "common/Bound.sol";
import {BoundTooLong, EmptyLetterInBounds} from "common/Errors.sol";
import {LibBoard} from "libraries/LibBoard.sol";

import "forge-std/Test.sol";
import {MudTest} from "@latticexyz/store/src/MudTest.sol";
import {Wrapper} from "./Wrapper.sol";

contract LibBoardTest is MudTest {
    IWorld world;
    Wrapper wrapper;

    function setUp() public override {
        super.setUp();
        world = IWorld(worldAddress);
        wrapper = new Wrapper();
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
        vm.expectRevert();
        wrapper.boardGetCoordsOutsideBound(letterCoord, Direction.TOP_TO_BOTTOM, bound);
        vm.expectRevert();
        wrapper.boardGetCoordsOutsideBound(letterCoord, Direction.LEFT_TO_RIGHT, bound);
        bound = Bound({positive: 1, negative: 100, proof: proof});
        vm.expectRevert();
        wrapper.boardGetCoordsOutsideBound(letterCoord, Direction.TOP_TO_BOTTOM, bound);
        vm.expectRevert();
        wrapper.boardGetCoordsOutsideBound(letterCoord, Direction.LEFT_TO_RIGHT, bound);
    }

    function testFuzzGetCoordsOutsideBound(uint16 boundPositive, uint16 boundNegative, int32 startX, int32 startY)
        public
    {
        vm.assume(startX >= -1e8 && startX <= 1e8);
        vm.assume(startY >= -1e8 && startY <= 1e8);
        if (boundPositive > 50 || boundNegative > 50) {
            bytes32[] memory emptyProof = new bytes32[](1);
            vm.expectRevert();
            wrapper.boardGetCoordsOutsideBound(
                Coord({x: startX, y: startY}),
                Direction.TOP_TO_BOTTOM,
                Bound({positive: boundPositive, negative: boundNegative, proof: emptyProof})
            );
            vm.expectRevert();
            wrapper.boardGetCoordsOutsideBound(
                Coord({x: startX, y: startY}),
                Direction.LEFT_TO_RIGHT,
                Bound({positive: boundPositive, negative: boundNegative, proof: emptyProof})
            );
            return;
        }
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
        boundPositive = uint16(bound(boundPositive, 0, 49));
        boundNegative = uint16(bound(boundNegative, 0, 49));
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
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> feat: board cross word tests
        vm.startPrank(worldAddress);
        TileLetter.set(0, 0, Letter.A);
        TileLetter.set(1, 0, Letter.B);
        TileLetter.set(2, 0, Letter.C);
        TileLetter.set(4, 0, Letter.E);
        TileLetter.set(5, 0, Letter.F);
        TileLetter.set(6, 0, Letter.G);
        vm.stopPrank();
        bytes32[] memory proof = new bytes32[](1);
        Letter[] memory word = LibBoard.getCrossWord(
            Coord({x: 3, y: 0}), Letter.D, Direction.TOP_TO_BOTTOM, Bound({positive: 3, negative: 3, proof: proof})
        );
        Letter[] memory expectedWord = new Letter[](7);
        expectedWord[0] = Letter.A;
        expectedWord[1] = Letter.B;
        expectedWord[2] = Letter.C;
        expectedWord[3] = Letter.D;
        expectedWord[4] = Letter.E;
        expectedWord[5] = Letter.F;
        expectedWord[6] = Letter.G;
        assertEq(abi.encode(word), abi.encode(expectedWord));

        vm.startPrank(worldAddress);
        TileLetter.set(0, 0, Letter.EMPTY);
        vm.stopPrank();
    }

    function testFailFuzzGetCrossWord(uint8 a, uint8 b, uint256 c, uint8 e, uint8 f, uint8 g) public {
        bool hasZero = false;
        if (a == 0 || b == 0 || c == 0 || e == 0 || f == 0 || g == 0) {
            hasZero = true;
        }
        vm.assume(hasZero);
        a = uint8(bound(a, 0, 26));
        b = uint8(bound(b, 0, 26));
        c = uint8(bound(c, 0, 26));
        e = uint8(bound(e, 0, 26));
        f = uint8(bound(f, 0, 26));
        g = uint8(bound(g, 0, 26));

        vm.startPrank(worldAddress);
        TileLetter.set(0, 0, Letter(a));
        TileLetter.set(1, 0, Letter(b));
        TileLetter.set(2, 0, Letter(c));
        TileLetter.set(4, 0, Letter(e));
        TileLetter.set(5, 0, Letter(f));
        TileLetter.set(6, 0, Letter(g));
        vm.stopPrank();
        bytes32[] memory proof = new bytes32[](1);
        LibBoard.getCrossWord(
            Coord({x: 3, y: 0}), Letter.D, Direction.TOP_TO_BOTTOM, Bound({positive: 3, negative: 3, proof: proof})
        );
    }

    function testFuzzGetCrossWord(
        int32 startX,
        int32 startY,
        uint16 crossWordHalfLength,
        bool wordDirectionLeftToRight,
        uint8 letterRaw
    ) public {
        vm.assume(startX >= -1e8 && startX <= 1e8);
        vm.assume(startY >= -1e8 && startY <= 1e8);
        letterRaw = uint8(bound(letterRaw, 1, 26));
        crossWordHalfLength = uint16(bound(crossWordHalfLength, 0, 200));
        Letter letter = Letter(letterRaw);
        Direction wordDirection = wordDirectionLeftToRight ? Direction.LEFT_TO_RIGHT : Direction.TOP_TO_BOTTOM;

        vm.startPrank(worldAddress);
        for (int32 i = 1; i <= int32(uint32(crossWordHalfLength)); i++) {
            if (!wordDirectionLeftToRight) {
                TileLetter.set(startX + i, startY, letter);
                TileLetter.set(startX - i, startY, letter);
            } else {
                TileLetter.set(startX, startY + i, letter);
                TileLetter.set(startX, startY - i, letter);
            }
        }

        bytes32[] memory proof = new bytes32[](1);
        Coord memory letterCoord = Coord({x: startX, y: startY});
        Letter[] memory crossWord = LibBoard.getCrossWord(
            letterCoord,
            letter,
            wordDirection,
            Bound({positive: crossWordHalfLength, negative: crossWordHalfLength, proof: proof})
        );
        assertEq(crossWord.length, crossWordHalfLength * 2 + 1);
        for (uint256 i = 0; i < crossWord.length; i++) {
            assertEq(uint8(crossWord[i]), uint8(letter));
        }

        vm.prank(worldAddress);
        TileLetter.get(0, 5);

    }
}

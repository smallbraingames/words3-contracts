// // SPDX-License-Identifier: MIT
// pragma solidity >=0.8.0;

// import {Direction} from "codegen/Types.sol";
// import {IWorld} from "codegen/world/IWorld.sol";
// import {TileTable, TileTableData} from "codegen/Tables.sol";
// import {Letter} from "codegen/Types.sol";

// import {Coord} from "common/Coord.sol";
// import {LibBoard} from "libraries/LibBoard.sol";
// import {EmptyLetterInBounds} from "common/Errors.sol";
// import {rawWordToWord} from "./TestUtils.sol";

// import "forge-std/Test.sol";
// import {MudV2Test} from "@latticexyz/std-contracts/src/test/MudV2Test.t.sol";
// import {getKeysWithValue} from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";

// contract LibBoardTest is MudV2Test {
//     IWorld world;

//     function setUp() public override {
//         super.setUp();
//         world = IWorld(worldAddress);
//     }

//     function testGetRewardPerEmptyTileFuzzEightLettersTwoEmpty(
//         uint8[] memory rawWord,
//         uint256 rewardFraction,
//         uint256 value
//     ) public {
//         vm.assume(rewardFraction > 0);
//         uint8 numEmpty = 0;
//         for (uint256 i = 0; i < rawWord.length; i++) {
//             vm.assume(rawWord[i] < 27);
//             if (rawWord[i] == 0) {
//                 numEmpty += 1;
//             }
//         }
//         uint256 reward = LibBoard.getRewardPerEmptyTile(rawWordToWord(rawWord), rewardFraction, value);
//         if (numEmpty == 0) {
//             assertEq(reward, 0);
//         } else {
//             assertEq(reward, (value / rewardFraction) / numEmpty);
//         }
//     }

//     function testGetLetterCoord() public {
//         assertEq(
//             abi.encode(LibBoard.getLetterCoord(10, Coord({x: 0, y: 0}), Direction.LEFT_TO_RIGHT)),
//             abi.encode(Coord({x: 10, y: 0}))
//         );
//         assertEq(
//             abi.encode(LibBoard.getLetterCoord(3, Coord({x: 0, y: 0}), Direction.LEFT_TO_RIGHT)),
//             abi.encode(Coord({x: 3, y: 0}))
//         );
//         assertEq(
//             abi.encode(LibBoard.getLetterCoord(12, Coord({x: 0, y: 10}), Direction.TOP_TO_BOTTOM)),
//             abi.encode(Coord({x: 0, y: 22}))
//         );
//         assertEq(
//             abi.encode(LibBoard.getLetterCoord(8, Coord({x: 23, y: 10}), Direction.TOP_TO_BOTTOM)),
//             abi.encode(Coord({x: 23, y: 18}))
//         );
//     }

//     function testGetLetterCoordLeftFuzzOffset(int32 offset, int32 startX, int32 startY) public {
//         vm.assume(offset > -1e6 && offset < 1e6);
//         vm.assume(startX > -5e6 && startX < 5e6);
//         vm.assume(startY > -5e6 && startY < 5e6);
//         assertEq(
//             abi.encode(LibBoard.getLetterCoord(offset, Coord({x: startX, y: startY}), Direction.LEFT_TO_RIGHT)),
//             abi.encode(Coord({x: startX + offset, y: startY}))
//         );
//     }

//     function testGetOutsideBoundCoords() public {
//         (Coord memory start, Coord memory end) =
//             LibBoard.getOutsideBoundCoords(Coord({x: 5, y: 8}), Direction.LEFT_TO_RIGHT, 10, 8);
//         assertEq(abi.encode(end), abi.encode(Coord({x: 5, y: 19})));
//         assertEq(abi.encode(start), abi.encode(Coord({x: 5, y: -1})));

//         (Coord memory startTop, Coord memory endTop) =
//             LibBoard.getOutsideBoundCoords(Coord({x: 12, y: 3}), Direction.TOP_TO_BOTTOM, 39, 2);
//         assertEq(abi.encode(endTop), abi.encode(Coord({x: 52, y: 3})));
//         assertEq(abi.encode(startTop), abi.encode(Coord({x: 9, y: 3})));
//     }

//     function testGetWordInBoundsCheckedFuzzNoWords(int32 x, int32 y, uint16 positive, uint16 negative) public {
//         vm.assume(positive < 1000);
//         vm.assume(negative < 1000);
//         vm.assume(x > -5e6 && x < 5e6);
//         vm.assume(y > -5e6 && y < 5e6);
//         WrapperContract wrapper = new WrapperContract();
//         vm.startPrank(address(world));
//         vm.expectRevert(EmptyLetterInBounds.selector);
//         wrapper.getWordInBoundsChecked(Coord({x: x, y: y}), Direction.TOP_TO_BOTTOM, positive, negative);
//         vm.expectRevert(EmptyLetterInBounds.selector);
//         wrapper.getWordInBoundsChecked(Coord({x: x, y: y}), Direction.LEFT_TO_RIGHT, positive, negative);
//     }

//     function testGetWordInBoundsChecked() public {
//         world.playFirstWord();
//         WrapperContract wrapper = new WrapperContract();
//         vm.startPrank(address(world));
//         wrapper.getWordInBoundsChecked(Coord({x: 0, y: 0}), Direction.TOP_TO_BOTTOM, 7, 0);
//     }
// }

// contract WrapperContract {
//     function getWordInBoundsChecked(Coord memory letterCoord, Direction direction, uint16 positive, uint16 negative)
//         public
//         view
//     {
//         LibBoard.getWordInBoundsChecked(letterCoord, direction, positive, negative);
//     }
// }

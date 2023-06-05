// // SPDX-License-Identifier: Unlicensed
// pragma solidity >=0.8.0;

// import {AlreadySetupGrid} from "common/Errors.sol";
// import {Coord} from "common/Coord.sol";
// import {LibBoard} from "libraries/LibBoard.sol";
// import {LibPrice} from "libraries/LibPrice.sol";
// import {LibTile} from "libraries/LibTile.sol";

// import {System} from "@latticexyz/world/src/System.sol";

// contract SetupBoardSystem is System {
//     function playFirstWord() public {
//         if (LibTile.hasTileAtCoord(Coord({x: 0, y: 0}))) {
//             revert AlreadySetupGrid();
//         }
//         LibBoard.playInfinite();
//         LibPrice.setupLetterWeights();
//     }
// }

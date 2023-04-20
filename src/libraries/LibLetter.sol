// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0;

import {Letter} from "codegen/Types.sol";

import {PointsForEmptyLetter} from "common/Errors.sol";

library LibLetter {
    function getPointsForLetter(Letter letter) internal pure returns (uint32) {
        if (letter == Letter.A) {
            return 1;
        } else if (letter == Letter.B) {
            return 3;
        } else if (letter == Letter.C) {
            return 3;
        } else if (letter == Letter.D) {
            return 2;
        } else if (letter == Letter.E) {
            return 1;
        } else if (letter == Letter.F) {
            return 4;
        } else if (letter == Letter.G) {
            return 2;
        } else if (letter == Letter.H) {
            return 4;
        } else if (letter == Letter.I) {
            return 1;
        } else if (letter == Letter.J) {
            return 8;
        } else if (letter == Letter.K) {
            return 5;
        } else if (letter == Letter.L) {
            return 1;
        } else if (letter == Letter.M) {
            return 3;
        } else if (letter == Letter.N) {
            return 1;
        } else if (letter == Letter.O) {
            return 1;
        } else if (letter == Letter.P) {
            return 3;
        } else if (letter == Letter.Q) {
            return 10;
        } else if (letter == Letter.R) {
            return 1;
        } else if (letter == Letter.S) {
            return 1;
        } else if (letter == Letter.T) {
            return 1;
        } else if (letter == Letter.U) {
            return 1;
        } else if (letter == Letter.V) {
            return 4;
        } else if (letter == Letter.W) {
            return 4;
        } else if (letter == Letter.X) {
            return 8;
        } else if (letter == Letter.Y) {
            return 4;
        } else if (letter == Letter.Z) {
            return 10;
        }
        revert PointsForEmptyLetter();
    }
}

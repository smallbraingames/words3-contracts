// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {BonusType} from "codegen/Types.sol";

struct Bonus {
    uint32 bonusValue;
    BonusType bonusType;
}

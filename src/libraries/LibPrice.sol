// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { DrawCount, VRGDAConfig, VRGDAConfigData } from "codegen/index.sol";
import {
    toDaysWadUnsafe, toWadUnsafe, wadDiv, wadExp, wadLn, wadMul, wadPow
} from "solmate/src/utils/SignedWadMath.sol";

library LibPrice {
    function wadRoot(int256 x, int256 root) internal pure returns (int256) {
        return wadPow(x, wadDiv(1e18, root));
    }

    // Adapted from transmissions11/VRGDAs (https://github.com/transmissions11/VRGDAs)
    function getDrawPrice() internal view returns (uint256) {
        VRGDAConfigData memory vrgdaConfig = VRGDAConfig.get();
        int256 decayConstant = wadLn(1e18 - vrgdaConfig.priceDecay);
        int256 daysSinceStart = toDaysWadUnsafe(block.timestamp - vrgdaConfig.startTime);
        uint256 drawCount = uint256(DrawCount.get());
        int256 inverse = wadRoot(wadDiv(toWadUnsafe(drawCount + 1), vrgdaConfig.perDayInitial), vrgdaConfig.power);
        return uint256(wadMul(vrgdaConfig.targetPrice, wadExp(wadMul(decayConstant, daysSinceStart - inverse))));
    }
}

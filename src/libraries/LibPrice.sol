// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { DrawLastSold, DrawLastSoldData, PriceConfig, PriceConfigData } from "codegen/index.sol";
import { Overflow } from "common/Errors.sol";
import { wadDiv, wadMul, wadPow } from "solmate/src/utils/SignedWadMath.sol";

library LibPrice {
    function getDrawPrice() internal view returns (uint256) {
        PriceConfigData memory priceConfig = PriceConfig.get();
        DrawLastSoldData memory drawLastSold = DrawLastSold.get();

        int256 wadGdaStartPrice = wadMul(toWad(drawLastSold.price), priceConfig.wadPriceIncreaseFactor);

        return getPrice({
            wadStartPrice: wadGdaStartPrice,
            wadMinPrice: toWad(priceConfig.minPrice),
            wadPower: priceConfig.wadPower,
            wadScale: priceConfig.wadScale,
            wadPassed: toWad(block.number - drawLastSold.blockNumber)
        });
    }

    function getPrice(
        int256 wadStartPrice,
        int256 wadMinPrice,
        int256 wadPower,
        int256 wadScale,
        int256 wadPassed
    )
        internal
        pure
        returns (uint256)
    {
        int256 startX =
            getInverseF({ y: wadStartPrice, wadPower: wadPower, wadScale: wadScale, wadConstant: wadMinPrice });
        int256 currentX = startX + wadPassed;
        int256 wadPrice = getF({ x: currentX, wadPower: wadPower, wadScale: wadScale, wadConstant: wadMinPrice });
        return uint256(wadPrice / 1e18);
    }

    function getF(int256 x, int256 wadPower, int256 wadScale, int256 wadConstant) internal pure returns (int256) {
        return wadDiv(wadScale, wadPow(x, wadPower)) + wadConstant;
    }

    function getInverseF(
        int256 y,
        int256 wadPower,
        int256 wadScale,
        int256 wadConstant
    )
        internal
        pure
        returns (int256)
    {
        return wadRoot(wadDiv(wadScale, y - wadConstant), wadPower);
    }

    function wadRoot(int256 x, int256 root) internal pure returns (int256) {
        if (x == 0) return 0;
        return wadPow(x, wadDiv(1e18, root));
    }

    function toWad(uint256 x) internal pure returns (int256) {
        uint256 wad = x * 1e18;
        if (wad > uint256(type(int256).max)) {
            revert Overflow();
        }
        return int256(wad);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { DrawLastSold, DrawLastSoldData, PriceConfig, PriceConfigData } from "codegen/index.sol";

import { Overflow } from "common/Errors.sol";
import { wadDiv, wadMul, wadPow } from "solmate/src/utils/SignedWadMath.sol";

library LibPrice {
    function getDrawPrice() internal view returns (uint256) {
        PriceConfigData memory priceConfig = PriceConfig.get();
        DrawLastSoldData memory drawLastSold = DrawLastSold.get();

        int256 wadGdaStartPrice = wadMul(toWad(drawLastSold.price), priceConfig.wadFactor);
        uint256 gdaEndPrice = priceConfig.minPrice;
        uint256 gdaDuration = getGDADuration({
            wadStartPrice: wadGdaStartPrice,
            wadDurationRoot: priceConfig.wadDurationRoot,
            wadDurationScale: priceConfig.wadDurationScale,
            wadDurationConstant: priceConfig.wadDurationConstant
        });

        uint256 gdaStartPrice = uint256(wadGdaStartPrice / 1e18);

        return getGDAPrice({
            startPrice: gdaStartPrice,
            endPrice: gdaEndPrice,
            duration: gdaDuration,
            passed: block.number - drawLastSold.blockNumber
        });
    }

    function getGDAPrice(
        uint256 startPrice,
        uint256 endPrice,
        uint256 duration,
        uint256 passed
    )
        internal
        pure
        returns (uint256)
    {
        uint256 price = startPrice;
        if (passed > duration || startPrice <= endPrice) {
            return endPrice;
        }
        uint256 deltaPrice = startPrice - endPrice;
        price -= (passed * deltaPrice / duration);
        return price;
    }

    // Duration is equal to nth root of startPrice * scale + constant
    function getGDADuration(
        int256 wadStartPrice,
        int256 wadDurationRoot,
        int256 wadDurationScale,
        int256 wadDurationConstant
    )
        internal
        pure
        returns (uint256)
    {
        int256 duration = wadMul(wadRoot(wadStartPrice, wadDurationRoot), wadDurationScale) + wadDurationConstant;
        return uint256(duration / 1e18) + 1;
    }

    function wadRoot(int256 x, int256 root) internal pure returns (int256) {
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

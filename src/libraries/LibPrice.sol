// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { DrawLastSold, DrawLastSoldData, PriceConfig, PriceConfigData } from "codegen/index.sol";
import { wadDiv, wadMul, wadPow } from "solmate/src/utils/SignedWadMath.sol";

library LibPrice {
    function getDrawPrice() internal view returns (uint256) {
        PriceConfigData memory priceConfig = PriceConfig.get();
        DrawLastSoldData memory drawLastSold = DrawLastSold.get();
        uint256 gdaStartPrice = uint256(wadMul(int256(drawLastSold.price), priceConfig.wadFactor));
        uint256 gdaEndPrice = priceConfig.minPrice;
        uint256 gdaDuration = getGDADuration({
            startPrice: gdaStartPrice,
            wadDurationRoot: priceConfig.wadDurationRoot,
            wadDurationScale: priceConfig.wadDurationScale,
            wadDurationConstant: priceConfig.wadDurationConstant
        });
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
        if (passed > duration) {
            return endPrice;
        }
        uint256 deltaPrice = startPrice - endPrice;
        price -= passed * deltaPrice / duration;
        return price;
    }

    function getGDADuration(
        uint256 startPrice,
        int256 wadDurationRoot,
        int256 wadDurationScale,
        int256 wadDurationConstant
    )
        internal
        pure
        returns (uint256)
    {
        int256 duration = wadMul(wadRoot(int256(startPrice), wadDurationRoot), wadDurationScale) + wadDurationConstant;
        return uint256(duration / 1e18) + 1;
    }

    function wadRoot(int256 x, int256 root) internal pure returns (int256) {
        return wadPow(x, wadDiv(1e18, root));
    }
}

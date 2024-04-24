// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { Config, Request, RequestData, Response } from "codegen/index.sol";

contract SetRandaoSystem is System {
    error WithinPeriod();

    function setRandao(uint256 id) public returns (uint256) {
        RequestData memory request = Request.get({ id: id });
        uint256 period = Config.getPeriod();
        if (block.number - request.blockNumber < period) {
            revert WithinPeriod();
        }
        uint256 randao = block.prevrandao;
        Response.set({ id: id, value: randao });
        return randao;
    }
}

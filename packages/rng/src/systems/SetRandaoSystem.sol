// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { Request, RequestData, Response } from "codegen/index.sol";

contract SetRandaoSystem is System {
    error WithinPeriod();

    function setRandao(uint256 id) public returns (uint256) {
        RequestData memory request = Request.get({ id: id });
        if (block.number - request.blockNumber < request.period) {
            revert WithinPeriod();
        }
        uint256 randao = block.prevrandao;
        Response.set({ id: id, value: randao });
        return randao;
    }
}

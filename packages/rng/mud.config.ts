import { defineWorld } from "@latticexyz/world";

export default defineWorld({
    namespace: "rng",
    tables: {
        Id: {
            key: [],
            schema: {
                value: "uint256",
            }
        },
        Request: {
            key: ["id"],
            schema: {
                id: "uint256",
                blockNumber: "uint256",
                timestamp: "uint256",
                period: "uint256" // In number of blocks
            },
        },
        Response: {
            key: ["id"],
            schema: {
                id: "uint256",
                value: "uint256",
            },
        }
    },
});

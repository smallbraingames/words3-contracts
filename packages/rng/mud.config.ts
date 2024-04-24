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
        Config: {
            key: [],
            schema: {
                period: "uint256", // In number of blocks
                valueSet: "bool"
            }
        },
        Request: {
            key: ["id"],
            schema: {
                id: "uint256",
                blockNumber: "uint256",
                timestamp: "uint256",
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

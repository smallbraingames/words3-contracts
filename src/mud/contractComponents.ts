/* Autogenerated file. Do not edit manually. */

import { TableId } from "@latticexyz/utils";
import { defineComponent, Type as RecsType, World } from "@latticexyz/recs";

export function defineContractComponents(world: World) {
  return {
    TileTable: (() => {
      const tableId = new TableId("", "TileTable");
      return defineComponent(
        world,
        {
          player: RecsType.String,
          letter: RecsType.Number,
        },
        {
          metadata: {
            contractId: tableId.toHexString(),
            tableId: tableId.toString(),
          },
        }
      );
    })(),
    WeightTable: (() => {
      const tableId = new TableId("", "WeightTable");
      return defineComponent(
        world,
        {
          weight: RecsType.BigInt,
        },
        {
          metadata: {
            contractId: tableId.toHexString(),
            tableId: tableId.toString(),
          },
        }
      );
    })(),
    RewardsTable: (() => {
      const tableId = new TableId("", "RewardsTable");
      return defineComponent(
        world,
        {
          rewards: RecsType.BigInt,
        },
        {
          metadata: {
            contractId: tableId.toHexString(),
            tableId: tableId.toString(),
          },
        }
      );
    })(),
    TreasuryTable: (() => {
      const tableId = new TableId("", "TreasuryTable");
      return defineComponent(
        world,
        {
          value: RecsType.BigInt,
        },
        {
          metadata: {
            contractId: tableId.toHexString(),
            tableId: tableId.toString(),
          },
        }
      );
    })(),
    ScoreTable: (() => {
      const tableId = new TableId("", "ScoreTable");
      return defineComponent(
        world,
        {
          score: RecsType.BigInt,
        },
        {
          metadata: {
            contractId: tableId.toHexString(),
            tableId: tableId.toString(),
          },
        }
      );
    })(),
    SpentTable: (() => {
      const tableId = new TableId("", "SpentTable");
      return defineComponent(
        world,
        {
          score: RecsType.BigInt,
        },
        {
          metadata: {
            contractId: tableId.toHexString(),
            tableId: tableId.toString(),
          },
        }
      );
    })(),
  };
}

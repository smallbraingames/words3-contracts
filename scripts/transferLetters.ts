import {
  Address,
  Chain,
  Hex,
  PublicClient,
  WalletClient,
  createPublicClient,
  createWalletClient,
  getAddress,
  http,
} from "viem";
import IWorldAbi from "../out/IWorld.sol/IWorld.abi.json";
import worlds from "../worlds.json";
import { Command } from "commander";
import { baseSepolia } from "viem/chains";
import { chainConfig } from "viem/op-stack";
import { privateKeyToAccount } from "viem/accounts";
import { parse } from "csv-parse";
import { readFile } from "fs/promises";
import { createReadStream } from "fs";

const redstone = {
  ...chainConfig,
  id: 690,
  sourceId: 1,
  name: "Redstone",
  nativeCurrency: { name: "Ether", symbol: "ETH", decimals: 18 },
  rpcUrls: {
    default: {
      http: ["https://rpc.redstonechain.com"],
      webSocket: ["wss://rpc.redstonechain.com"],
    },
  },
  blockExplorers: {
    default: {
      name: "Blockscout",
      url: "https://explorer.redstone.xyz",
    },
  },
};

const SUPPORTED_CHAINS: Chain[] = [redstone, baseSepolia];

const getStringLetter = (s: string) => {
  if (s.length === 0) {
    return 0;
  }
  return s.charCodeAt(0) - 96;
};

const getLetterString = (letter: number) => {
  if (letter < 1 || letter > 26) {
    throw new Error("[Get Letter String] letter must be between 1 and 26");
  }

  return String.fromCharCode(64 + letter);
};

const transferLetters = async (
  letters: number[],
  to: Address,
  walletClient: WalletClient,
  publicClient: PublicClient,
  chain: Chain,
  worldAddress: Address,
) => {
  if (!walletClient.account) {
    throw new Error("[Transfer Letters] Account is not connected");
  }

  console.log(
    `[Transfer Letters] transferring letters ${letters.map(getLetterString).join(",")} to ${to} on ${chain.name} chain`,
  );

  const tx = await walletClient.writeContract({
    address: worldAddress,
    chain,
    abi: IWorldAbi,
    functionName: "transfer",
    args: [letters, to],
    account: walletClient.account!,
  });

  const receipt = await publicClient.waitForTransactionReceipt({ hash: tx });

  if (receipt.status !== "success") {
    console.log("[Transfer Letters] Transaction failed", receipt);
    throw new Error(`[Transfer Letters] Transaction failed: ${receipt}`);
  }

  console.log(
    `[Transfer Letters] Transferped letters ${letters.map(getLetterString).join(",")} to ${to} on ${chain.name} chain (tx hash: ${tx})`,
  );
};

type Transfer = {
  player: Address;
  letters: number[];
};

const processTransfers = async (
  transfers: Transfer[],
  walletClient: WalletClient,
  publicClient: PublicClient,
  chain: Chain,
  worldAddress: Address,
) => {
  console.log(
    `[Transfer Letters] transferring ${transfers.length} times on ${chain.name} chain`,
  );
  for (const transfer of transfers) {
    await transferLetters(
      transfer.letters,
      transfer.player,
      walletClient,
      publicClient,
      chain,
      worldAddress,
    );
  }
  console.log(
    `[Transfer Letters] Transferped ${transfers.length} times on ${chain.name} chain`,
  );
};

const getPlayerCSVAddresses = async (csv: string): Promise<Address[]> => {
  const promise = new Promise<Address[]>((resolve, reject) => {
    const addresses: Address[] = [];
    createReadStream(csv)
      .pipe(parse({ columns: true }))
      .on("data", (row) => {
        try {
          let rowAddress = row.address;
          if (!rowAddress.startsWith("0x")) {
            rowAddress = `0x${rowAddress}`;
          }
          addresses.push(getAddress(rowAddress));
        } catch (e) {
          console.error(
            `[Get Player CSV Addresses] Error parsing row ${row}`,
            e,
          );
        }
      })
      .on("end", () => {
        resolve(addresses);
      });
  });
  return promise;
};

const program = new Command();

program
  .name("transfer-letters")
  .description("Transfer letters to a players")
  .argument("<number>", "Chain to transfer letters on")
  .argument("<string>", "Wallet private key")
  .option("-l, --letters <string>", "List of letters to transfer")
  .option(
    "-r, --random <number>",
    "Randomly choose some letters from the letter list instead of transferring all",
  )
  .option("--playersCsv <string>", "CSV file containing player addresses")
  .option(
    "--player <string>",
    "Player address to transfer to, transfer to one player",
  )
  .action(
    async (
      chainId: string,
      walletPrivateKey: string,
      options: {
        letters?: string;
        random?: string;
        playersCsv?: string;
        player?: string;
      },
    ) => {
      // @ts-expect-error
      const worldAddressRaw: string | undefined = worlds[chainId]?.address;
      if (!worldAddressRaw) {
        throw new Error(
          `[Transfer Letters] No world address found for chain ${chainId}. Did you run \`mud deploy\`?`,
        );
      }

      const worldAddress = getAddress(worldAddressRaw);

      const chain = SUPPORTED_CHAINS.find((c) => c.id.toString() === chainId);
      if (!chain) {
        throw new Error(`[Transfer Letters] Chain ${chainId} is not supported`);
      }

      const letters =
        options.letters
          ?.split("")
          .map((l) => getStringLetter(l.toLowerCase())) ??
        Array.from({ length: 26 }, (_, i) => i + 1);
      console.log(
        `[Transfer Letters] transferring with letter list ${letters.map(getLetterString).join(",")}`,
      );

      const players: Address[] = [];
      if (options.player) {
        players.push(getAddress(options.player));
        console.log(
          `[Transfer Letters] transferring to player ${options.player}`,
        );
      } else if (options.playersCsv) {
        const csvPlayers = await getPlayerCSVAddresses(options.playersCsv);
        players.push(...csvPlayers);
        console.log(
          `[Transfer Letters] transferring to ${csvPlayers.length} players from CSV`,
        );
      } else {
        throw Error(
          "[Transfer Letters] No player specified, specify player or playersCsv",
        );
      }

      const transfers: Transfer[] = [];
      if (options.random) {
        const numLetters = parseInt(options.random);
        for (const player of players) {
          const randomLetters = letters
            .sort(() => Math.random() - 0.5)
            .slice(0, numLetters);
          transfers.push({ player, letters: randomLetters });
        }
        console.log(
          `[Transfer Letters] transferring ${numLetters} random letter(s) to ${players.length} players`,
        );
      } else {
        for (const player of players) {
          transfers.push({ player, letters });
        }
        console.log(
          `[Transfer Letters] transferring all letters in list to ${players.length} players`,
        );
      }

      const privateKeyAccount = privateKeyToAccount(walletPrivateKey as Hex);

      const walletClient = createWalletClient({
        chain,
        account: privateKeyAccount,
        transport: http(),
      });
      const publicClient = createPublicClient({ chain, transport: http() });
      await processTransfers(
        transfers,
        walletClient,
        publicClient,
        chain,
        worldAddress,
      );
    },
  );

program.parse();


# Words3

An open source, fully onchain, **word game** built with [MUD](https://mud.dev)




## Deployment

To deploy words3, first clone the repository **including submodules**

```bash
  git clone --recurse-submodules https://github.com/smallbraingames/words3-contracts
```

Then, install dependencies (we use [pnpm](https://pnpm.io))

```bash
pnpm install
```

Next, cleanup excess files in the murky submodule to prevent compilation errors

```bash
pnpm clean-murky
```

Now, deploy contracts locally with

```
pnpm dev
```


## Environment Variables

To run this project, you will need to add the following environment variables to your .env file

`PRIVATE_KEY`

You can set this to the default anvil private key with

```
PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 # Anvil
```

## Running Tests

To run tests, after following the estup instructions, run the following command

```
pnpm test
```


## Authors

- [@smallbraingames](https://www.github.com/smallbraingames)


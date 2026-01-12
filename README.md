### Notes

>1. Run `make install` to install all required dependencies before compiling or testing the project.
>2. All unit tests have been executed and pass on:
   - Local Anvil chain
   - Sepolia testnet
>3. zkSync testing notes:
   - The project currently uses an older version of the Chainlink mock contract (`MockV3Aggregator`).
   - Some unit and integration tests are skipped when running `forge test --zksync` due to mock compatibility issues.
   - Support will be updated to use newer mock contracts.
>4. This project includes examples and experiments related to Ethereum storage layout (e.g., storage slots for variables, arrays, and mappings).


## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

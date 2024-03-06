# Notes

## Solidity/Ethereum
- docker ethereum/client-go, ethereum/solc
- node hardhat, viem, ganache

```bash
yarn init -y
yarn add --dev hardhat
yarn add --dev @nomicfoundation/hardhat-toolbox-viem
npx hardhat init
```

1. Proyect setup: `npx hardhat init`
2. Get a wallet (private key): Metamask
3. Testnet funds: Sepolia and QuickNode or Alchemy
4. Endpoint to deploy: Geth or QuickNode 

```plaintext
artifacts/contracts
  └─ zombie.sol
    └─ zombie.json      (ABI)
    └─ zombie.dbg.json
```

---

## Gear/VARA

1. Proyect setup: `gear cli`
2. Get a wallet: Polkadot.js
3. Testnet funds: idea.gear-tech
4. Endpoint to deploy: idea.gear-tech

```plaintext
target
  └─ wasm32-unknown-unknown/release
    └─ zombie.meta.txt  (ABI)
    └─ zombie.opt.wasm
```

---

## Ink/Polkadot

1. Proyect setup: `cargo contract`
2. Get a wallet: Polkadot.js
3. Testnet funds: `https://contracts-ui.substrate.io/`
4. Endpoint to deploy: `substrate-contracts-node`

```plaintext
target
  └─ ink
    └─ zombie.json      (ABI)
    └─ zombie.wasm
    └─ zombie.contract  (bundle)
```

---

## Canister/ICP

1. Proyect setup: `dfx new zombie`
2. Get a wallet: `dfx wallet`
3. Testnet funds: https://faucet.dfinity.org
4. Endpoint to deploy: `dfx deploy zombie --playground`

## Cairo/StarkNet

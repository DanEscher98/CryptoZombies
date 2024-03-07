
```sh
rustup toolchain install stable-x86_64-unknown-linux-gnu
rustup component add rust-src --toolchain stable-x86_64-unknown-linux-gnu
cargo install cargo-contract --force --version 3.2.0

PROJECT=flipper
cargo contract new $PROJECT
cd $PROJECT
cargo contract build --release
```

```plaintext
www.subscan.io/
    > Networks > Testnets > Shibuya

portal.astar.network 
    > Wallet > Native Wallets > Polkadot.js
    > Network > Other networks > Astar Testnet > Advanced > Shibuya > Change Network
    > Assets > Faucet

polkadot.js.org
    > Networks > Test Networks > Shibuya > via Astar > Switch
    > Developer > Contracts > Upload & deploy
```

# anvil --config-out anvil.json
PRIVATE_KEY=`cat workflows/anvil.json | jq --raw-output .private_keys[0]`
RPC_URL=127.0.0.1:8545

function deploy() {
  local FILE=$1
  local CONTRACT=$2
  local ARGS=$3
  forge create \
    --json --rpc-url "$RPC_URL" --private-key "$PRIVATE_KEY" \
    $FILE:$CONTRACT --constructor-args $ARGS \
    | jq --raw-output .deployedTo
}

function get_cryptokitties() {
  if [ ! -f src/CryptoKitties.sol ]; then
    curl -sS https://gist.githubusercontent.com/yogin/b88b105d9b2e332a5b59a3fd29cac962/raw/0ecb6cdcffdf1c53fcafacfd3a832a88d792d7cc/CryptoKitties.sol > src/CryptoKitties.sol
  fi
}

if ! pgrep -x "anvil" > /dev/null; then
  echo "Anvil is not running."
  exit 1
fi

get_cryptokitties
CONTRACT=`deploy "src/CryptoKitties.sol" "KittyCore" "0"`
echo -e "CONTRACT:\t$CONTRACT"

CONTRACT=`deploy "src/ZombieFactoryB.sol" "ZombieFeeding" "$CONTRACT"`
echo -e "CONTRACT:\t$CONTRACT"


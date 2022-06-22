#!/bin/bash

_term() { 
  echo "Caught SIGTERM signal!" 
  kill -TERM "$sensei_process" 2>/dev/null
}
# Setting variables
TOR_ADDRESS=$(yq e '.tor-address' /root/start9/config.yaml)
LAN_ADDRESS=$(yq e '.lan-address' /root/start9/config.yaml)
APP_PASS=$(yq e '.password' /root/start9/config.yaml)
RPC_TYPE=$(yq e '.bitcoind.type' /root/start9/config.yaml)
RPC_USER=$(yq e '.bitcoind.user' /root/start9/config.yaml)
RPC_PASS=$(yq e '.bitcoind.password' /root/start9/config.yaml)
if [ "$RPC_TYPE" = "internal-proxy" ]; then
	RPC_HOST="btc-rpc-proxy.embassy"
	echo "Running on Bitcoin Proxy..."
else
	RPC_HOST="bitcoind.embassy"
	echo "Running on Bitcoin Core..."
fi
echo "Configuring Sensei..."

# Properties Page showing password to be used for login
  echo 'version: 2' >> /root/start9/stats.yaml
  echo 'data:' >> /root/start9/stats.yaml
  echo '  Password: ' >> /root/start9/stats.yaml
        echo '    type: string' >> /root/start9/stats.yaml
        echo "    value: \"$APP_PASS\"" >> /root/start9/stats.yaml
        echo '    description: This is your admin password for Sensei. Please use caution when sharing this password, you could lose your funds!' >> /root/start9/stats.yaml
        echo '    copyable: true' >> /root/start9/stats.yaml
        echo '    masked: true' >> /root/start9/stats.yaml
        echo '    qr: false' >> /root/start9/stats.yaml

echo "Starting Sensei..."
source $HOME/.cargo/env
cargo run \
    --bin senseid -- --network=mainnet \
    --bitcoind-rpc-host=$RPC_HOST \
    --bitcoind-rpc-port=8332 \
    --bitcoind-rpc-username=$RPC_USER \
    --bitcoind-rpc-password=$RPC_PASS \
    --database-url=sensei.db

while true;
do
sleep 20000;
done


trap _term SIGTERM
wait -n $sensei_process
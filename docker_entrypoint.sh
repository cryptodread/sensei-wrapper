#!/bin/bash
set -a

_term() { 
  echo "Caught SIGTERM signal!" 
  kill -TERM "$sensei_process" 2>/dev/null
}
# Setting variables
export TOR_ADDRESS=$(yq e '.tor-address' /root/start9/config.yaml)
export LAN_ADDRESS=$(yq e '.lan-address' /root/start9/config.yaml)
export RPC_TYPE=$(yq e '.bitcoind.type' /root/start9/config.yaml)
export NETWORK="bitcoin"
export DATABASE_URL="sensei.db"
# export API_HOST=$(yq e '.tor-address' /root/start9/config.yaml)
export BITCOIND_RPC_USERNAME=$(yq e '.bitcoind.user' /root/start9/config.yaml)
export BITCOIND_RPC_PORT=8332
export BITCOIND_RPC_PASSWORD=$(yq e '.bitcoind.password' /root/start9/config.yaml)
if [ "$RPC_TYPE" = "internal-proxy" ]; then
	export BITCOIND_RPC_HOST="btc-rpc-proxy.embassy"
	echo "Running on Bitcoin Proxy..."
else
	export BITCOIND_RPC_HOST="bitcoind.embassy"
	echo "Running on Bitcoin Core..."
fi
echo "Configuring Sensei..."

# Properties Page showing password to be used for login
  echo 'version: 2' >> /root/start9/stats.yaml
  echo 'data:' >> /root/start9/stats.yaml
  echo '  Password: ' >> /root/start9/stats.yaml
        echo '    type: string' >> /root/start9/stats.yaml
        echo "    value: ******** " >> /root/start9/stats.yaml
        echo '    description: This is your admin password for Sensei. Please use caution when sharing this password, you could lose your funds!' >> /root/start9/stats.yaml
        echo '    copyable: true' >> /root/start9/stats.yaml
        echo '    masked: true' >> /root/start9/stats.yaml
        echo '    qr: false' >> /root/start9/stats.yaml

echo "Starting Sensei..."
./senseid 
while true;
do
sleep 20000;
done


trap _term SIGTERM
wait -n $sensei_process
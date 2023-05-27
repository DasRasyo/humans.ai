#!/bin/bash


echo -e "                                                       ";
echo -e "   ______                                              ";
echo -e "  / ____/___  ____  ____ ___  _____  _________  _____  ";
echo -e " / /   / __ \/ __ \/ __  / / / / _ \/ ___/ __ \/ ___/  ";
echo -e "/ /___/ /_/ / / / / /_/ / /_/ /  __/ /  / /_/ / /      ";
echo -e "\____/\____/_/ /_/\__  /\__ _/\___/_/   \____/_/       ";
echo -e "                    /_/                                ";
echo -e "                                                       ";

echo -e "\033[38;5;245mTwitter : https://twitter.com/Conquerorr_1\033[0m"
echo -e "\033[38;5;245mGithub  : https://github.com/DasRasyo\033[0m"
echo -e "\033[38;5;205mHumans AI Node\033[0m"

sleep 8

prompt() {
  read -p "$1: " val
  echo $val
}



echo -e "\033[38;5;205m⚠️Starting with Packages update and Dependencies Inslall⚠️"
sleep 5

sudo apt update && apt upgrade -y && sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential \
git make ncdu -y 

sleep 5

echo -e "\033[38;5;205m⚠️Installing GO⚠️\033[0m"

sleep 10

cd $HOME
curl -Ls https://go.dev/dl/go1.20.1.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
touch $HOME/.bash_profile
source $HOME/.bash_profile
PATH_INCLUDES_GO=$(grep "$HOME/go/bin" $HOME/.bash_profile)
if [ -z "$PATH_INCLUDES_GO" ]; then
  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
  echo "export GOPATH=$HOME/go" >> $HOME/.bash_profile
fi
eval $(echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh)
eval $(echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile)
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
source $HOME/.bash_profile

sleep 5

source $HOME/.bash_profile

echo -e "\033[38;5;205mPackages updated, Go and Dependencies Inslalled. You can check your go version with = go version\033[0m"

sleep 7

echo -e "\033[38;5;205mDownloading the Binary\033[0m"

sleep 10

git clone https://github.com/humansdotai/humans
cd humans
git checkout v0.2.2
make install

humansd config keyring-backend test
humansd config chain-id humans_3000-31
validator_node_name=$(prompt "Enter your validator node name")
humansd init $validator_node_name --chain-id humans_3000-31

sleep 10

curl -s https://github.com/humansdotai/testnets/blob/master/friction/mission-3/genesis-m3-p1.json > $HOME/.humansd/config/genesis.json
curl -Ls https://snapshots.kjnodes.com/humans-testnet/addrbook.json > $HOME/.humansd/config/addrbook.json

SEEDS=""
PEERS="ceba57f1376d4949cc0419918d110f0085b24b25@135.181.113.225:26656,752d0b45e13954a6052597d180e5eb230e64f4fa@141.95.99.214:26656,6271d80b8fc42da3a2825cc5ef75818dd52423d1@138.201.121.185:26656,bc098ac0149a0a06701e29e4f7c79cac65c25c7f@162.55.173.57:26656,4e6f3ba9f9432766d13686076eadf60900d42e5b@65.108.224.156:26656,59ad24780f3d8b90da29079a8a386aa1355969ef@144.76.45.59:26656"
sed -i 's|^seeds *=.*|seeds = "'$SEEDS'"|; s|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.humansd/config/config.toml



echo -e "\033[38;5;205mStarting Service\033[0m"

sleep 5

sudo tee /etc/systemd/system/humansd.service > /dev/null << EOF
[Unit]
Description=Humans AI Node
After=network-online.target
[Service]
User=root
ExecStart=$(which humansd) start
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
EOF

humansd tendermint unsafe-reset-all --home $HOME/.humansd --keep-addr-book

sudo systemctl daemon-reload
sudo systemctl enable humansd
sudo systemctl start humansd

sleep 5

echo -e "\033[38;5;205mCongrats!! Your node started!\033[0m"
sleep 7
echo -e "\033[38;5;205mSome Useful Command That You May Need For Service. Copy and Save!\033[0m"
sleep 3
echo -e "\033[38;5;205mCheck Your Logs:   sudo journalctl -u humansd -f --no-hostname -o cat\033[0m"
sleep 3
echo -e "\033[38;5;205mStop the Service:   sudo systemctl stop humansd\033[0m"
sleep 3
echo -e "\033[38;5;205mStart the Service:   sudo systemctl start humansd\033[0m"
sleep 3
echo -e "\033[38;5;205mRestart the Service:   sudo systemctl restart humansd\033[0m"
sleep 3
echo -e "\033[31m⚠️Before creating validator make sure you fully synced!!!!⚠️\033[0m"
sleep 5


echo -e "\033[31m⚠️⚠️⚠️Lets create a wallet! Please do not forget to save your mnemonics!!!. If you dont save you can not access your wallet. After creating wallet, you will have 100 second to save your mnemonics. After that script will continued!⚠️⚠️⚠️\033[0m"
echo -e "\033[31m⚠️ Before creating your validator do not forget to top up your wallet with some testnet coin! ⚠️\033[0m"
echo -e "\033[31m⚠️⚠️⚠️ SAVE THE MNEMONICS⚠️⚠️⚠️\033[0m"
sleep 17

wallet_name=$(prompt "Enter your account-wallet name")
humansd keys add $wallet_name

sleep 100

echo -e "\033[38;5;205mWith this script we automaticly check if your node fully synced. After synced you can go on with creating your validator. The script will check sync status every 60 seconds and will print the status.\033[0m"

while true
do

    sync_status=$(curl -s localhost:26657/status | jq '.result | .sync_info | .catching_up')
        if [ "$sync_status" = "false" ]; then
        echo "Your node is synced with the Humans network."
            sleep 5
            echo "Your node is now synced with the Humans network. Proceed with validator creation."
            sleep 5
            echo "Stop the script with ctrl C and edit the following command with your information to create your validator!"
            sleep 10
            echo -e "\033[38;5;205mhumansd tx staking create-validator --amount=1000000000000000000aheart --pubkey=$(humansd tendermint show-validator) --moniker=$validator_node_name --chain-id=humans_3000-1 --commission-rate=0.05 --commission-max-rate=0.10 --commission-max-change-rate=0.01 --min-self-delegation=1000000 --gas=auto --gas-prices=1800000000aheart --from=$wallet_name\033[0m"
		sleep 20

        else
       echo "Your node is not synced with the Humans network. Waiting for sync to complete..."
           sleep 60
        fi
done

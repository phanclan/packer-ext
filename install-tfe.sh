#!/bin/sh -x

echo "[*] Setup logging and begin"
set -eu
NOW=$(date +"%FT%T")
exec &> /home/ubuntu/install-ptfe.log

echo "[$NOW]  Beginning TFE user_data script."

sudo apt-get update
echo "[*] Install base"
sudo apt-get install -qq jq unzip tree curl wget vim git make
#sudo apt-get install -qq dnsutils iputils-ping net-tools netcat pv
#sudo apt-get install -qq nginx

echo "[*] Install cloud tools"
#sudo apt-get install -qq awscli
sudo apt-get install -qq python3-pip
pip3 install --upgrade pip
pip3 install awscli --upgrade --user
#!/bin/bash
set -x

echo "[*] Install dnsmasq"

YUM=$(which yum 2>/dev/null)
APT_GET=$(which apt-get 2>/dev/null)
if [[ ! -z ${YUM} ]]; then
  logger "#==> Installing dnsmasq"
  sudo yum install -q -y dnsmasq
elif [[ ! -z ${APT_GET} ]]; then
  logger "Installing dnsmasq"
  sudo apt-get -qq update
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq dnsmasq-base dnsmasq
else
  logger "Dnsmasq not installed due to OS detection failure"
  exit 1;
fi

logger "Configuring dnsmasq to forward .consul requests to consul port 8600"
sudo sh -c 'echo "server=/consul/127.0.0.1#8600" >> /etc/dnsmasq.d/consul'
sudo systemctl enable dnsmasq
sudo systemctl restart dnsmasq

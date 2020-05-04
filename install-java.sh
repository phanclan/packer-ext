#!/bin/bash
set -x

echo "[*] Install docker"
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq default-jdk

#!/bin/bash
set -ex

# Setup bridge
sudo apt update
sudo apt install -y bridge-utils
sudo cp host/60-zeek-bridge.yaml /etc/netplan/60-zeek-bridge.yaml
sudo netplan apply

# Disable NIC offload features
sudo cp host/ethtool.service /etc/systemd/system/ethtool.service
sudo cp host/ethtool.sh /usr/local/sbin/ethtool.sh
sudo systemctl enable ethtool
sudo systemctl start ethtool

# Enable auto-updates
./host/enable_autoupdate.sh

# Install Docker
./host/install_docker.sh

# Build then run Docker container
pushd docker
./docker_build.sh
./docker_run.sh
popd

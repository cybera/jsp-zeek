#!/bin/bash
set -ex

# Setup bridge
sudo apt update
sudo apt install -y bridge-utils
sudo cp host/60-zeek-bridge.yaml /etc/netplan/60-zeek-bridge.yaml
sudo netplan apply

# Disable NIC features
for i in rx tx sg tso ufo gso gro lro; do ethtool -K eno1 $i off; done

# Enable auto-updates
./host/enable_autoupdate.sh

# Install Docker
./host/install_docker.sh

# Build then run Docker container
pushd docker
./docker_build.sh
./docker_run.sh
popd

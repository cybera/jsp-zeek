#!/bin/bash
set -ex

## Install OS Packages
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

# Add Docker key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt update

#* Docker install
sudo apt install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io

# Test Docker Hello-World
sudo docker run hello-world

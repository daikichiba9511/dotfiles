#!/bin/sh
set -eu
sudo apt update && sudo apt upgrade -y
sudo apt install -y \
    gcc \
    g++ \
    make \
    cmake \
    git \
    vim \
    tmux \
    bat \
    fzf \
    curl \
    exa


# for bat
# Ref: https://github.com/sharkdp/bat#on-ubuntu-using-apt
mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat



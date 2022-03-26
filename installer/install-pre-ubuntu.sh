#!/bin/sh
set -eu

if which sudo > /dev/null 2>&1; then
    echo "this envrionment has sudo.. so continue to install"
else
    apt install -y sudo
fi

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
    wget \
    unzip \
    skkdic

wget https://github.com/ogham/exa/releases/download/v0.10.1/exa-linux-x86_64-v0.10.1.zip
mv exa-linux-x86_64-v0.10.1.zip $HOME/
unzip $HOME/exa-linux-x86_64-v0.10.1.zip -d $HOME/.exa
cp $HOME/.exa/bin/exa /usr/local/bin

# for bat
# Ref: https://github.com/sharkdp/bat#on-ubuntu-using-apt
mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat



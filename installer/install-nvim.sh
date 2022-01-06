#!/bin/sh 
# pipeは使わない予定だけど一応
# set -eou pipefail
set -eu

# echo $1

# install neovim from source
# vscode-neovimとの互換性を持たせるためにはver>=0.5が必要なのでソースからビルドする
NVIM_DEFUALT_VER=0.6
NVIM_VERSION=${1-$NVIM_DEFUALT_VER}
# step:1 clone
echo "✨ git cloned neovim"
git clone https://github.com/neovim/neovim.git ~/neovim

# step:2 build
cd ~/neovim
git checkout "release-${NVIM_VERSION}}"
sudo make CMAKE_BUILD_TYPE=Release
sudo make install

echo "✨ finished installing neovim"


#!/bin/sh
# pipeは使わない予定だけど一応
# set -eou pipefail
set -eu

# echo $1

# install neovim from source
# vscode-neovimとの互換性を持たせるためにはver>=0.5が必要なのでソースからビルドする
# NVIM_DEFUALT_VER=0.7
# NVIM_VERSION=${1-$NVIM_DEFUALT_VER}
# step:0 install prerequire
sudo apt update && sudo apt upgrade
sudo apt install -y \
	ninja-build \
	gettext \
	libtool \
	libtool-bin \
	autoconf \
	automake \
	pkg-config \
	doxygen \
	make \
	cmake

# step:1 clone
echo "✨ git cloned neovim"
git clone https://github.com/neovim/neovim.git ~/neovim

# step:2 build
cd ~/neovim
# master branchをビルド
# git checkout "release-${NVIM_VERSION}"
sudo make CMAKE_BUILD_TYPE=Release
sudo make install

cd -
sudo rm -rf ~/neovim
echo "✨ finished installing neovim"

# for jupyterlab
curl -sL https://deb.nodesource.com/setup_19.x | bash -
sudo apt upgrade -y && sudo apt install -yqq nodejs

# for nvim-treesitter
# Ocasionaly, we cannot install tree-sitter by nvim-treesitter, so manually install these packages by npm
# npm install --location=global tree-sitter tree-sitter-cli

echo "✨ finished installing nodejs"

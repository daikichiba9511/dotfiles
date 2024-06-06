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
# sudo apt update && sudo apt upgrade
# sudo apt install -y \
# 	ninja-build \
# 	gettext \
# 	libtool \
# 	libtool-bin \
# 	autoconf \
# 	automake \
# 	pkg-config \
# 	doxygen \
# 	make \
# 	cmake
#
# # step:1 clone
# echo "✨ git cloned neovim"
# git clone https://github.com/neovim/neovim.git ~/neovim
#
# # step:2 build
# cd ~/neovim
# # master branchをビルド
# # git checkout "release-${NVIM_VERSION}"
# sudo make CMAKE_BUILD_TYPE=Release
# sudo make install
#
# cd -
# sudo rm -rf ~/neovim
# echo "✨ finished installing neovim"

# Download stable version of neovim from github release for Linux
wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz -P /tmp
# For destinaton directory, use /tmp
mkdir -p ~/.local/bin/
tar xzvf /tmp/nvim-linux64.tar.gz -C ~/.local/bin/
sudo rm /tmp/nvim-linux64.tar.gz
[ -e /usr/local/bin/nvim ] && sudo rm /usr/local/bin/nvim
sudo ln -s ~/.local/bin/nvim-linux64/bin/nvim /usr/local/bin/nvim

if [ ! -e /usr/local/bin/nvim ]; then
	echo "######## ❌ Failed to install neovim?? (´・ω・｀) Plsease, check /usr/local/bin/nvim #########"
	exit 1
fi

# for jupyterlab $ pyright $ copilot.vim
# For Ubuntu
# Ref:
# [1] https://github.com/nodesource/distributions
echo "✨ installing nodejs for jupyterlab & pyright & copilot.vim"
sudo apt update
sudo apt install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/nodesource.gpg
NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt update
sudo apt install nodejs -yq

# for nvim-treesitter
# Ocasionaly, we cannot install tree-sitter by nvim-treesitter, so manually install these packages by npm
# npm install --location=global tree-sitter tree-sitter-cli

echo "✨ finished installing nodejs"

#!/bin/sh
set -eu

if which sudo >/dev/null 2>&1; then
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
	skkdic \
	fd-find \
	sqlite3 \
	libsqlite3-dev

# for telescop.nvim
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep_13.0.0_amd64.deb
sudo dpkg -i ripgrep_13.0.0_amd64.deb

wget https://github.com/ogham/exa/releases/download/v0.10.1/exa-linux-x86_64-v0.10.1.zip
mv exa-linux-x86_64-v0.10.1.zip "$HOME/"
unzip "$HOME/exa-linux-x86_64-v0.10.1.zip" -d "$HOME/.exa"
sudo cp "$HOME/.exa/bin/exa /usr/local/bin"

# for bat
# Ref: https://github.com/sharkdp/bat#on-ubuntu-using-apt
mkdir -p ~/.local/bin
rm -f ~/.local/bin/bat
sudo ln -sf /usr/bin/batcat ~/.local/bin/bat

# for delta
wget https://github.com/dandavison/delta/releases/download/0.16.5/delta-0.16.5-x86_64-unknown-linux-musl.tar.gz -P /tmp
tar xvf /tmp/delta-0.16.5-x86_64-unknown-linux-musl.tar.gz -C "${HOME}/.local/bin"
sudo ln -s "${HOME}/.local/bin/delta-0.16.5-x86_64-unknown-linux-musl/delta" /usr/local/bin/delta

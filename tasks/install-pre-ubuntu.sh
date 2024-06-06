#!/usr/bin/env bash
set -eux -o pipefail -o posix

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
	curl \
	wget \
	unzip \
	skkdic \
	fd-find \
	sqlite3 \
	libsqlite3-dev

# For yazi
# Ref:
# https://yazi-rs.github.io/docs/usage/installation
# ffmpegthumbnailer: video thumbnail
# unar: archive preview
#
sudo apt install -y \
	ffmpegthumbnailer \
	unar

# for telescop.nvim
wget https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep_13.0.0_amd64.deb -P /tmp
sudo dpkg -i /tmp/ripgrep_13.0.0_amd64.deb

[ -d "${HOME}/.exa" ] && rm -rf "${HOME}/.exa"
wget https://github.com/ogham/exa/releases/download/v0.10.1/exa-linux-x86_64-v0.10.1.zip -P /tmp
unzip /tmp/exa-linux-x86_64-v0.10.1.zip -d "${HOME}/.exa"
sudo ln -sf "$HOME/.exa/bin/exa" "/usr/local/bin"

# for bat
# Ref: https://github.com/sharkdp/bat#on-ubuntu-using-apt
[ -f /usr/bin/bat ] && sudo rm -f ~/.local/bin/bat
mkdir -p ~/.local/bin
rm -f ~/.local/bin/bat
sudo ln -sf /usr/bin/batcat ~/.local/bin/bat

# for delta
[ -f /usr/local/bin/delta ] && sudo rm -f /usr/local/bin/delta
wget https://github.com/dandavison/delta/releases/download/0.16.5/delta-0.16.5-x86_64-unknown-linux-musl.tar.gz -P /tmp
tar xvf /tmp/delta-0.16.5-x86_64-unknown-linux-musl.tar.gz -C "${HOME}/.local/bin"
sudo ln -s "${HOME}/.local/bin/delta-0.16.5-x86_64-unknown-linux-musl/delta" /usr/local/bin/delta

# For lsd
wget https://github.com/lsd-rs/lsd/releases/download/v1.0.0/lsd-musl_1.0.0_amd64.deb -P /tmp
sudo apt install -y /tmp/lsd-musl_1.0.0_amd64.deb

# For fzf
# update to the latest version
# cd "${HOME}/.fzf_bin" && ./install && sudo apt remove fzf
# wget https://github.com/junegunn/fzf/releases/download/0.46.1/fzf-0.46.1-linux_amd64.tar.gz -P /tmp
# tar xvf /tmp/fzf-0.46.1-linux_amd64.tar.gz -C "${HOME}/.fzf_bin"
git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
"$HOME/.fzf/install" --all

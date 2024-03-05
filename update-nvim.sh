# WARNING: use sudo user in this script
# Reference
# 1. https://qiita.com/r12tkmt/items/5c22c68c70f39f8d1168

[ ! -f "/tmp/neovim" ] && rm -rf ~/neovim
sudo rm /usr/local/bin/nvim
sudo rm -r /usr/local/share/nvim

# Build neovim from source
#
# cd "/tmp"
# git clone https://github.com/neovim/neovim.git
# cd "/tmp/neovim"
# git checkout release-0.9
# make CMAKE_BUILD_TYPE=Release
# sudo make install
# rm -rf "/tmp/neovim"

# Download stable version of neovim from github release for Linux
wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz -P /tmp
# For destinaton directory, use /tmp
mkdir -p ~/.local/bin/
tar xzvf /tmp/nvim-linux64.tar.gz -C ~/.local/bin/
sudo rm /tmp/nvim-linux64.tar.gz
[ -e /usr/local/bin/nvim ] && sudo rm /usr/local/bin/nvim
sudo ln -s ~/.local/bin/nvim-linux64/bin/nvim /usr/local/bin/nvim

# WARNING: use sudo user in this script
# Reference
# 1. https://qiita.com/r12tkmt/items/5c22c68c70f39f8d1168

[ ! -f "/tmp/neovim" ] && rm -rf ~/neovim
sudo rm /usr/local/bin/nvim
sudo rm -r /usr/local/share/nvim

cd "/tmp"
git clone https://github.com/neovim/neovim.git
cd "/tmp/neovim"
# git checkout v0.8.1
make CMAKE_BUILD_TYPE=Release
sudo make install
rm -rf "/tmp/neovim"


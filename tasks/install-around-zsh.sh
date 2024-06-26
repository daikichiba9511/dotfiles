#!/usr/bin/env bash
set -eux -o pipefail -o posix

# ubuntuのとき
# powerlineはzshのpromptのunicode文字列表示に必要
sudo apt install -y zsh powerline fonts-powerline

# defaultのshellを変更
# 次回以降のログイン時にshellを変える
sudo chsh "${USER}" -s "$(which zsh)"

# zplug
# curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
export ZPLUG_HOME="${HOME}/.zplug"
rm -rf "${ZPLUG_HOME}"
git clone https://github.com/zplug/zplug "${ZPLUG_HOME}"

# starship
# customize prompt
sudo curl -sS https://starship.rs/install.sh | sudo bash --posix -s -- -y

#!/bin/sh

# ubuntuのとき
# powerlineはzshのpromptのunicode文字列表示に必要
sudo apt-get install -y zsh powerline fonts-powerline

# defaultのshellを変更
# 次回以降のログイン時にshellを変える
chsh -s $(which zsh)
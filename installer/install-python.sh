#!/bin/sh
set -eu

PYTHON_DEFAULT=3.9.7
PYTHON_VER=${1-$PYTHON_DEFAULT}

echo "===== python install start ====="

# install prerequire
# Ref: https://zenn.dev/neruo/articles/install-pyenv-on-ubuntu
sudo apt install -y \
    libffi-dev libssl-dev zlib1g-dev liblzma-dev tk-dev \
    libbz2-dev libreadline-dev libsqlite3-dev libopencv-dev \
    build-essential

# control python versions by pyenv
git clone --depth 1 https://github.com/pyenv/pyenv.git $HOME/.pyenv

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
fi

pyenv install $PYTHON_DEFAULT

# if .zshrc exists
# assume that this .zshrc is under dotfiles (dotfiles/.zshrc)
[ ! -f '~/.zshrc ]' && source ~/.zshrc

# option versions
# pyenv install 3.7.12
# pyenv install 3.8.10

pyenv global $PYTHON_VER
echo ' ### check you python versions ### '
python --version
echo ' check installed versions'
pyenv versions

# use package manager poetry
# pip has low feature to resolve dependencies
# pipenv is too slow to resolve dependencies
# Ref:
# [1] https://python-poetry.org/
# [2] https://vaaaaaanquish.hatenablog.com/entry/2021/03/29/221715
# poetry docs recommends install poetry by curl
# but, it's so hassle to do version managing by curl... so via pip
python3 -m pip install --upgrade pip
python3 -m pip install poetry

echo '✅ finished developping python enviroment'

#!/bin/sh
set -eu

echo "===== python install start ====="

# control python versions by pyenv
git clone https://github.com/pyenv/pyenv.git ~/.pyenv

pyenv install 3.7.12 3.8.12 3.9.7

# use package manager poetry
# pip has low feature to resolve dependencies
# pipenv is too slow to resolve dependencies
# Ref:
# [1] https://python-poetry.org/
# [2] https://vaaaaaanquish.hatenablog.com/entry/2021/03/29/221715
# poetry docs recommends install poetry by curl
# but, it's so hassle to do version managing by curl... so via pip
python3 -m pip install poetry

echo '✅ finished developping python enviroment'
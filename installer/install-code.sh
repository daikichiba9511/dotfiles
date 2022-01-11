#!/bin/sh

set -eu

# とりあえずUbuntu向け
# 参考：https://code.visualstudio.com/docs/setup/linux
# debパッケージをcode_debにダウンロードしておく
sudo apt-get install ./code_deb/code_*.deb

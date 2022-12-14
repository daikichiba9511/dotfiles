#!/bin/sh

VERSION=20220408-101518-b908e2dd
curl -LO https://github.com/wez/wezterm/releases/download/$VERSION/wezterm-${VERSION}.Ubuntu20.04.deb
sudo apt install -y ./wezterm-${VERSION}.Ubuntu20.04.deb
sudo rm ./wezterm-${VERSION}.Ubuntu20.04.deb

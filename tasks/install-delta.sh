#!/bin/bash
# install git-delta to Ubuntu20.04
# Rlease Page: https://github.com/dandavison/delta/releases
echo 'install git-delta to Ubuntu20.04'
wget https://github.com/dandavison/delta/releases/download/0.15.1/delta-0.15.1-x86_64-unknown-linux-musl.tar.gz
tar -zxvf ./delta-0.15.1-x86_64-unknown-linux-musl.tar.gz
sudo mv ./delta-0.15.1-x86_64-unknown-linux-musl/delta /usr/local/bin

#!/bin/bash
set -eu

curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh |
	bash -s -- -f --repo rossmacarthur/sheldon --to ~/.local/bin

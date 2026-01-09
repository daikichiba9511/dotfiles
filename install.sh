#!/bin/bash
set -eu

DOTFILES_REPO="daikichiba9511/dotfiles"

echo "==> Installing dotfiles..."

# chezmoi をインストール（まだなければ）
if ! command -v chezmoi &> /dev/null; then
  echo "==> Installing chezmoi..."
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
  export PATH="$HOME/.local/bin:$PATH"
fi

# dotfiles を適用
echo "==> Applying dotfiles..."
chezmoi init --apply "$DOTFILES_REPO"

echo "==> Done! Please restart your shell."

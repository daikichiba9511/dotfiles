#!/bin/bash
set -eu

DOTFILES_REPO="https://github.com/daikichiba9511/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

echo "==> Installing dotfiles..."

# chezmoi をインストール（まだなければ）
if ! command -v chezmoi &> /dev/null; then
  echo "==> Installing chezmoi..."
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
  export PATH="$HOME/.local/bin:$PATH"
fi

# dotfiles を clone（まだなければ）
if [ ! -d "$DOTFILES_DIR" ]; then
  echo "==> Cloning dotfiles..."
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
  echo "==> Updating dotfiles..."
  git -C "$DOTFILES_DIR" pull
fi

# chezmoi の source directory を ~/dotfiles に設定して適用
echo "==> Applying dotfiles..."
chezmoi init --source "$DOTFILES_DIR"
chezmoi apply -v

echo "==> Done! Please restart your shell."

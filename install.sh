#!/bin/bash
set -eu

DEFAULT_PROFILE="nix"
DOTFILES_REPO="https://github.com/daikichiba9511/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"
CHEZMOI_BIN="$HOME/.local/bin/chezmoi"
CHEZMOI_CONFIG="$HOME/.config/chezmoi/chezmoi.toml"

usage() {
  echo "Usage: install.sh [--profile nix|mise]"
  echo
  echo "Profiles:"
  echo "  nix   Personal environment managed by Nix (default)"
  echo "  mise  Lightweight work environment managed by mise"
}

profile="$DEFAULT_PROFILE"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --profile)
      if [ "$#" -lt 2 ]; then
        echo "--profile requires nix or mise" >&2
        exit 2
      fi
      profile="$2"
      shift 2
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

case "$profile" in
  nix|mise) ;;
  *)
    echo "Unsupported profile: $profile (expected nix or mise)" >&2
    exit 2
    ;;
esac

echo "==> Installing dotfiles (profile: ${profile})..."

# chezmoi をインストール（まだなければ）
if [ ! -f "$CHEZMOI_BIN" ]; then
  echo "==> Installing chezmoi..."
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
fi

# dotfiles を clone（まだなければ）
if [ ! -d "$DOTFILES_DIR" ]; then
  echo "==> Cloning dotfiles..."
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
  echo "==> Updating dotfiles..."
  git -C "$DOTFILES_DIR" pull --ff-only
fi

# マシン固有のプロファイルをchezmoiへ渡す
mkdir -p "$HOME/.config/chezmoi"
config_tmp="$(mktemp "${CHEZMOI_CONFIG}.tmp.XXXXXX")"
trap 'rm -f "$config_tmp"' EXIT
{
  printf 'sourceDir = "%s"\n\n' "$DOTFILES_DIR"
  printf '[data]\n'
  printf '    environment_profile = "%s"\n\n' "$profile"
  printf '[edit]\n'
  printf '    command = "nvim"\n'
} > "$config_tmp"
chmod 600 "$config_tmp"
mv "$config_tmp" "$CHEZMOI_CONFIG"
trap - EXIT

# dotfiles を適用
echo "==> Applying dotfiles..."
"$CHEZMOI_BIN" apply -v

echo "==> Done! Please restart your shell."

#!/bin/bash
set -eu

if [[ "$(uname)" != "Darwin" ]]; then
  echo "This script is for macOS only"
  exit 1
fi

echo "==> Installing macOS window management tools..."

# Check if Homebrew is available
if ! command -v brew &> /dev/null; then
  echo "Homebrew not found. Please install it first."
  exit 1
fi

# AeroSpace - tiling window manager
if ! brew list --cask aerospace &> /dev/null; then
  echo "Installing AeroSpace..."
  brew install --cask nikitabobko/tap/aerospace
fi

# JankyBorders - window border highlight
if ! brew list borders &> /dev/null; then
  echo "Installing JankyBorders..."
  brew install FelixKratz/formulae/borders
  brew services start borders
fi

# SketchyBar - custom menu bar
if ! brew list sketchybar &> /dev/null; then
  echo "Installing SketchyBar..."
  brew install FelixKratz/formulae/sketchybar
  brew services start sketchybar
fi

# AltTab - window switcher
if ! brew list --cask alt-tab &> /dev/null; then
  echo "Installing AltTab..."
  brew install --cask alt-tab
fi

# choose-gui - picker for workspace selection
if ! command -v choose &> /dev/null; then
  echo "Installing choose-gui..."
  brew install choose-gui
fi

echo ""
echo "==> macOS window management tools installed!"
echo ""
echo "Next steps:"
echo "  1. Open AeroSpace and grant accessibility permission"
echo "  2. Open AltTab and grant accessibility permission"
echo "  3. Run: open -a AeroSpace"
echo "  4. Run: open -a AltTab"

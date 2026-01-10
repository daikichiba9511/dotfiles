# dotfiles

This repository is daikichiba9511's dotfiles, managed with [chezmoi](https://www.chezmoi.io/).

I write program/documents like machine learning modeling, data science, documentation w/ Neovim in WezTerm on Ubuntu/macOS.

## My Environment List

- Ubuntu 24.04.3 LTS / macOS

- neovim latest
  - lazy.nvim (package manager)
  - blink.cmp (completion)
  - nvim-lspconfig + mason (LSP)
  - nvim-treesitter
  - fzf-lua
  - copilot.lua, CopilotChat, Avante, claude-code.nvim (AI)
  - catppuccin (colorscheme)
  - lualine.nvim, bufferline.nvim
  - snacks.nvim (dashboard, explorer, picker, notifier, etc.)
  - vim-fugitive, gitsigns.nvim (git)
  - conform.nvim (formatter)
  - toggleterm.nvim
  - which-key.nvim
  - obsidian.nvim

- wezterm (terminal)
- zsh (shell)
- starship (prompt)
- mise (runtime version manager)
- nodejs == 22.x

### macOS Window Management

- AeroSpace (tiling window manager)
- SketchyBar (custom menu bar)
- JankyBorders (window border highlight)
- AltTab (window switcher)

## Installation

### Quick Install (one-liner)

```sh
curl -fsLS https://raw.githubusercontent.com/daikichiba9511/dotfiles/main/install.sh | bash
```

### Manual Install

1. Install chezmoi

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
```

2. Clone and apply dotfiles

```sh
git clone https://github.com/daikichiba9511/dotfiles.git ~/dotfiles
~/.local/bin/chezmoi init --source ~/dotfiles --apply
```

### macOS: Install Window Management Tools

After initial setup, run the following to install macOS window management tools:

```sh
~/.local/bin/install-macos-wm.sh
```

This installs AeroSpace, SketchyBar, JankyBorders, AltTab, and choose-gui.

## Updating

```sh
chezmoi update
```

Or pull manually and apply:

```sh
cd ~/dotfiles && git pull && chezmoi apply
```

## Keybindings

### WezTerm

| Key | Action |
|-----|--------|
| `Cmd+Shift + h/l` | Previous/Next tab |
| `Cmd+Shift + k` | New tab |
| `Cmd+Shift + j` | Close tab |
| `Cmd+Shift + -` | Split vertical |
| `Cmd+Shift + \` | Split horizontal |
| `Ctrl+Shift + h/j/k/l` | Move between panes |
| `Cmd+Shift + a` | Open Claude Code |

### AeroSpace (macOS)

| Key | Action |
|-----|--------|
| `Alt + h/j/k/l` | Focus window (across monitors) |
| `Alt + Shift + h/j/k/l` | Move window |
| `Alt + 1-9` | Switch workspace |
| `Cmd+Shift + 1-9` | Move window to workspace |
| `Alt + w` | Workspace picker |
| `Alt + f` | Fullscreen |
| `Alt + t` | Toggle float |
| `Alt + r` | Resize mode |

## Structure

```
~/dotfiles/
├── .chezmoiignore          # OS-specific ignore rules
├── install.sh              # Bootstrap script
├── run_once_*.sh.tmpl      # One-time setup scripts
├── private_dot_config/     # ~/.config/*
├── private_dot_local/      # ~/.local/*
└── dot_*                   # ~/.*
```

## References

- [chezmoi](https://www.chezmoi.io/)
- [yutkat/dotfiles](https://github.com/yutkat/dotfiles)
- [FelixKratz/dotfiles](https://github.com/FelixKratz/dotfiles) - SketchyBar reference
- [nikitabobko/AeroSpace](https://github.com/nikitabobko/AeroSpace)

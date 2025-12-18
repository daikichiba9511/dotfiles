# dotfiles

This repository is daikichiba9511's dotfiles.

If you want to know an install procedure more, please see setup.sh.
I write program/documents like machine learing modeling , data science, documentation w/ Neovim in wezterm on Ubuntu.

## My Environment List

- Ubuntu 24.04.3 LTS

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
- nodejs == 22.x

## How

- procedure

1. clone this repository
2. move
3. run a setup script
4. back to previous directory

one-line commands

```sh
git clone --depth 1 git@github.com:daikichiba9511/dotfiles.git ~/dotfiles && cd ~/dotfiles && bash setup.sh && cd -
```

### 1. clone this repository

```sh
git clone --depth 1 git@github.com:daikichiba9511/dotfiles.git ~/dotfiles
```

### 2. move

```sh
cd ~/dotfiles
```

### 3. run a setup script

```sh
bash setup.sh
```

### 4. back to previous directory

```sh
cd -
```

# References

[1] [yutkat/dotfiles](https://github.com/yutkat/dotfiles)

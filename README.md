# dotfiles

This repository is daikichiba9511's dotfiles.

If you want to know an install procedure more, please see setup.sh.
I write program/documents like machine learing modeling , data science, documentation w/ Neovim in wezterm on Ubuntu.

## My Environment List

- Ubuntu 22.04

- neovim latest
  - LazyVim + some customizations
    - Extras
      - copilot
      - copilot-chat
      - telescope
      - lang
        - clangd(c++)
        - python
        - rust
        - sql
        - terraform
        - toml
        - typescript
        - yaml
    - bufdelete.nvim
    - otter.nvim
    - obsidian.nvim
    - headlines.nvim
    - toggleterm.nvim

etc.

- wezterm (terminal)
- zsh (shell)
- starship (prompt)
- nodejs == 22.x

## Screenshot

- screenshot on macos

![screenshot-on-macos](./assets/neovim-tokyonight-20221124.png)

![screenshot-telescope-on-macos](./assets/neovim-tokyonight-telescope-20221124.png)

## How

- procedure

1. clone this repository
2. move
3. run a setup script
4. back to previous directory

one-line commands

```sh
git clone git@github.com:daikichiba9511/dotfiles.git ~/dotfiles && cd ~/dotfiles && bash setup.sh && cd -
```

### 1. clone this repository

```sh
git clone git@github.com:daikichiba9511/dotfiles.git ~/dotfiles
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

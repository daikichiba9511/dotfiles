# dotfiles

this repository has codes of my dotfiles. if you want to know entire install procedure, refer to scripts/setup.sh.

But, these code has some bugs (e.g. install-python etc.), so be careful if you use these codes

## Used

- neovim latest
  - packer.nvim
  - nvim-lsp

- wezterm


## How

```sh
# procedure

# 1. clone this repository
git clone git@github.com:daikichiba9511/dotfiles.git ~/dotfiles

# 2. move
cd ~/dotfiles

# 3 run a setup script
sh scripts/setup.sh y

## if you want to install python
sh scripts/setup.sh y python

# 4 return
cd -

```

oneline commands

```
git clone git@github.com:daikichiba9511/dotfiles.git ~/dotfiles && cd ~/dotfiles && sh scripts/setup.sh y&& cd -
```

# Reference

[1] [yutkat/dotfiles](https://github.com/yutkat/dotfiles)

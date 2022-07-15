# dotfiles

this repository has codes of my dotfiles. if you want to know entire install procedure, refer to scripts/setup.sh.

But, these code has some bugs (e.g. install-python etc.), so be careful if you use these codes

## How

```shell
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

NOTE:

_`jeai-language-sever` is no longer used !_

Now, I use coc-pyright, so do not have to install jedi-language-server.

~~if you use Python at NeoVim, you should install `jedi-lanugage-server`.~~

```
pip install jedi-lanugage-server
```

# Reference

[1] [yutkat/dotfiles](https://github.com/yutkat/dotfiles)

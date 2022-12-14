# dotfiles

this repository has codes of my dotfiles. if you want to know entire install procedure, you should refer to scripts/setup.sh.

But, these code might have some bugs (e.g. install-python etc., Sorry), so be careful please...

I always develop machine learing model , datascience code , etc with Neovim in wezterm on Ubuntu (local os and docker container).

I think your that your tasks are ok If being on Ubuntu(local/docker container), because I always write something like code or document in Neovim on Ubuntu.

## My Environment List

- Ubuntu 20.04

- neovim latest
  - packer.nvim
  - nvim-lsp
  - nvim-cmp
  - telescope
  - sidevar
  - luasnip
  - lualine
  - mason
  - mason-lspconfig
  - null-ls

etc.

- wezterm
- zsh
- starship

I have prepared some task files in 'tasks' directory (mostly about install/setup)

If you want to see in details, see prepared tasks, please.

## Screenshot

- screenshot on macos

![screenshot-on-macos](./assets/neovim-tokyonight-20221124.png)

![screenshot-telescope-on-macos](./assets/neovim-tokyonight-telescope-20221124.png)


## How

- procedure

1. clone this repository

```sh
git clone git@github.com:daikichiba9511/dotfiles.git ~/dotfiles
```
2. move

```sh
cd ~/dotfiles
```

3. run a setup script

```sh
bash setup.sh
```

- (optional) if you want to install python

```sh
bash setup.sh -p
```

or

```sh
bash tasks/install-python.sh
```

- (optional) if you want to install rust

```sh
bash setup.sh -r
```

or

```sh
bash tasks/install-rust.sh
```


5. back to previous directory
```sh
cd -
```

- one-line commands

```sh
git clone git@github.com:daikichiba9511/dotfiles.git ~/dotfiles && cd ~/dotfiles && bash setup.sh && cd -
```

## For python user

- prerequire
    - python is installed on your environment
    - node.js is installed on your environment
        - Install 'Pyright' with MasonInstall is by npm
        - and require node.js runtime for pyright
- If you don't prefer to use pyright, you should install other Python Lsp. See details by using ':Mason', please.

1. Clone this repository
2. Run 'bash scripts/setup.sh'
3. Open Neovim
4. Type `:PackerSync`
5. Close Neovim at once
6. Open Neovim and type `:MasonInstall pyright`
7. If you wanna use formatter with opeened buffer, type `pip install black` on your terminal.  If you install black in your develop environment, the Neovim format buffer automatically (by using null-ls).


# Reference

[1] [yutkat/dotfiles](https://github.com/yutkat/dotfiles)

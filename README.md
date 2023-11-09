# dotfiles

This repository is daikichiba9511's dotfiles. 

If you want to know an install procedure more, you should see scripts/setup.sh.
I do programming such as machine learing model , data science and documentation with Neovim in wezterm on Ubuntu (local os and docker container) efficiently.
I think everything is OK on Ubuntu22.04, since I always do something like writing code or documentation in Neovim which is build on Ubuntu.

## My Environment List

- Ubuntu 22.04

- neovim latest
  - lazy.nvim (package manager)
  - nvim-cmp (completion)
  - telescope (fuzzy finder)
  - sidebar (filer)
  - luasnip (snipet)
  - lualine (beautiful status line)
  - mason (lsp installer)
  - mason-lspconfig (bridge lsp is installed by mason and nvim-lsp easily)
  - null-ls (formatter and linter)

etc.

- wezterm (terminal)
- zsh (shell)
- starship (prompt)
- nodejs == 19.x

I have prepared task files in the 'tasks' directory (For example, install prerequires of neovim)
If you want to know about it more, Please see 'tasks' directory.

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

When you want to use statistic analyze about python code, you need to install nodejs and python on your environment since we need to use 'pyright' (most recommend choice for now...)
Please see 'tasks/install-nvim.sh' which is the install script to install nodejs

After the installation, Please open neovim and then type the command bellow.

```
:MasonInstall pyright
```

If you don't prefer to use pyright, you should install other Python Lsp. See details by executing ':Mason', please.

1. Clone this repository
2. Run 'bash scripts/setup.sh'
3. Open Neovim
4. Type `:Lazy sync`
5. Close Neovim.
6. Reopen Neovim and type `:MasonInstall pyright` if you want to use python with LSP support.

Let's enjoy python with neovim !!

# Reference

[1] [yutkat/dotfiles](https://github.com/yutkat/dotfiles)

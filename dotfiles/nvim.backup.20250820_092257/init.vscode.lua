local opt = vim.o
local keymap = vim.api.nvim_set_keymap

vim.g.clipboard = vim.g.vscode_clipboard
vim.opt.clipboard:append("unnamedplus")

-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local set_keymap = vim.keymap.set

set_keymap("n", "<C-j>", "<cmd>bprev<cr>", { silent = true, desc = "Prev buffer" })
set_keymap("n", "<C-k>", "<cmd>bnext<cr>", { silent = true, desc = "Next buffer" })

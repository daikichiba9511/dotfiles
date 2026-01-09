-- Core settings
-- Set <space> as the leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Transparent background toggle
_G.transparent_enabled = false

local function toggle_transparent()
  _G.transparent_enabled = not _G.transparent_enabled

  if _G.transparent_enabled then
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
    vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
    vim.api.nvim_set_hl(0, "Folded", { bg = "none" })
    vim.api.nvim_set_hl(0, "NonText", { bg = "none" })
    vim.api.nvim_set_hl(0, "SpecialKey", { bg = "none" })
    vim.api.nvim_set_hl(0, "VertSplit", { bg = "none" })
    vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
    vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
  else
    vim.cmd("colorscheme catppuccin")
  end
end

vim.keymap.set("n", "<leader>bg", toggle_transparent, { desc = "Toggle transparent background" })

-- Define User Commands
vim.api.nvim_create_user_command("Config", "edit $MYVIMRC", {})

-- kickstart.nvim inspired minimal configuration
-- https://github.com/nvim-lua/kickstart.nvim

-- Load core settings (leader key, basic functions, etc.)
require("core")

-- Install package manager (lazy.nvim)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Configure plugins
-- Load all plugin configurations from the plugins directory
require("lazy").setup("plugins", {})

-- LSP configuration
require("lsp")

-- Load custom configurations
require("config.options")
require("config.keymaps")
require("config.autocmds")

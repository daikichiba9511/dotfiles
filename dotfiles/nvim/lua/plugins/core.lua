local opt = vim.opt
local keymap = vim.api.nvim_set_keymap

opt.list = true
opt.listchars = { tab = "»»", space = "·" }

keymap("n", "<C-x>", "<Cmd>lua require('bufdelete').bufwipeout(0, true)<CR>", { noremap = true, silent = true })

return {}

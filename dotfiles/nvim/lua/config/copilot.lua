-- require("copilot").setup({})

vim.g.copilot_no_tab_map = true
vim.g.copilot_filetypes = { markdown = true, gitcommit = true } -- enable copilot completion for markdown and gitcommit files

local keymap = vim.keymap.set
-- https://github.com/orgs/community/discussions/29817#discussioncomment-4217615
keymap("i", "<C-g>", 'copilot#Accept("<CR>")', { silent = true, expr = true, script = true, replace_keycodes = false })
keymap("i", "<C-j>", "<Plug>(copilot-next)")
keymap("i", "<C-k>", "<Plug>(copilot-previous)")
keymap("i", "<C-o>", "<Plug>(copilot-dismiss)")
keymap("i", "<C-s>", "<Plug>(copilot-suggest)")

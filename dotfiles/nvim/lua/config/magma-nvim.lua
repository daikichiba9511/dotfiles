vim.api.nvim_set_keymap("n", "<LocalLeader>r", ":MagmaEvaluateOperator", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<LocalLeader>rr", ":MagmaEvaluateLine<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<LocalLeader>ro", ":MagmaShowOutput<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<LocalLeader>rc", ":MagmaReevaluateCell<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<LocalLeader>rd", ":MagmaDelete<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<LocalLeader>rq", ":noautocmd MagmaEnterOutput<CR>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("x", "<LocalLeader>rr", "<C-u>MagmaEvaluateVisual<CR>", { silent = true })

vim.cmd([[xnoremap <silent> <LocalLeader>r :<C-u>MagmaEvaluateVisual<CR>]])

vim.g.magma_automatically_open_output = false
vim.g.magma_image_provider = "ueberzug"

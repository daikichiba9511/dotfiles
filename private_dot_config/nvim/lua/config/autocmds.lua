-- Autocmds configuration

-- MDX filetype
vim.filetype.add({
  extension = {
    mdx = "mdx",
  },
})

-- MDX uses markdown treesitter parser for highlighting
vim.treesitter.language.register("markdown", "mdx")

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- Terminal settings
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = '*',
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = 'no'
  end,
})

-- 外部でファイルが変更されたら自動で再読み込み (LazyVim style)
-- CursorHold/CursorHoldI: カーソルが updatetime (250ms) 動かない時にもチェック
vim.api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave', 'CursorHold', 'CursorHoldI' }, {
  group = vim.api.nvim_create_augroup('checktime', { clear = true }),
  callback = function()
    if vim.o.buftype ~= 'nofile' then
      vim.cmd('checktime')
    end
  end,
})
local opt = vim.opt
opt.termguicolors = true
opt.cursorline = true

opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.fileencodings = "ucs-boms,utf-8,euc-jp,cp932"
opt.fileformats = "unix,dos,mac"

opt.number = true
opt.showmatch = true

opt.smartindent = true
opt.autoindent = true
opt.autoread = true
opt.expandtab = true
opt.wildmenu = true
opt.history = 5000

opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4

opt.clipboard:append("unnamedplus")

opt.list = true
opt.listchars:append("tab:>-")

vim.api.nvim_set_keymap("i", "jj", "<ESC>", { silent = true })
vim.api.nvim_set_keymap("n", "<C-j>", ":bprev<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-k>", ":bnext<CR>", { noremap = true, silent = true })

-- [lsp]
vim.keymap.set("n", ";", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("n", "[lsp]", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", ";", "[lsp]", {})


-- package はplugins.luaで管理
require("plugins")

vim.cmd [[
augroup Packer
    autocmd!
    autocmd BufWritePost plugin.lua,init.lua PackerCompile
augroup END
]]

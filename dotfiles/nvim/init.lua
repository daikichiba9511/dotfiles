local opt = vim.opt
opt.termguicolors = true

opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.fileencodings = "ucs-boms,utf-8,euc-jp,cp932"
opt.fileformats = "unix,dos,mac"

-- opt.number = true
opt.relativenumber = true
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

local function set_tab(file_type, indent_num)
    vim.cmd(string.format(" autocmd FileType %s setlocal shiftwidth=%s tabstop=%s ", file_type, indent_num, indent_num))
end

local tab2_ft = {
    "c",
    "cpp",
    "typescript",
    "markdown",
}
for _, ft in ipairs(tab2_ft) do
    set_tab(ft, 2)
end

-- vim.cmd([[ autocmd FileType cpp setlocal shiftwidth=2 tabstop=2 ]])
-- vim.cmd([[ autocmd FileType typescript setlocal shiftwidth=2 tabstop=2 ]])
-- vim.cmd([[ autocmd FileType markdown set shiftwidth=2 tabstop=2 ]])

opt.clipboard:append("unnamedplus")
opt.hidden = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.wrapscan = true

-- vscode neovimで動作を切り替えたい設定
if vim.g.vscode then
    opt.cursorline = false
    opt.hlsearch = false
else
    opt.cursorline = true
    opt.hlsearch = true
    opt.incsearch = true
end

--

opt.list = true
opt.listchars:append("tab:>-")

vim.api.nvim_set_keymap("i", "jj", "<ESC>", { silent = true })
vim.api.nvim_set_keymap("n", "<C-j>", ":bprev<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-k>", ":bnext<CR>", { noremap = true, silent = true })

-- [lsp]
vim.keymap.set("n", ";", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("n", "[lsp]", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", ";", "[lsp]", {})

-- [FuzzyFinder]
vim.keymap.set("n", "z", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("n", "Z", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "z", "[FuzzyFinder]", {})
vim.api.nvim_set_keymap("v", "z", "[FuzzyFinder]", {})

-- vim.cmd([[ set sh=zsh ]])

-- package はplugins.luaで管理
require("plugins")

vim.cmd([[
    augroup Packer
        autocmd!
        autocmd BufWritePost plugin.lua,init.lua PackerCompile
    augroup END
]])

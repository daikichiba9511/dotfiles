local opt = vim.opt
-- package はplugins.luaで管理
-- require("plugins")

-- vim.cmd([[
--     augroup Packer
--         autocmd!
--         autocmd BufWritePost plugin.lua,init.lua PackerCompile
--     augroup END
-- ]])
--

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

local set_keymap = vim.api.nvim_set_keymap
set_keymap("i", "jj", "<ESC>", { silent = true })
set_keymap("n", "<C-j>", ":bprev<CR>", { noremap = true, silent = true })
set_keymap("n", "<C-k>", ":bnext<CR>", { noremap = true, silent = true })
set_keymap("n", "<C-k>", ":bnext<CR>", { noremap = true, silent = true })
set_keymap("n", "<C-x>", ":bd<CR>", { noremap = true, silent = true })

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

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

Colorscheme = "tokyonight"
-- Colorscheme = "nightowl"

-- plugins {{{
require("lazy").setup({
	-- colorscheme
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("config/tokyonight")
		end,
	},
	-- {
	-- "oxfist/night-owl.nvim",
	-- lazy = false,
	-- priority = 1000,
	-- config = function()
	-- 	-- require("config/nightowl.lua")
	-- 	vim.cmd.colorscheme("night-owl")
	-- end,
	-- },
	{ "nvim-lua/plenary.nvim" }, -- do not lazy load
	{ "folke/which-key.nvim" },
	{ "folke/neodev.nvim" },
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
		},
		config = function()
			require("config/nvim-cmp")
		end,
	},
	{ "hrsh7th/cmp-nvim-lsp", module = "cmp_nvim_lsp", after = "nvim-cmp" },
	{ "hrsh7th/cmp-nvim-lsp-signature-help", after = "nvim-cmp" },
	{ "hrsh7th/cmp-nvim-lsp-document-symbol", after = "nvim-cmp" },
	{ "hrsh7th/cmp-buffer", after = "nvim-cmp" },
	{ "hrsh7th/cmp-path", after = "nvim-cmp" },
	{ "hrsh7th/cmp-nvim-lua", after = "nvim-cmp" },
	{ "hrsh7th/cmp-emoji", after = "nvim-cmp" },
	{ "hrsh7th/cmp-calc", after = "nvim-cmp" },
	{ "hrsh7th/cmp-cmdline", after = "nvim-cmp" },
	{ "saadparwaiz1/cmp_luasnip", after = "nvim-cmp" },
	{ "f3fora/cmp-spell", after = "nvim-cmp" },
	{ "ray-x/cmp-treesitter", after = "nvim-cmp" },
	{ "lukas-reineke/cmp-under-comparator", after = { "nvim-cmp" } },
	{ "hrsh7th/cmp-omni", after = "nvim-cmp" },
	{
		"L3MON4D3/LuaSnip",
		event = "VimEnter",
		config = function()
			require("config/LuaSnip")
		end,
	},
	{ "nvim-tree/nvim-web-devicons", lazy = true },
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		config = function()
			require("config/todo-comments")
		end,
	},
	-- Comment out
	{
		"numToStr/Comment.nvim",
		event = "VimEnter",
		config = function()
			require("config/Comment")
		end,
	},
	{
		"onsails/lspkind-nvim",
		module = "lspkind",
		config = function()
			require("config/lspkind-nvim")
		end,
	},
	{
		"williamboman/mason.nvim",
		event = "VimEnter",
		config = function()
			require("config.mason")
		end,
	},
	---- Masonでインストールしたツールのセットアップをする
	{
		"williamboman/mason-lspconfig.nvim",
		after = { "mason.nvim", "nvim-lspconfig", "cmp-nvim-lsp", "nlsp-settings.nvim" },
		config = function()
			require("config.mason-lspconfig")
		end,
	},
	{
		"tamago324/nlsp-settings.nvim",
		after = { "nvim-lspconfig" },
		config = function()
			require("config/nlsp-settings")
		end,
	},
	-- LSPの機能強化系
	{
		"neovim/nvim-lspconfig",
		cofnig = function()
			require("config.nvim-lspconfig")
		end,
	},
	------ status lineにコンテキストを出すのに使う
	{
		"SmiteshP/nvim-navic",
		module = "nvim-navic",
	},
	--         use({
	--             "weilbith/nvim-lsp-smag",
	--             after = "nvim-lspconfig",
	--         })
	------ LSPの情報使ってUIをかっこよくする
	{
		"kkharji/lspsaga.nvim",
		config = function()
			require("config/lspsaga")
		end,
	},
	--         use({
	--             "folke/lsp-colors.nvim",
	--             module = "lsp-colors",
	--         })
	--
	------ 関数の引数とかdocstringとかをpopupに出す
	{
		"ray-x/lsp_signature.nvim",
		after = { "mason.nvim", "nvim-lspconfig", "cmp-nvim-lsp", "nlsp-settings.nvim" },
		config = function()
			require("lsp_signature").setup({})
		end,
	},
	{
		"folke/trouble.nvim",
		config = function()
			require("config.trouble")
		end,
	},
	-- 通知を良い感じにする
	{
		"j-hui/fidget.nvim",
		tag = "legacy",
		config = function()
			require("config.fidget")
		end,
	},
	{
		"myusuf3/numbers.vim",
	},
	{
		"nvim-telescope/telescope.nvim",
		requires = { { "nvim-lua/plenary.nvim", opt = true }, { "nvim-lua/popup.nvim", opt = true } },
		after = { Colorscheme },
		event = "VimEnter",
		config = function()
			require("config.telescope")
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter",
		after = { Colorscheme },
		event = "VimEnter",
		run = function()
			require("nvim-treesitter.install").update({ with_sync = true })
		end,
		config = function()
			if vim.g.vscode then
				return nil
			else
				require("config/nvim-treesitter")
			end
		end,
	},
	{ "JoosepAlviste/nvim-ts-context-commentstring", after = { "nvim-treesitter" } },
	{ "nvim-treesitter/nvim-treesitter-refactor", after = { "nvim-treesitter" } },
	{ "nvim-treesitter/nvim-tree-docs", after = { "nvim-treesitter" } },
	-- use({ "vigoux/architext.nvim", after = { "nvim-treesitter" } })
	{ "yioneko/nvim-yati", after = "nvim-treesitter" },

	--
	-- StatusLine
	{
		"nvim-lualine/lualine.nvim",
		after = Colorscheme,
		requires = { "kyazdani42/nvim-web-devicons", opt = true },
		config = function()
			require("config/lualine")
		end,
	},
	{
		"akinsho/bufferline.nvim",
		version = "*",
		requires = "nvim-tree/nvim-web-devicons",
		config = function()
			require("config.bufferline")
		end,
	},

	{
		"GustavoKatel/sidebar.nvim",
		-- cmd = { "SidebarNvimToggle" },
		config = function()
			require("config/sidebar")
		end,
	},
	{
		"lambdalisue/fern.vim",
		config = function()
			require("config/fern")
		end,
	},
	{
		"lewis6991/hover.nvim",
		event = "VimEnter",
		config = function()
			require("config/hover")
		end,
	},
	-- Reading             assistant
	---- 選択してる行がどのインデント内にいるかわかりやすくする
	{
		"lukas-reineke/indent-blankline.nvim",
		after = { Colorscheme },
		event = "VimEnter",
		config = function()
			if not vim.g.vscode then
				require("config/indent-blankline")
			else
				return
			end
		end,
	},

	{
		"windwp/nvim-autopairs",
		event = "VimEnter",
		config = function()
			require("config/nvim-autopairs")
		end,
	},
	-- Lint & Formatter
	{
		"jose-elias-alvarez/null-ls.nvim",
		config = function()
			require("config/null-ls")
		end,
	},

	{ "bfredl/nvim-luadev", event = "VimEnter" },
	{ "folke/lua-dev.nvim", module = "lua-dev" },
	-- { "wadackel/nvim-syntax-info",    cmd = { "SyntaxInfo" } },
	{ "iamcco/markdown-preview.nvim", ft = { "markdown" }, run = ":call mkdp#util#install()" },
	{
		"lewis6991/gitsigns.nvim",
		-- config = function()
		--     require("config/gitsigns")
		-- end,
	},
	{
		"akinsho/toggleterm.nvim",
		config = function()
			require("config/toggleterm")
		end,
	},
	{
		"github/copilot.vim",
		config = function()
			require("config/copilot")
		end,
	},
	{ "kevinhwang91/nvim-bqf" },
})

-- }}}

local opt = vim.opt
local set_keymap = vim.api.nvim_set_keymap

-- package はplugins.luaで管理
-- require("plugins")

-- vim.cmd([[
--     augroup Packer
--         autocmd!
--         autocmd BufWritePost plugin.lua,init.lua PackerCompile
--     augroup END
-- ]])
--
-- vim.g.mapleader = " "

opt.termguicolors = true

opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.fileencodings = "ucs-boms,utf-8,euc-jp,cp932"
opt.fileformats = "unix,dos,mac"
opt.swapfile = false

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
opt.shell = "/usr/bin/zsh"

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

opt.clipboard = "unnamedplus"
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

opt.list = true -- show tabs
opt.listchars = { tab = "-»", space = "·" }

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

-- References:
-- https://riq0h.jp/2023/01/20/210601/

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

local pystubpath = vim.fn.stdpath("data") .. "/lazy/python-type-stubs"
if not vim.loop.fs_stat(pystubpath) then
	vim.fn.system({
		"git",
		"clone",
		"--depth=1",
		"https://github.com/microsoft/python-type-stubs.git",
		pystubpath,
	})
end

Colorscheme = "tokyonight"
-- Colorscheme = "nightowl"
--

local lazy_opts = {
	defaults = {
		lazy = true,
	},
	peformance = {
		cache = {
			enabled = true,
		},
	},
}

-- plugins {{{
require("lazy").setup({
	-- colorscheme
	{
		"folke/tokyonight.nvim",
		priority = 1000,
		lazy = false,
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
	{ "nvim-lua/plenary.nvim", lazy = false }, -- do not lazy load
	{ "folke/which-key.nvim" },
	{
		"folke/neodev.nvim",
		ft = "lua",
		config = function()
			require("neodev").setup()
		end,
	},

	-- Completion using nvim-cmp {{
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter, CmdlineEnter",
		version = false,
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			require("config/nvim-cmp")
		end,
	},
	{ "hrsh7th/cmp-nvim-lsp", event = "InsertEnter" },
	{ "hrsh7th/cmp-nvim-lsp-signature-help", event = "InsertEnter" },
	{ "hrsh7th/cmp-nvim-lsp-document-symbol", event = "InsertEnter" },
	{ "hrsh7th/cmp-buffer", event = "InsertEnter" },
	{ "hrsh7th/cmp-path", event = "InsertEnter" },
	{ "hrsh7th/cmp-nvim-lua", event = "InsertEnter" },
	{ "hrsh7th/cmp-emoji", event = "InsertEnter" },
	{ "hrsh7th/cmp-calc", event = "InsertEnter" },
	{ "hrsh7th/cmp-cmdline", event = "ModeChanged" },
	{ "saadparwaiz1/cmp_luasnip", event = "InsertEnter" },
	{ "f3fora/cmp-spell", event = "InsertEnter" },
	{ "ray-x/cmp-treesitter", event = "InsertEnter" },
	{ "lukas-reineke/cmp-under-comparator", event = "InsertEnter" },
	{ "hrsh7th/cmp-omni", event = "InsertEnter" },
	-- {
	-- 	"zbirenbaum/copilot-cmp",
	-- 	event = "InsertEnter",
	-- 	after = { "copilot.lua" },
	-- 	config = function()
	-- 		require("copilot_cmp").setup()
	-- 	end,
	-- },
	-- }}
	-- {
	-- 	"zbirenbaum/copilot.lua",
	-- 	cmd = "Copilot",
	-- 	event = "InsertEnter",
	-- 	config = function()
	-- 		require("copilot").setup({})
	-- 	end,
	-- },
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
		config = function()
			require("config/lspkind-nvim")
		end,
	},
	-- Lsp
	{
		"williamboman/mason.nvim",
		event = { "WinNew", "WinLeave", "BufRead" },
		build = ":MasonUpdate",
		config = function()
			-- require("config.mason")
			require("mason").setup()
		end,
	},
	---- Masonでインストールしたツールのセットアップをする
	{
		"williamboman/mason-lspconfig.nvim",
		event = "BufRead",
		config = function()
			require("config.mason-lspconfig")
		end,
	},
	{
		"tamago324/nlsp-settings.nvim",
		event = "VimEnter",
		config = function()
			require("config/nlsp-settings")
		end,
	},
	-- LSPの機能強化系
	{
		"neovim/nvim-lspconfig",
		event = "BufRead",
		dependencies = {
			-- Automatically install LSPs to stdpath for neovim
			{ "williamboman/mason.nvim", config = true },
			"williamboman/mason-lspconfig.nvim",

			-- Useful status updates for LSP
			-- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
			-- { "j-hui/fidget.nvim" },

			-- Additional lua configuration, makes nvim stuff amazing!
			{ "folke/neodev.nvim" },
		},
		cofnig = function()
			require("config.nvim-lspconfig")
		end,
	},
	------ status lineにコンテキストを出すのに使う
	{
		"SmiteshP/nvim-navic",
		event = "VimEnter",
	},
	--         use({
	--             "weilbith/nvim-lsp-smag",
	--         })
	------ LSPの情報使ってUIをかっこよくする
	{
		"kkharji/lspsaga.nvim",
		event = "InsertEnter",
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
		event = "InsertEnter",
		config = function()
			require("lsp_signature").setup({})
		end,
	},
	{
		"folke/trouble.nvim",
		event = "BufRead",
		config = function()
			require("config.trouble")
		end,
	},
	-- 通知を良い感じにする
	{
		"j-hui/fidget.nvim",
		event = "VimEnter",
		tag = "legacy",
		config = function()
			require("config.fidget")
		end,
	},
	{
		"myusuf3/numbers.vim",
		event = "VimEnter",
	},
	{
		"nvim-telescope/telescope.nvim",
		requires = { { "nvim-lua/plenary.nvim", opt = true }, { "nvim-lua/popup.nvim", opt = true } },
		event = "VimEnter",
		config = function()
			require("config.telescope")
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter",
		version = false, -- last release is way too old and doesn't work on Windows
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		-- run = function()
		-- 	require("nvim-treesitter.install").update({ with_sync = true })
		-- end,
		config = function()
			if vim.g.vscode then
				return nil
			else
				require("config/nvim-treesitter")
			end
		end,
		dependencies = {
			{
				"nvim-treesitter/nvim-treesitter-textobjects",
				init = function()
					require("lazy.core.loader").disable_rtp_plugin("nvim-treesitter-textobjects")
					-- load_textobjects = true
				end,
			},
		},
		cmd = { "TSUpdateSync" },
	},
	{ "JoosepAlviste/nvim-ts-context-commentstring" },
	-- { "nvim-treesitter/nvim-treesitter-refactor" },
	-- { "nvim-treesitter/nvim-tree-docs" },
	-- use({ "vigoux/architext.nvim",  })
	-- { "yioneko/nvim-yati" },
	--
	-- StatusLine
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		requires = { "kyazdani42/nvim-web-devicons", opt = true },
		config = function()
			require("config/lualine")
		end,
	},
	{
		"akinsho/bufferline.nvim",
		version = "*",
		event = "BufRead",
		requires = "nvim-tree/nvim-web-devicons",
		config = function()
			require("config.bufferline")
		end,
	},

	{
		"GustavoKatel/sidebar.nvim",
		-- cmd = { "SidebarNvimToggle" },
		event = "VimEnter",
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
		event = "VimEnter",
		config = function()
			require("config/null-ls")
		end,
	},

	{ "bfredl/nvim-luadev", ft = "lua" },
	{ "folke/lua-dev.nvim", ft = "lua" },
	{ "wadackel/nvim-syntax-info", cmd = { "SyntaxInfo" } },
	{
		"iamcco/markdown-preview.nvim",
		ft = { "markdown" },
		event = { "BufRead" },
		cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
		build = function()
			vim.fn["mkdp#util#install"]()
		end,
		-- build = "cd app && npm install",
	},
	{
		"lewis6991/gitsigns.nvim",
		event = "BufRead",
		config = function()
			require("config/gitsigns")
		end,
	},
	{
		"microsoft/python-type-stubs",
		cond = false,
	},
	{
		"akinsho/toggleterm.nvim",
		-- cmd = "ToggleTerm",
		event = "VimEnter",
		config = function()
			require("config/toggleterm")
		end,
	},
	{
		"github/copilot.vim",
		event = "InsertEnter",
		config = function()
			require("config/copilot")
		end,
	},
	{ "kevinhwang91/nvim-bqf", event = "VimEnter" },
	{ "lambdalisue/nerdfont.vim", event = "VimEnter" },
	{
		"rcarriga/nvim-notify",
		event = "VimEnter",
		config = function()
			vim.notify = require("notify")
			vim.notify("Config loaded", "info", { title = "Neovim" })
		end,
	},
	{
		"phaazon/hop.nvim",
		branch = "v2",
		event = "BufRead",
		config = function()
			-- require("config/hop")
			require("hop").setup({
				-- default key settings is for QWERTY
				keys = "etovxqpdygfblzhckisuran",
			})
			set_keymap("n", "<Leader>h", "<Cmd>:HopWord<CR>", { noremap = true, silent = true })
		end,
	},
}, lazy_opts)

-- }}}

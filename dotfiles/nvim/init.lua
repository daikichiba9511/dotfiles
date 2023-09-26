-- 設定ファイル
-- 基本的にこのファイルに必要なpluginの設定を書いてる
--- 各pluginのconfigはnvim/lua/configh配下に書いてる

local set_keymap = vim.api.nvim_set_keymap

vim.g.mapleader = " " -- <space> is leader key

--{{{
vim.opt.termguicolors = true
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.fileencodings = "ucs-boms,utf-8,euc-jp,cp932"
vim.opt.fileformats = "unix,dos,mac"
vim.opt.swapfile = false
vim.opt.relativenumber = true
vim.opt.showmatch = true
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.autoread = true
vim.opt.wildmenu = true
vim.opt.history = 5000

---@param ft string
local set_2spaces = function(ft)
  vim.cmd([[ autocmd FileType ]] .. ft .. [[ setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab]])
end

set_2spaces("yaml")
set_2spaces("lua")

-- if vim.fn.has("macos") == 1 then
-- 	opt.shell = "/bin/zsh"
-- else
-- 	opt.shell = "/usr/bin/zsh"
-- end
vim.opt.shell = "zsh"

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.opt.clipboard = "unnamedplus"
vim.opt.hidden = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wrapscan = true
--}}}

-- vscode neovimで動作を切り替えたい設定
if vim.g.vscode then
  vim.opt.cursorline = false
  vim.opt.hlsearch = false
else
  vim.opt.cursorline = true
  vim.opt.hlsearch = true
  vim.opt.incsearch = true
end

vim.opt.list = true -- show tabs
vim.opt.listchars = { tab = "-»", space = "·" }

-- buffer operations
set_keymap("i", "jj", "<ESC>", { silent = true })
set_keymap("n", "<C-j>", ":bprev<CR>", { noremap = true, silent = true })
set_keymap("n", "<C-k>", ":bnext<CR>", { noremap = true, silent = true })
set_keymap("n", "<C-k>", ":bnext<CR>", { noremap = true, silent = true })
set_keymap("n", "<C-x>", ":bd<CR>", { noremap = true, silent = true })

-- [lsp]
set_keymap("n", ";", "<Nop>", { noremap = true, silent = true })
set_keymap("n", "[lsp]", "<Nop>", { noremap = true, silent = true })
set_keymap("n", ";", "[lsp]", {})

-- [FuzzyFinder]
set_keymap("n", "z", "<Nop>", { noremap = true, silent = true })
set_keymap("n", "Z", "<Nop>", { noremap = true, silent = true })
set_keymap("n", "z", "[FuzzyFinder]", {})
set_keymap("v", "z", "[FuzzyFinder]", {})

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

-- local pystubpath = vim.fn.stdpath("data") .. "/lazy/python-type-stubs"
-- if not vim.loop.fs_stat(pystubpath) then
-- 	vim.fn.system({
-- 		"git",
-- 		"clone",
-- 		"--depth=1",
-- 		"https://github.com/microsoft/python-type-stubs.git",
-- 		pystubpath,
-- 	})
-- end

Colorscheme = "tokyonight"
-- Colorscheme = "nightowl"
-- Colorscheme = "catppuccin"
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
      if Colorscheme == "tokyonight" then
        require("config/tokyonight")
      end
    end,
  },
  {
    "oxfist/night-owl.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      if Colorscheme == "nightowl" then
        -- require("config/nightowl")
        vim.cmd.colorscheme("night-owl")
      end
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,
    config = function()
      if Colorscheme == "catppuccin" then
        require("config/catppuccin")
        vim.cmd.colorscheme("catppuccin")
      end
    end,
  },
  { "MunifTanjim/nui.nvim", event = "VimEnter" },
  { "nvim-lua/plenary.nvim", lazy = false }, -- do not lazy load
  { "folke/which-key.nvim", event = "VimEnter" },
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
  { "petertriho/cmp-git", error = "InsertEnter" },

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
  { "nvim-tree/nvim-web-devicons", event = "VimEnter" },
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
    config = function()
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
  -- {
  -- 	"microsoft/python-type-stubs",
  -- 	cond = false,
  -- },
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
      require("notify").setup({
        background_colour = "#1e222a",
      })
      vim.notify = require("notify")
      vim.notify("Config loaded", "info")
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
  {
    "RRethy/vim-illuminate",
    event = "BufRead",
  },
  { "norcalli/nvim-colorizer.lua", event = "BufRead" },
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    config = function()
      require("alpha").setup(require("alpha.themes.dashboard").config)
    end,
  },
  {
    "petertriho/nvim-scrollbar",
    event = {
      "BufWinEnter",
      "CmdwinLeave",
      "TabEnter",
      "TermEnter",
      "TextChanged",
      "VimResized",
      "WinEnter",
      "WinScrolled",
    },
    config = function()
      require("scrollbar").setup()
    end,
  },
  { "machakann/vim-sandwich", event = "VimEnter" },
  { "zsugabubus/crazy8.nvim", event = "VimEnter" },
  { "Decodetalkers/csv-tools.lua", ft = "csv" },
  { "dhruvasagar/vim-table-mode", ft = "markdown" },
  { "qnighy/satysfi.vim", ft = "satysfi" },
  -- { "simrat39/rust-tools.nvim" },
  { "m-demare/hlargs.nvim" },

  {
    "epwalsh/obsidian.nvim",
    lazy = true,
    event = {
      -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
      -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
      "BufReadPre "
        .. vim.fn.expand("~")
        .. "/Dropbox/MyValut/**.md",
      "BufNewFile " .. vim.fn.expand("~") .. "/Dropbox/MyValut/**.md",
    },
    dependencies = {
      -- Required.
      "nvim-lua/plenary.nvim",
      -- see below for full list of optional dependencies 👇
      "hrsh7th/nvim-cmp",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      dir = "~/Dropbox/MyValut", -- no need to call 'vim.fn.expand' here
    },
  },
  {
    "pwntester/octo.nvim",
    description = "Issue and PR management in Neovim using the GitHub GraphQL API",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    event = "VimEnter",
    config = function()
      require("config/octo")
    end,
  },
  {
    "mfussenegger/nvim-dap",
    config = function()
      require("config/nvim-dap")
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    config = function()
      require("config/nvim-dap-ui")
    end,
  },
}, lazy_opts)

-- My Image Preview Plugin
require("image_preview").setup()

-- My Converter Plugin
require("markdowntable2csv").setup()

-- Put Today Date to the current cursorline
function InsertCurrentToday()
  local current_date = os.date("%Y-%m-%d")
  vim.api.nvim_put({ current_date }, "c", true, true)
end

vim.api.nvim_set_keymap("n", "<leader>it", "<Cmd>lua InsertCurrentToday()<CR>", { noremap = true, silent = true })

-- }}}

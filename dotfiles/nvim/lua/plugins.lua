-- Reference:
-- [1] https://github.com/yutkat/dotfiles/blob/main/.config/nvim/lua/rc/pluginlist.lua
-- local install_path = vim.fn.stdpath("data") .. "/site/pack/jetpack/opt/vim-jetpack/plugin/jetpack.vim"
-- local package_manager_url = "https://raw.githubusercontent.com/tani/vim-jetpack/master/plugin/jetpack.vim"

local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
local package_manager_url = "https://github.com/wbthomason/packer.nvim"
if vim.fn.empty(vim.fn.glob(install_path)) == 1 then
    -- local cmd = 'curl -fsLo %s --create-dirs %s'
    -- os.execute(string.format(cmd, install_path, package_manger_url))
    local cmd = 'git clone --depth 1 %s %s'
    os.execute(string.format(cmd, package_manager_url, install_path))
end

-- vim.cmd([[packadd vim-jetpack]])
-- vim.g["jetpack#optimization"] = 2

package.path = package.path .. ";" .. vim.fn.stdpath("config") .. "/lua/?"

vim.opt.syntax = "enable"
vim.opt.termguicolors = true

vim.cmd([[packadd packer.nvim]])

require("packer-init")

-- パッケージ個別の設定は可読性のためにconfig directory配下に分ける
return require("packer").startup(
function(use)
    use({ "wbthomason/packer.nvim" })
    use({
        "machakann/vim-sandwich",
        event = "VimEnter",
        config = function()
            vim.cmd("source ~/.config/nvim/config/vim-sandwich.vim")
        end,
    })
    use({
        "folke/todo-comments.nvim",
        event = "VimEnter",
        config = function()
            require("config/todo-comments")
        end,
    })
    -- Comment out
    use({
        "numToStr/Comment.nvim",
        event = "VimEnter",
        config = function()
            require("config/Comment")
        end,
    })

    -- vscodeのときは早期リターンで以下のパッケージは読み込まない
    if vim.g.vscode then
        return
    end

    -- Lua Library
    use({ "nvim-lua/popup.nvim", module = "popup" })
    use({ "nvim-lua/plenary.nvim" }) -- do not lazy load
    use { "kkharji/sqlite.lua" }
    use({ "MunifTanjim/nui.nvim", module = "nui" })

    -- Notify
    use({ "rcarriga/nvim-notify", module = "notify" })

    -- ColorScheme
    -- local colorscheme = "iceberg.vim"
    local colorscheme = "nord.nvim"
    use({
        "cocopon/iceberg.vim",
        event = { "VimEnter", "ColorSchemePre" },
        -- config = function()
        -- require("config/iceberg")
        -- end,
    })
    use({
        'shaunsingh/nord.nvim',
        event = { "VimEnter", "ColorSchemePre" },
        config = function()
            vim.g.nord_contrast = true
            vim.g.nord_borders = false
            vim.g.nord_disable_background = false
            vim.g.nord_italic = false
            vim.cmd([[ colorscheme nord ]])
        end
    })
    use {
        'jinh0/eyeliner.nvim',
        config = function()
            require("config/eyeliner")
        end
    }

    use({
        'sunjon/stylish.nvim'
    })
    use({ "kyazdani42/nvim-web-devicons" })
    -- use({
    --    'goolord/alpha-nvim',
    --    requires = { 'kyazdani42/nvim-web-devicons' },
    --    config = function()
    --        require 'alpha'.setup(require 'alpha.themes.startify'.config)
    --    end })
    -- Fonts
    use({ "lambdalisue/nerdfont.vim" })

    -- term
    -- use({ "kassio/neoterm" })
    use({
        "akinsho/toggleterm.nvim",
        config = function()
            require("config/toggleterm")
        end
    })

    -- LSP
    use({
        "hrsh7th/nvim-cmp",
        requires = {
            { "L3MON4D3/LuaSnip", opt = true, event = "VimEnter" },
            { "windwp/nvim-autopairs", opt = true, event = "VimEnter" },
        },
        after = { "LuaSnip", "nvim-autopairs" },
        config = function()
            require("config/nvim-cmp")
        end,
    })
    use({
        "onsails/lspkind-nvim",
        module = "lspkind",
        config = function()
            require("config/lspkind-nvim")
        end,
    })
    use({ "hrsh7th/cmp-nvim-lsp", module = "cmp_nvim_lsp" })
    use({ "hrsh7th/cmp-nvim-lsp-signature-help", after = "nvim-cmp" })
    use({ "hrsh7th/cmp-nvim-lsp-document-symbol", after = "nvim-cmp" })
    use({ "hrsh7th/cmp-buffer", after = "nvim-cmp" })
    use({ "hrsh7th/cmp-path", after = "nvim-cmp" })
    use({ "hrsh7th/cmp-nvim-lua", after = "nvim-cmp" })
    use({ "hrsh7th/cmp-emoji", after = "nvim-cmp" })
    use({ "hrsh7th/cmp-calc", after = "nvim-cmp" })
    use({ "hrsh7th/cmp-cmdline", after = "nvim-cmp" })
    use({ "saadparwaiz1/cmp_luasnip", after = "nvim-cmp" })
    use({ "f3fora/cmp-spell", after = "nvim-cmp" })

    use({ "ray-x/cmp-treesitter", after = "nvim-cmp" })
    use({ "lukas-reineke/cmp-under-comparator", after = { "LuaSnip" } })
    use({ "hrsh7th/cmp-omni", after = "nvim-cmp" })

    use({
        "neovim/nvim-lspconfig",
        cofnig = function()
            require("config/nvim-lspconfig")
        end
    })

    -- Snippet
    use({
        "L3MON4D3/LuaSnip",
        -- event = "VimEnter",
        config = function()
            require("config/LuaSnip")
        end,
    })

    use({
        "kevinhwang91/nvim-hclipboard",
        after = { "LuaSnip" },
        config = function()
            require("hclipboard").start()
        end,
    })

    -- TODO: lsp系がバグってたらここみるといいかも
    use({
        "williamboman/nvim-lsp-installer",
        after = { "nvim-lspconfig", "cmp-nvim-lsp" },
        config = function()
            require("config/nvim-lsp-installer")
        end,
    })

    use({
        "tamago324/nlsp-settings.nvim",
        after = { "nvim-lspconfig" },
        config = function()
            require("config/nlsp-settings")
        end,
    })
    use({ "weilbith/nvim-lsp-smag", after = "nvim-lspconfig" })
    use({
        "kkharji/lspsaga.nvim",
        after = "nvim-lsp-installer",
        config = function()
            require("config/lspsaga")
        end,
    })
    use({
        "folke/lsp-colors.nvim",
        module = "lsp-colors",
    })

    use({
        "ray-x/lsp_signature.nvim",
        config = function()
            require("lsp_signature").setup({})
        end
    })

    use({
        "folke/trouble.nvim",
        after = { "nvim-lsp-installer" },
        config = function()
            require("config/trouble")
        end,
    })

    use({
        "j-hui/fidget.nvim",
        after = "nvim-lsp-installer",
        config = function()
            require("config/fidget")
        end
    })

    -- use({
    --    "tzachar/cmp-tabnine",
    --    run = "./install.sh",
    --    requires = "hrsh7th/nvim-cmp",
    --    after = "nvim-cmp",
    -- })

    use({
        "RRethy/vim-illuminate",
        config = function()
            require("config/vim-illuminate")
        end
    })
    use({
        "t9md/vim-quickhl",
    })

    use({
        "myusuf3/numbers.vim"
    })

    -- FuzzyFiner
    -- TODO: configを理解&整理する. 動作しそうかチェックする
    use({
        "nvim-telescope/telescope.nvim",
        -- requires = { { "nvim-lua/plenary.nvim", opt = true }, { "nvim-lua/popup.nvim", opt = true } },
        after = { colorscheme },
        -- event = "VimEnter",
        config = function()
            require("config/telescope")
        end,
    })
    use({
        "nvim-telescope/telescope-packer.nvim",
        config = function()
            require("config/telescope-packer")
        end
    })
    use({
        "nvim-telescope/telescope-frecency.nvim",
        after = { "telescope.nvim" },
        config = function()
            require("telescope").load_extension("frecency")
        end,
    })
    use({
        "nvim-telescope/telescope-github.nvim",
        after = { "telescope.nvim" },
        config = function()
            require("telescope").load_extension("gh")
        end,
    })
    use({
        "nvim-telescope/telescope-ui-select.nvim",
        after = { "telescope.nvim" },
        config = function()
            require("telescope").load_extension("ui-select")
        end,
    })
    use({ "nvim-telescope/telescope-symbols.nvim", after = { "telescope.nvim" } })

    if vim.fn.executable("ueberzug") == 1 then
        use({
            "nvim-telescope/telescope-media-files.nvim",
            after = { "telescope.nvim" },
            config = function()
                require("telescope").load_extension("media_files")
            end,
        })
    end

    -- Treesitter
    use({
        "nvim-treesitter/nvim-treesitter",
        after = { colorscheme },
        -- event = "VimEnter",
        run = function()
            require("nvim-treesitter.install").update({ with_sync = true })
        end,
        config = function()
            require("config/nvim-treesitter")
        end,
    })
    use({ "JoosepAlviste/nvim-ts-context-commentstring", after = { "nvim-treesitter" } })
    use({ "nvim-treesitter/nvim-treesitter-refactor", after = { "nvim-treesitter" } })
    use({ "nvim-treesitter/nvim-tree-docs", after = { "nvim-treesitter" } })
    use({ "vigoux/architext.nvim", after = { "nvim-treesitter" } })
    use({ "yioneko/nvim-yati", after = "nvim-treesitter" })

    use({
        "SmiteshP/nvim-navic",
        module = "nvim-navic",
    })

    -- StatusLine
    -- use({
    --     "feline-nvim/feline.nvim",
    --     config = function()
    --         require("config/feline")
    --     end
    -- })

    use {
        "nvim-lualine/lualine.nvim",
        after = colorscheme,
        requires = { "kyazdani42/nvim-web-devicons", opt = true },
        config = function()
            require("config/lualine")
        end
    }

    -- Bufferline
    if not vim.g.vscode then
        use({
            "akinsho/bufferline.nvim",
            after = colorscheme,
            config = function()
                require("config/bufferline")
            end,
        })
    end



    -- Sidebar
    -- conflict with clever-f (augroup sidebar_nvim_prevent_buffer_override)
    use({
        "GustavoKatel/sidebar.nvim",
        -- cmd = { "SidebarNvimToggle" },
        config = function()
            require("config/sidebar")
        end,
    })
    -- Scrollbar
    use({
        "petertriho/nvim-scrollbar",
        requires = { { "kevinhwang91/nvim-hlslens", opt = true } },
        after = { colorscheme, "nvim-hlslens" },
        config = function()
            require("config/nvim-scrollbar")
        end,
    })



    use({
        "famiu/bufdelete.nvim",
        event = "VimEnter",
        config = function()
            require("config/bufdelete")
        end,
    })
    -- Popup Info
    use({
        "lewis6991/hover.nvim",
        event = "VimEnter",
        config = function()
            require("config/hover")
        end,
    })
    -- Reading assistant
    if not vim.g.vscode then
        use({
            "lukas-reineke/indent-blankline.nvim",
            after = { colorscheme },
            event = "VimEnter",
            config = function()
                if not vim.g.vscode then
                    require("config/indent-blankline")
                else
                    return
                end
            end,
        })
    end

    use({
        "windwp/nvim-autopairs",
        event = "VimEnter",
        config = function()
            require("config/nvim-autopairs")
        end,
    })
    -- Lint
    use({
        "jose-elias-alvarez/null-ls.nvim",
        after = "nvim-lsp-installer",
        config = function()
            require("config/null-ls")
        end,
    })
    use({
        "chen244/csv-tools.lua",
        ft = { "csv" },
        config = function()
            require("config/csv-tools")
        end,
    })
    use({
        "dhruvasagar/vim-table-mode",
        -- event = "VimEnter",
        cmd = { "TableModeEnable" },
        config = function()
            vim.cmd("source ~/.config/nvim/config/vim-table-mode.vim")
        end,
    })
    -- Markdown
    use({ "iamcco/markdown-preview.nvim", ft = { "markdown" }, run = ":call mkdp#util#install()" })
    -- Rust
    use({
        "simrat39/rust-tools.nvim",
        module = "rust-tools",
        -- after = { "nvim-lspconfig" },
        -- ft = { "rust" },
        -- config = function()
        -- 	require("rc/pluginconfig/rust-tools")
        -- end,
    })
    -- Terraform
    use({ "hashivim/vim-terraform" })
    -- SATySFi
    -- use({ "qnighy/satysfi.vim" })
    -- Julia
    -- use({ "JuliaLang/julia-vim" })


    -- Debugger
    use({
        "mfussenegger/nvim-dap",
        event = "VimEnter",
        config = function()
            require("config/nvim-dap")
        end,
    })
    use({
        "rcarriga/nvim-dap-ui",
        after = { "nvim-dap" },
        config = function()
            require("config/nvim-dap-ui")
        end,
    })
    use({ "theHamsta/nvim-dap-virtual-text", after = { "nvim-dap" } })
    use({
        "nvim-telescope/telescope-dap.nvim",
        requires = {
            { "mfussenegger/nvim-dap", opt = true },
            { "nvim-telescope/telescope.nvim", opt = true },
        },
        after = { "nvim-dap", "telescope.nvim" },
    })
    -- TODO: configを理解&整理する. 動作しそうかチェックする
    use({
        "stevearc/aerial.nvim",
        event = "VimEnter",
        config = function()
            require("config/aerial")
        end,
    })

    use({ "bfredl/nvim-luadev", event = "VimEnter" })
    use({ "folke/lua-dev.nvim", module = "lua-dev" })
    use({ "wadackel/nvim-syntax-info", cmd = { "SyntaxInfo" } })

    -- 自前でinit.luaに設定することにした
    -- use({ "zsugabubus/crazy8.nvim" })

    use({
        "danymat/neogen",
        config = function()
            require('config/neogen')
        end,
        require = "nvim-treesitter/nvim-treesitter",
    })

    -- Git
    use({
        'akinsho/git-conflict.nvim',
        tag = "*",
        config = function()
            require('config/git-conflict')
        end
    })
    use({
        'lewis6991/gitsigns.nvim',
        -- tag = 'release' -- To use the latest release
        config = function()
            require('gitsigns').setup()
        end
    })

    -- Jupyter
    -- use({
    --    'dccsillag/magma-nvim',
    --    run = ':UpdateRemotePlugins',
    --    config = function()
    --        require("config/magma-nvim")
    --    end
    -- })
end
)

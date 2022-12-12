-- Reference:
-- [1] https://github.com/yutkat/dotfiles/blob/main/.config/nvim/lua/rc/pluginlist.lua
-- local install_path = vim.fn.stdpath("data") .. "/site/pack/jetpack/opt/vim-jetpack/plugin/jetpack.vim"
-- local package_manager_url = "https://raw.githubusercontent.com/tani/vim-jetpack/master/plugin/jetpack.vim"

local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
local package_manager_url = "https://github.com/wbthomason/packer.nvim"
if vim.fn.empty(vim.fn.glob(install_path)) == 1 then
    -- local cmd = 'curl -fsLo %s --create-dirs %s'
    -- os.execute(string.format(cmd, install_path, package_manger_url))
    local cmd = "git clone --depth 1 %s %s"
    os.execute(string.format(cmd, package_manager_url, install_path))
end

package.path = package.path .. ";" .. vim.fn.stdpath("config") .. "/lua/?"

vim.opt.termguicolors = true

if vim.g.vscode then
    vim.fn.setenv("MACOSX_DEPLOYMENT_TARGET", "10.15")
    -- vim.cmd([[hi clear]])
    vim.opt.syntax = "off"
else
    vim.opt.syntax = "enable"
    vim.fn.setenv("MACOSX_DEPLOYMENT_TARGET", "10.15")
    -- vim.cmd([[packadd packer.nvim]])
end

require("packer-init")

-- パッケージ個別の設定は可読性のためにconfig directory配下に分ける
return require("packer").startup({
    function(use)
        if vim.g.vscode then
            -- Notify
            use({ "rcarriga/nvim-notify", module = "notify" })
            use({
                "cocopon/iceberg.vim",
                event = { "VimEnter", "ColorSchemePre" },
                config = function()
                    require("config/iceberg")
                end,
            })
            return nil
        else
            -- ###### Not for vscode neovim ######
            use({ "wbthomason/packer.nvim" })
            use({
                "machakann/vim-sandwich",
                event = "VimEnter",
                config = function()
                    if not vim.g.vscode then
                        vim.cmd([[source ~/.config/nvim/config/vim-sandwich.vim]])
                    end
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

            --         -- Notify
            --         use({ "rcarriga/nvim-notify", module = "notify" })
            --
            -- Lua Library
            use({ "nvim-lua/popup.nvim", module = "popup" })
            use({ "nvim-lua/plenary.nvim" }) -- do not lazy load
            use({ "kkharji/sqlite.lua" })
            use({ "MunifTanjim/nui.nvim", module = "nui" })

            -- ColorScheme
            -- local colorscheme = "iceberg.vim"
            -- local colorscheme = "nightfox.nvim"
            local colorscheme = "tokyonight.nvim"
            --         -- use({
            --         --     "shaunsingh/nord.nvim",
            --         --     event = { "VimEnter", "ColorSchemePre" },
            --         --     config = function()
            --         --         vim.g.nord_contrast = true
            --         --         vim.g.nord_borders = false
            --         --         vim.g.nord_disable_background = false
            --         --         vim.g.nord_italic = false
            --         --         --    vim.cmd([[ colorscheme nord ]])
            --         --     end,
            --         -- })
            --         use({
            --             "EdenEast/nightfox.nvim",
            --             config = function()
            --                 if colorscheme == "nightfox.nvim" then
            --                     require("config/nightfox")
            --                 end
            --             end,
            --         })
            use({
                "folke/tokyonight.nvim",
                config = function()
                    require("config/tokyonight")
                end,
            })
            --
            --         use({
            --             "jinh0/eyeliner.nvim",
            --             config = function()
            --                 require("config/eyeliner")
            --             end,
            --         })
            use({ "kyazdani42/nvim-web-devicons" })
            --
            --         -- かっこいいUIパーツが入ってる
            --         use({
            --             "sunjon/stylish.nvim",
            --         })
            --         -- use({
            --         --    'goolord/alpha-nvim',
            --         --    requires = { 'kyazdani42/nvim-web-devicons' },
            --         --    config = function()
            --         --        require 'alpha'.setup(require 'alpha.themes.startify'.config)
            --         --    end })

            -- Fonts
            use({ "lambdalisue/nerdfont.vim" })
            -- Terminal
            ---- Ctrl+Tで下1/4くらいにターミナルのバッファを出す
            use({
                "akinsho/toggleterm.nvim",
                config = function()
                    require("config/toggleterm")
                end,
            })
            -- LSP
            ------ 自動補完系
            use({
                "hrsh7th/nvim-cmp",
                requires = {
                    { "L3MON4D3/LuaSnip", opt = true, event = "VimEnter" },
                    { "windwp/nvim-autopairs", opt = true, event = "VimEnter" },
                },
                after = { "LuaSnip", "nvim-autopairs" },
                -- after = { "nvim-autopairs" },
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
            ------ 自動補完用リソース
            use({ "hrsh7th/cmp-nvim-lsp", module = "cmp_nvim_lsp", after = "nvim-cmp" })
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

            -- Snippet
            use({
                "L3MON4D3/LuaSnip",
                event = "VimEnter",
                config = function()
                    require("config/LuaSnip")
                end,
            })
            --
            --         use({
            --             "kevinhwang91/nvim-hclipboard",
            --             after = { "LuaSnip" },
            --             config = function()
            --                 require("hclipboard").start()
            --             end,
            --         })
            -- Language Server管理系
            ---- Language Server & Linter & Formatter etc.のインストールをTUIでできるようにする
            use({
                "williamboman/mason.nvim",
                event = "VimEnter",
                config = function()
                    require("config/mason")
                end,
            })
            ---- Masonでインストールしたツールのセットアップをする
            use({
                "williamboman/mason-lspconfig.nvim",
                after = { "mason.nvim", "nvim-lspconfig", "cmp-nvim-lsp", "nlsp-settings.nvim" },
                config = function()
                    require("config/mason-lspconfig")
                end,
            })
            use({
                "tamago324/nlsp-settings.nvim",
                after = { "nvim-lspconfig" },
                config = function()
                    require("config/nlsp-settings")
                end,
            })
            -- LSPの機能強化系
            use({
                "neovim/nvim-lspconfig",
                cofnig = function()
                    require("config/nvim-lspconfig")
                end,
            })
            ------ status lineにコンテキストを出すのに使う
            use({
                "SmiteshP/nvim-navic",
                module = "nvim-navic",
            })

            --         use({
            --             "weilbith/nvim-lsp-smag",
            --             after = "nvim-lspconfig",
            --         })
            ------ LSPの情報使ってUIをかっこよくする
            use({
                "kkharji/lspsaga.nvim",
                config = function()
                    require("config/lspsaga")
                end,
            })
            --         use({
            --             "folke/lsp-colors.nvim",
            --             module = "lsp-colors",
            --         })
            --
            ------ 関数の引数とかdocstringとかをpopupに出す
            use({
                "ray-x/lsp_signature.nvim",
                after = { "mason.nvim", "nvim-lspconfig", "cmp-nvim-lsp", "nlsp-settings.nvim" },
                config = function()
                    require("lsp_signature").setup({})
                end,
            })
            --         -- use({
            --         --     "lvimuser/lsp-inlayhints.nvim",
            --         --     config = function()
            --         --         require("config/lsp-inlayhints")
            --         --     end,
            --         -- })
            --
            --         -- Diagnostic list
            --         use({
            --             "folke/trouble.nvim",
            --             config = function()
            --                 require("config/trouble")
            --             end,
            --         })
            --
            --         use({
            --             "j-hui/fidget.nvim",
            --             config = function()
            --                 require("config/fidget")
            --             end,
            --         })
            --
            --         use({
            --             "RRethy/vim-illuminate",
            --             config = function()
            --                 require("config/vim-illuminate")
            --             end,
            --         })
            --         -- if not vim.g.vscode then
            --         --     use({
            --         --         "t9md/vim-quickhl",
            --         --     })
            --         -- end
            --
            -- 行数の表示を相対的番号と絶対的番号にする
            use({
                "myusuf3/numbers.vim",
            })
            --
            -- FuzzyFiner
            ------ Telescope系
            ---------- Telescope本体
            use({
                "nvim-telescope/telescope.nvim",
                requires = { { "nvim-lua/plenary.nvim", opt = true }, { "nvim-lua/popup.nvim", opt = true } },
                after = { colorscheme },
                event = "VimEnter",
                config = function()
                    require("config/telescope")
                end,
            })
            ---------- TelescopeのExtension
            use({
                "nvim-telescope/telescope-packer.nvim",
                config = function()
                    require("config/telescope-packer")
                end,
            })
            use({ "nvim-telescope/telescope-file-browser.nvim" })
            --         -- use({
            --         --     "nvim-telescope/telescope-frecency.nvim",
            --         --     after = { "telescope.nvim" },
            --         --     config = function()
            --         --         require("telescope").load_extension("frecency")
            --         --     end,
            --         -- })
            --         -- use({
            --         --     "nvim-telescope/telescope-github.nvim",
            --         --     after = { "telescope.nvim" },
            --         --     config = function()
            --         --         require("telescope").load_extension("gh")
            --         --     end,
            --         -- })
            --         use({
            --             "nvim-telescope/telescope-ui-select.nvim",
            --             after = { "telescope.nvim" },
            --             config = function()
            --                 require("telescope").load_extension("ui-select")
            --             end,
            --         })
            --
            -- Treesitter
            use({
                "nvim-treesitter/nvim-treesitter",
                after = { colorscheme },
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
            })
            use({ "JoosepAlviste/nvim-ts-context-commentstring", after = { "nvim-treesitter" } })
            use({ "nvim-treesitter/nvim-treesitter-refactor", after = { "nvim-treesitter" } })
            use({ "nvim-treesitter/nvim-tree-docs", after = { "nvim-treesitter" } })
            -- use({ "vigoux/architext.nvim", after = { "nvim-treesitter" } })
            use({ "yioneko/nvim-yati", after = "nvim-treesitter" })

            --
            -- StatusLine
            use({
                "nvim-lualine/lualine.nvim",
                after = colorscheme,
                requires = { "kyazdani42/nvim-web-devicons", opt = true },
                config = function()
                    require("config/lualine")
                end,
            })
            use({
                "akinsho/bufferline.nvim",
                tag = "v3.*",
                requires = "nvim-tree/nvim-web-devicons",
                config = function()
                    require("config.bufferline")
                end,
            })
            -- buffer系
            ---- Ctrl+Xでcurrent bufferのみを閉じる
            use({
                "famiu/bufdelete.nvim",
                event = "VimEnter",
                config = function()
                    require("config.bufdelete")
                end,
            })
            -- Sidebar
            ---- サイドバーにファイラーとtodo-commentsみたいなの出す
            ------ conflict with clever-f (augroup sidebar_nvim_prevent_buffer_override)
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

            --         use({
            --             "famiu/bufdelete.nvim",
            --             event = "VimEnter",
            --             config = function()
            --                 require("config/bufdelete")
            --             end,
            --         })
            -- Popup Info
            use({
                "lewis6991/hover.nvim",
                event = "VimEnter",
                config = function()
                    require("config/hover")
                end,
            })
            -- Reading             assistant
            ---- 選択してる行がどのインデント内にいるかわかりやすくする
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
            -- Lint & Formatter
            use({
                "jose-elias-alvarez/null-ls.nvim",
                config = function()
                    require("config/null-ls")
                end,
            })
            --         use({
            --             "chen244/csv-tools.lua",
            --             ft = { "csv" },
            --             config = function()
            --                 require("config/csv-tools")
            --             end,
            --         })
            --         use({
            --             "dhruvasagar/vim-table-mode",
            --             -- event = "VimEnter",
            --             cmd = { "TableModeEnable" },
            --             config = function()
            --                 vim.cmd("source ~/.config/nvim/config/vim-table-mode.vim")
            --             end,
            --         })
            --         -- REPLを使えるようにする
            --         use({
            --             "hkupty/iron.nvim",
            --             config = function()
            --                 require("config/iron")
            --             end,
            --         })
            --
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

            -- Deno
            use({
                "sigmasd/deno-nvim",
                config = function()
                    require("config/deno-nvim")
                end,
            })
            --
            --         -- Terraform
            --         use({ "hashivim/vim-terraform" })
            --         -- SATySFi
            --         -- use({ "qnighy/satysfi.vim" })
            --         -- Julia
            --         -- use({ "JuliaLang/julia-vim" })
            --
            --         -- Debugger
            --         -- use({
            --         --     "mfussenegger/nvim-dap",
            --         --     event = "VimEnter",
            --         --     config = function()
            --         --         require("config/nvim-dap")
            --         --     end,
            --         -- })
            --         -- use({
            --         --     "rcarriga/nvim-dap-ui",
            --         --     after = { "nvim-dap" },
            --         --     config = function()
            --         --         require("config/nvim-dap-ui")
            --         --     end,
            --         -- })
            --         -- use({ "theHamsta/nvim-dap-virtual-text", after = { "nvim-dap" } })
            --         -- use({
            --         --     "nvim-telescope/telescope-dap.nvim",
            --         --     requires = {
            --         --         { "mfussenegger/nvim-dap", opt = true },
            --         --         { "nvim-telescope/telescope.nvim", opt = true },
            --         --     },
            --         --     after = { "nvim-dap", "telescope.nvim" },
            --         -- })
            --         -- コードのoutlineを表示するツール
            --         use({
            --             "stevearc/aerial.nvim",
            --             event = "VimEnter",
            --             config = function()
            --                 require("config/aerial")
            --             end,
            --         })
            --
            use({ "bfredl/nvim-luadev", event = "VimEnter" })
            use({ "folke/lua-dev.nvim", module = "lua-dev" })
            use({ "wadackel/nvim-syntax-info", cmd = { "SyntaxInfo" } })
            --
            --         -- 自前でinit.luaに設定することにした
            --         -- use({ "zsugabubus/crazy8.nvim" })
            --
            --         -- use({
            --         --     "danymat/neogen",
            --         --     config = function()
            --         --         require("config/neogen")
            --         --     end,
            --         --     require = "nvim-treesitter/nvim-treesitter",
            --         -- })
            --
            --         -- Git
            --         use({
            --             "akinsho/git-conflict.nvim",
            --             tag = "*",
            --             config = function()
            --                 require("config/git-conflict")
            --             end,
            --         })
            ------ 前コミットから変更があった行に色を付ける
            use({
                "lewis6991/gitsigns.nvim",
                -- tag = 'release' -- To use the latest release
                config = function()
                    require("gitsigns").setup()
                end,
            })
            --
            --         -- Jupyter
            --         -- use({
            --         --    'dccsillag/magma-nvim',
            --         --    run = ':UpdateRemotePlugins',
            --         --    config = function()
            --         --        require("config/magma-nvim")
            --         --    end
            --         -- })
        end
    end,
    config = {
        max_jobs = 10,
    },
})

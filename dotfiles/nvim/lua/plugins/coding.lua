--- ログを出力する関数
---
---@param msg string messages to log
---@param level string logging level
---@param notice boolean | nil default false
local function log(msg, level, notice)
  if notice == nil then
    notice = false
  end

  local date = os.date("%Y-%m-%d %H:%M:%S")
  local _msg = string.format("[%s] : [%s] : %s", level, date, msg)
  if notice then
    vim.notify(_msg)
  else
    print(_msg)
  end
end

--- OSのタイプを判定する関数、macosならmacos, linuxならLinuxを、それ以外はunknownを返す
---
---@return string
local function get_os_type()
  local handle = io.popen("uname")
  if handle == nil then
    return "unknown"
  end
  local result = handle:read("*a")
  handle:close()

  -- log(string.format("DETECTED: OS Type %s", result), "INFO", true)
  if result:match("Darwin") then
    return "macos"
  elseif result:match("Linux") then
    return "Linux"
  else
    return "unknown"
  end
end

---OSごとにVaultディレクトリのパスが違うので、対応してセットするための関数
---
---@return string | nil
local function set_vault_path()
  local os_type = get_os_type()
  local exists_myvault = (vim.fn.isdirectory("~/Dropbox/MyVault") == 1 or vim.fn.isdirectory("~/MyVault") == 1)
  if os_type == "Linux" then
    return exists_myvault and "~/Dropbox/MyVault" or nil
  elseif os_type == "macos" then
    return exists_myvault and "~/MyVault" or nil
  else
    log("DETECTED: Unknown OS Type when settting your vault path", "WARNING", true)
    return ""
  end
end

local function set_workspace()
  local path = set_vault_path()
  if path ~= nil then
    return { workspace = {
      name = "MyVault",
      path = path,
    } }
  else
    return {}
  end
end

---現在のノードの絶対パスを取得する関数
---@param state any
---@return unknown
local function get_abs_path(state)
  local abs_path = state.tree:get_node().path
  return abs_path
end

---現在のノードの相対パスを取得する関数
---@param state any
---@return unknown
local function get_relative_path(state)
  local abs_path = state.tree:get_node().path
  local rel_path = vim.fn.fnamemodify(abs_path, ":.:")
  return rel_path
end

---クリップボードに値をセットする関数
---@param value string
---@return nil
local function set_to_clipboard(value)
  vim.notify("set to clipboard: " .. value)
  vim.fn.setreg("+", value)
end

---クリップボードに値をセットする関数で、osc52を使うことでリモートでも使えるよう
---@return nil
local function set_to_clipboard_from_remote(value)
  require("osc52").copy(value)
end

---相対パスをクリップボードにセットする関数
---@param state any
---@return nil
local function set_relative_path_to_clipboard(state)
  local rel_path = get_relative_path(state)
  set_to_clipboard(rel_path)
end

---絶対パスをクリップボードにセットする関数
---@param state any
---@return nil
local function set_absolute_path_to_clipboard(state)
  local abs_path = get_abs_path(state)
  set_to_clipboard(abs_path)
end

---相対パスをリモートからクリップボードにセットする関数
---@param state any
---@return nil
local function set_relative_path_to_clipboard_from_remote(state)
  local rel_path = get_relative_path(state)
  set_to_clipboard_from_remote(rel_path)
end

---絶対パスをリモートからクリップボードにセットする関数
---@param state any
---@return nil
local function set_absolute_path_to_clipboard_from_remote(state)
  local abs_path = get_abs_path(state)
  set_to_clipboard_from_remote(abs_path)
end

vim.api.nvim_create_user_command("InitLua", function()
  vim.cmd.edit(vim.fn.stdpath("config") .. "/init.lua")
end, { desc = "Open init.lua" })

vim.api.nvim_create_user_command("CopyLastCmd", function()
  vim.fn.setreg("*", vim.fn.getreg(":"))
  -- unless vim.opt.clipboard has unnamed
  -- vim.fn.setreg('', vim.fn.getreg(':'))
end, { desc = "Copy last used command" })

return {
  -- treesiter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "tsx",
        "typescript",
        "vim",
        "yaml",
        "rust",
      },
    },
  },
  -- mason
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- lua
        "stylua",
        -- shell
        "shellcheck",
        "shfmt",
        -- python
        "ruff",
        "ruff-lsp",
        -- rust
        "rust-analyzer",
      },
    },
  },

  -- {
  --   "nvim-lualine/lualine.nvim",
  --   optional = true,
  --   event = "VeryLazy",
  --   opts = function(_, opts)
  --     local colors = {
  --       [""] = LazyVim.ui.fg("Special"),
  --       ["Normal"] = LazyVim.ui.fg("Special"),
  --       ["Warning"] = LazyVim.ui.fg("DiagnosticError"),
  --       ["InProgress"] = LazyVim.ui.fg("DiagnosticWarn"),
  --     }
  --     table.insert(opts.sections.lualine_x, 2, {
  --       function()
  --         local icon = LazyVim.config.icons.kinds.Copilot
  --         local status = require("copilot.api").status.data
  --         return icon .. (status.message or "")
  --       end,
  --       cond = function()
  --         if not package.loaded["copilot"] then
  --           return
  --         end
  --         local ok, clients = pcall(LazyVim.lsp.get_clients, { name = "copilot", bufnr = 0 })
  --         if not ok then
  --           return false
  --         end
  --         return ok and #clients > 0
  --       end,
  --       color = function()
  --         if not package.loaded["copilot"] then
  --           return
  --         end
  --         local status = require("copilot.api").status.data
  --         return colors[status.status] or colors[""]
  --       end,
  --     })
  --   end,
  -- },

  -- copilot
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    opts = {
      suggestion = { enabled = true },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        gitcommit = true,
        help = true,
      },
    },
  },
  -- {
  --   "zbirenbaum/copilot-cmp",
  --   config = function()
  --     require("copilot_cmp").setup()
  --   end,
  -- },

  -- {
  --   "github/copilot.vim",
  -- },
  -- copilot cmp source
  -- {
  --   "nvim-cmp",
  --   dependencies = {
  --     {
  --       "zbirenbaum/copilot-cmp",
  --       dependencies = "copilot.lua",
  --       opts = {},
  --       config = function(_, opts)
  --         local copilot_cmp = require("copilot_cmp")
  --         copilot_cmp.setup(opts)
  --         -- attach cmp source whenever copilot attaches
  --         -- fixes lazy-loading issues with the copilot cmp source
  --         LazyVim.lsp.on_attach(function(client)
  --           vim.notify("attach copilot.lua")
  --           copilot_cmp._on_insert_enter({})
  --         end, "copilot")
  --       end,
  --     },
  --   },
  --   ---@param opts cmp.ConfigSchema
  --   opts = function(_, opts)
  --     table.insert(opts.sources, 1, {
  --       name = "copilot",
  --       group_index = 1,
  --       priority = 100,
  --     })
  --   end,
  -- },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    -- branch = "canary",
    event = "VeryLazy",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      -- { "github/copilot.vim" },
      { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
    },
    opts = {
      debug = true, -- Enable debugging
      chat_autocomplete = true,
      model = "claude-3.7-sonnet",
      -- See Configuration section for rest
    },
    -- See Commands section for default commands if you want to lazy load on them
  },

  -- Bufdelete
  {
    "famiu/bufdelete.nvim",
  },
  -- Quarto
  {
    "quarto-dev/quarto-nvim",
  },
  {
    "jmbuhr/otter.nvim",
  },
  -- Obsidian
  {
    "epwalsh/obsidian.nvim",
    lazy = true,
    version = "*",
    opts = {
      set_workspace(),
    },
  },
  -- symbolのレンダリングの位置が日本語だと微妙なので。。
  {
    "MeanderingProgrammer/markdown.nvim",
    name = "render-markdown", -- Only needed if you have another plugin named markdown.nvim
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("render-markdown").setup({
        file_types = { "markdown", "norg", "rmd", "org" },
        code = {
          sign = false,
          width = "block",
          right_pad = 1,
        },
        heading = {
          sign = false,
          icons = {},
        },
        bullet = {
          enabled = true,
          icons = { "●", "○", "◆", "◇" },
          right_pad = 1,
        },
      })
    end,
  },
  -- {
  --   "lukas-reineke/headlines.nvim",
  --   dependencies = "nvim-treesitter/nvim-treesitter",
  --   opts = {
  --     markdown = { bullets = { "● ", "○ ", "◆ ", "◇ " } },
  --   },
  -- },
  -- {
  --   "MeanderingProgrammer/render-markdown.nvim",
  --   opts = {
  --     file_types = { "markdown", "norg", "rmd", "org" },
  --     code = {
  --       sign = false,
  --       width = "block",
  --       right_pad = 1,
  --     },
  --     heading = {
  --       sign = false,
  --       icons = {},
  --     },
  --     bullet = {
  --       enabled = true,
  --       icons = { "●", "○", "◆", "◇" },
  --       right_pad = 2,
  --     },
  --   },
  -- dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
  -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
  --   dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
  -- },
  -- ToggleTerm
  {
    "akinsho/toggleterm.nvim",
    opts = {
      size = 40,
      -- open_mapping = "<leader>tt",
      hide_numbers = true,
    },
  },
  -- {
  --   "3rd/image.nvim",
  --   -- Disable on Windows system
  --   cond = function()
  --     return vim.fn.has("win32") ~= 1
  --   end,
  --   dependencies = {
  --     "leafo/magick",
  --   },
  --   opts = {
  --     -- image.nvim config
  --   },
  -- },
  -- {
  --   "3rd/diagram.nvim",
  --   dependencies = {
  --     "3rd/image.nvim",
  --   },
  --   opts = { -- you can just pass {}, defaults below
  --     renderer_options = {
  --       mermaid = {
  --         background = nil, -- nil | "transparent" | "white" | "#hex"
  --         theme = nil, -- nil | "default" | "dark" | "forest" | "neutral"
  --       },
  --     },
  --     integrations = {
  --       require("diagram.integrations.markdown"),
  --     },
  --   },
  -- },
  {
    "ojroques/nvim-osc52",
    config = function()
      vim.keymap.set("n", "<leader>ctl", require("osc52").copy_operator, { expr = true, desc = "Copy text object" })
      vim.keymap.set("n", "<leader>cc", "<leader>c_", { remap = true })
      vim.keymap.set("v", "<leader>ctl", require("osc52").copy_visual, { desc = "Copy visual selection" })
    end,
  },
  {
    "adelarsq/image_preview.nvim",
    event = "VeryLazy",
    config = function()
      require("image_preview").setup()
    end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    config = function()
      require("neo-tree").setup({
        filesystem = {
          window = {
            mappings = {
              ["<leader>p"] = "image_wezterm", -- " or another map
              ["<leader>yr"] = {
                set_relative_path_to_clipboard,
                desc = "Copy relative path to clipboard",
              },
              ["<leader>ya"] = {
                set_absolute_path_to_clipboard,
                desc = "Copy absolute path to clipboard",
              },
              ["<leader>ylr"] = {
                set_relative_path_to_clipboard_from_remote,
                desc = "Copy relative path to local clipboard from remote",
              },
              ["<leader>yla"] = {
                set_absolute_path_to_clipboard_from_remote,
                desc = "Copy absolute path to local clipboard from remote",
              },
            },
          },
          commands = {
            image_wezterm = function(state)
              local node = state.tree:get_node()
              if node.type == "file" then
                require("image_preview").PreviewImage(node.path)
              end
            end,
          },
        },
      })
    end,
  },
  -- {
  --   "stevearc/conform.nvim",
  --   opts = {
  --     formatters_by_ft = {
  --       sql = { "sql_formatter" },
  --     },
  --   },
  -- },
  -- Typst
  {
    "chomosuke/typst-preview.nvim",
    lazy = false, -- or ft = 'typst'
    version = "1.*",
    opts = {}, -- lazy.nvim will implicitly calls `setup {}`
  },
  -- lazy.nvim
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      image = {
        -- your image configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
        enable = true,
      },
    },
  },
}

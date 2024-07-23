--- ログを出力する関数
---
---@param msg string
---@param level string
---@param notice boolean | nil default false
local function log(msg, level, notice)
  if notice == nil then
    notice = false
  end

  local date = os.date("%Y-%m-%d %H:%M:%S")
  local _msg = string.format("[lazyvim] : [%s] : [%s] : %s", level, date, msg)
  if notice then
    vim.notify(_msg)
  else
    print(_msg)
  end
end

---OSのタイプを判定する関数、macosならmacos, linuxならLinuxを、それ以外はunknownを返す
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
  if os_type == "Linux" then
    return "~/Dropbox/MyVault"
  elseif os_type == "macos" then
    return "~/MyVault"
  else
    log("DETECTED: Unknown OS Type when settting your vault path", "WARNING", true)
    return
  end
end

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
  -- {
  --   "zbirenbaum/copilot.lua",
  --   cmd = "Copilot",
  --   build = ":Copilot auth",
  --   opts = {
  --     suggestion = { enabled = true },
  --     panel = { enabled = false },
  --     filetypes = {
  --       markdown = true,
  --       help = true,
  --     },
  --   },
  -- },
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
  -- {
  --   "CopilotC-Nvim/CopilotChat.nvim",
  --   branch = "canary",
  --   dependencies = {
  --     { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
  --     -- { "github/copilot.vim" },
  --     { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
  --   },
  --   opts = {
  --     debug = true, -- Enable debugging
  --     -- See Configuration section for rest
  --   },
  --   -- See Commands section for default commands if you want to lazy load on them
  -- },
  { import = "lazyvim.plugins.extras.coding.copilot" },
  { import = "lazyvim.plugins.extras.coding.copilot-chat" },
  { import = "lazyvim.plugins.extras.editor.telescope" },
  -- 言語ごとの設定
  { import = "lazyvim.plugins.extras.lang.clangd" },
  { import = "lazyvim.plugins.extras.lang.python" },
  { import = "lazyvim.plugins.extras.lang.rust" },
  { import = "lazyvim.plugins.extras.lang.sql" },
  { import = "lazyvim.plugins.extras.lang.terraform" },
  { import = "lazyvim.plugins.extras.lang.toml" },
  { import = "lazyvim.plugins.extras.lang.typescript" },
  { import = "lazyvim.plugins.extras.lang.yaml" },

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
    opts = {
      workspaces = {
        {
          name = "MyVault",
          path = set_vault_path(),
        },
      },
    },
  },
  {
    "MeanderingProgrammer/markdown.nvim",
    name = "render-markdown", -- Only needed if you have another plugin named markdown.nvim
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("render-markdown").setup()
    end,
  },
  -- ToggleTerm
  {
    "akinsho/toggleterm.nvim",
    opts = {
      size = 40,
      -- open_mapping = "<leader>tt",
      hide_numbers = true,
    },
  },
}

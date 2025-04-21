local snacks = require("snacks")

--- ログを出力する関数
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
        -- rust
        "rust-analyzer",
      },
    },
  },

  -- copilot
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = { "InsertEnter" },
    opts = {
      suggestion = {
        enabled = true,
        keymap = {
          accept = "<C-g>",
          accept_word = false,
          accept_line = false,
          next = "<C-]>",
          prev = "<C-[>",
          dismiss = "<C-e>",
        },
      },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        gitcommit = true,
        help = true,
        text = true,
        yaml = true,
      },
    },
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    event = "VeryLazy",
    branch = "main",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      -- { "github/copilot.vim" },
      { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log wrapper
    },
    build = "make tiktoken",
    opts = {
      debug = false, -- Enable debugging
      chat_autocomplete = true,
      model = "gemini-2.5-pro",
      -- agent = "gemini-2.5-pro",
      -- model = "claude-3.7-sonnet",
      mappings = {
        accept_diff = {
          normal = "<leader>ad",
          insert = "<leader>ad",
        },
      },
      prompts = {
        Explain = {
          prompt = "Write an explanation for the selected code as paragraphs of text step by step in Japanese.",
          system_prompt = "COPILOT_EXPLAIN",
        },
      },
    },
  },

  {
    "famiu/bufdelete.nvim",
  },
  {
    "quarto-dev/quarto-nvim",
  },
  {
    "jmbuhr/otter.nvim",
  },
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
  {
    "akinsho/toggleterm.nvim",
    opts = {
      size = 40,
      -- open_mapping = "<leader>tt",
      hide_numbers = true,
    },
  },
  {
    "ojroques/nvim-osc52",
    config = function()
      vim.keymap.set("n", "<leader>ctl", require("osc52").copy_operator, { expr = true, desc = "Copy text object" })
      vim.keymap.set("n", "<leader>cc", "<leader>c_", { remap = true })
      vim.keymap.set("v", "<leader>ctl", require("osc52").copy_visual, { desc = "Copy visual selection" })
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
  {
    "chomosuke/typst-preview.nvim",
    lazy = false, -- or ft = 'typst'
    version = "1.*",
    opts = {}, -- lazy.nvim will implicitly calls `setup {}`
  },
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

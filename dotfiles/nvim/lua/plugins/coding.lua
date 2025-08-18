local snacks = require("snacks")

--- ログレベルの定義
---@enum LogLevel
local LogLevel = {
  INFO = "INFO",
  WARNING = "WARNING",
  ERROR = "ERROR",
}

--- ログを出力する関数
---@param msg string messages to log
---@param level LogLevel logging level
---@param notice boolean? default false
local function log(msg, level, notice)
  notice = notice or false

  local date = os.date("%Y-%m-%d %H:%M:%S")
  local _msg = string.format("[%s] : [%s] : %s", level, date, msg)
  if notice then
    vim.notify(_msg)
  else
    print(_msg)
  end
end

--- OS種別の定義
---@enum OSType
local OSType = {
  MACOS = "macos",
  LINUX = "Linux",
  UNKNOWN = "unknown",
}

--- OSのタイプを判定する関数
---@return OSType
local function get_os_type()
  local ok, handle = pcall(io.popen, "uname")
  if not ok or handle == nil then
    log("Failed to detect OS type", LogLevel.ERROR, true)
    return OSType.UNKNOWN
  end

  local ok_read, result = pcall(handle.read, handle, "*a")
  handle:close()

  if not ok_read then
    log("Failed to read OS information", LogLevel.ERROR, true)
    return OSType.UNKNOWN
  end

  if result:match("Darwin") then
    return OSType.MACOS
  elseif result:match("Linux") then
    return OSType.LINUX
  else
    return OSType.UNKNOWN
  end
end

---OSごとにVaultディレクトリのパスが違うので、対応してセットするための関数
---@return string?
local function set_vault_path()
  local os_type = get_os_type()
  local exists_myvault = (vim.fn.isdirectory("~/Dropbox/MyVault") == 1 or vim.fn.isdirectory("~/MyVault") == 1)

  if os_type == OSType.LINUX then
    return exists_myvault and "~/Dropbox/MyVault" or nil
  elseif os_type == OSType.MACOS then
    return exists_myvault and "~/MyVault" or nil
  else
    log("Unknown OS Type when setting your vault path", LogLevel.WARNING, true)
    return nil
  end
end

---Obsidianのワークスペース設定を生成する関数
---@return table
local function set_workspace()
  local path = set_vault_path()
  if path then
    return { workspace = {
      name = "MyVault",
      path = path,
    } }
  else
    return {}
  end
end

---現在のノードの絶対パスを取得する関数
---@param state table Neo-tree state
---@return string
local function get_abs_path(state)
  return state.tree:get_node().path
end

---現在のノードの相対パスを取得する関数
---@param state table Neo-tree state
---@return string
local function get_relative_path(state)
  local abs_path = state.tree:get_node().path
  return vim.fn.fnamemodify(abs_path, ":.:")
end

---クリップボードに値をセットする関数（統合版）
---@param value string
---@param use_osc52 boolean? OSC52を使用するか（リモート用）
local function set_to_clipboard(value, use_osc52)
  if use_osc52 then
    local ok, osc52 = pcall(require, "osc52")
    if ok then
      osc52.copy(value)
    else
      log("Failed to load osc52 module", LogLevel.ERROR, true)
    end
  else
    vim.notify("set to clipboard: " .. value)
    vim.fn.setreg("+", value)
  end
end

vim.api.nvim_create_user_command("InitLua", function()
  vim.cmd.edit(vim.fn.stdpath("config") .. "/init.lua")
end, { desc = "Open init.lua" })

vim.api.nvim_create_user_command("CopyLastCmd", function()
  vim.fn.setreg("*", vim.fn.getreg(":"))
end, { desc = "Copy last used command" })

-- AI関連プラグインの共通設定
local ai_config = {
  copilot_model = "claude-4.0-sonnet",
  gemini_model = "gemini-2.5-pro",
}

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
    "mason-org/mason.nvim",
    version = "^1.0.0",
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
  {
    "mason-org/mason-lspconfig.nvim",
    version = "^1.0.0",
  },
  {
    "github/copilot.vim",
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = { "InsertEnter" },
    opts = {
      suggestion = {
        enabled = true,
        -- hide_during_completion = true
        keymap = {
          accept = "<C-g>",
          accept_word = false,
          accept_line = "<C-g>",
          next = "<C-]>",
          prev = "<C-[>",
          dismiss = "<C-e>",
        },
      },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        gitcommit = true,
        gitrebase = false,
        help = true,
        text = true,
        yaml = true,
        sh = function()
          if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), "^%.env.*") then
            -- disable for .env files
            return false
          end
          return true
        end,
      },
      copilot_model = "gpt-4o-copilot",
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
      model = ai_config.gemini_model,
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
    "obsidian-nvim/obsidian.nvim",
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
                "copy_relative_path",
                desc = "Copy relative path to clipboard",
              },
              ["<leader>ya"] = {
                "copy_absolute_path",
                desc = "Copy absolute path to clipboard",
              },
              ["<leader>ylr"] = {
                "copy_relative_path_from_remote",
                desc = "Copy relative path to local clipboard from remote",
              },
              ["<leader>yla"] = {
                "copy_absolute_path_from_remote",
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
            copy_relative_path = function(state)
              local rel_path = get_relative_path(state)
              set_to_clipboard(rel_path, false)
            end,
            copy_absolute_path = function(state)
              local abs_path = get_abs_path(state)
              set_to_clipboard(abs_path, false)
            end,
            copy_relative_path_from_remote = function(state)
              local rel_path = get_relative_path(state)
              set_to_clipboard(rel_path, true)
            end,
            copy_absolute_path_from_remote = function(state)
              local abs_path = get_abs_path(state)
              set_to_clipboard(abs_path, true)
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
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    opts = {
      ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
      provider = "copilot",
      augt_suggestion_provider = "copilot",
      providers = {
        copilot = {
          endpoint = "https://api.githubcopilot.com",
          model = ai_config.copilot_model, -- 共通設定から参照
          timeout = 30000,
          extra_request_body = {
            temperature = 0,
            max_tokens = 4096,
          },
        },
      },
      mappings = {
        --- @class AvanteConflictMappings
        sidebar = {
          apply_all = "z",
          apply_cursor = "c",
        },
        ask = "<leader>ua",
        edit = "<leader>ue",
        refresh = "<leader>ur",
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    keys = function(_, keys)
      ---@type avante.Config
      local opts =
        require("lazy.core.plugin").values(require("lazy.core.config").spec.plugins["avante.nvim"], "opts", false)

      local mappings = {
        {
          opts.mappings.ask,
          function()
            require("avante.api").ask()
          end,
          desc = "avante: ask",
          mode = { "n", "v" },
        },
        {
          opts.mappings.refresh,
          function()
            require("avante.api").refresh()
          end,
          desc = "avante: refresh",
          mode = "v",
        },
        {
          opts.mappings.edit,
          function()
            require("avante.api").edit()
          end,
          desc = "avante: edit",
          mode = { "n", "v" },
        },
      }
      mappings = vim.tbl_filter(function(m)
        return m[1] and #m[1] > 0
      end, mappings)
      return vim.list_extend(mappings, keys)
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "echasnovski/mini.pick", -- for file_selector provider mini.pick
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        -- This stops _all_ linting from running on markdown.
        ["markdownlint-cli2"] = {
          args = { "--config", vim.fn.stdpath("config") .. ".markdownlint-cli2.jsonc", "--" },
        },
      },
    },
  },
  {
    "L3MON4D3/LuaSnip",
    -- follow latest release.
    version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    -- install jsregexp (optional!).
    build = "make install_jsregexp",
    config = function()
      require("luasnip").filetype_extend("markdown", { "markdown" })
      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_lua").load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
    end,
  },
  {
    "greggh/claude-code.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim", -- Required for git operations
    },
    config = function()
      require("claude-code").setup()
    end,
  },
}

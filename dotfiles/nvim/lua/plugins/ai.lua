-- AI assistant plugins
return {
  -- GitHub Copilot (Lua version)
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = false,
          auto_trigger = false,
          keymap = {
            accept = "<M-a>",
            accept_word = "<M-w>",
            accept_line = "<C-g>",
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
        panel = {
          enabled = true,
          auto_refresh = false,
          keymap = {
            jump_prev = "[[",
            jump_next = "]]",
            accept = "<CR>",
            refresh = "gr",
            open = "<M-CR>",
          },
        },
      })
    end,
  },

  -- Copilot Chat
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    cmd = { "CopilotChat", "CopilotChatOpen", "CopilotChatToggle" },
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    -- Use default configuration
    -- Run :CopilotChatModels to see available models
  },

  -- Claude Code integration
  {
    "greggh/claude-code.nvim",
    cmd = { "ClaudeCode" },
    keys = {
      { "<leader>c,", mode = { "n", "t" } },
      { "<leader>cC", mode = "n" },
      { "<leader>cV", mode = "n" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("claude-code").setup({
        keymaps = {
          toggle = {
            normal = "<leader>c,",
            terminal = "<leader>c,",
            variants = {
              continue = "<leader>cC",
              verbose = "<leader>cV",
            },
          },
          window_navigation = true,
          scrolling = true,
        },
      })
    end,
  },

  -- Avante.nvim
  {
    "yetone/avante.nvim",
    build = vim.fn.has("win32") ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
      or "make BUILD_FROM_SOURCE=false",
    event = "VeryLazy",
    version = false,
    ---@module 'avante'
    ---@type avante.Config
    opts = {
      debug = false,
      instructions_file = "avante.md",
      provider = "copilot",
      augt_suggestion_provider = "copilot",
      providers = {
        copilot = {
          endpoint = "https://api.githubcopilot.com",
          model = "gemini-3-pro-preview", -- Gemini via Copilot API
          timeout = 30000,
          extra_request_body = {
            temperature = 0,
            max_tokens = 4096,
          },
        },
      },
      mappings = {
        sidebar = {
          apply_all = "z",
          apply_cursor = "c",
        },
        ask = "<leader>ua",
        edit = "<leader>ue",
        refresh = "<leader>ur",
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "saghen/blink.cmp",
      "ibhagwan/fzf-lua",
      "stevearc/dressing.nvim",
      "folke/snacks.nvim",
      "nvim-tree/nvim-web-devicons",
      "zbirenbaum/copilot.lua",
      {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            use_absolute_path = true,
          },
        },
      },
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
}

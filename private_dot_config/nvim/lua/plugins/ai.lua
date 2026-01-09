-- AI assistant plugins
return {
  -- GitHub Copilot (Lua version)
  -- Used as backend for:
  -- - blink-cmp-copilot (completion via blink.cmp)
  -- - CopilotChat (chat interface)
  -- - Avante (AI assistant)
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = { enabled = false }, -- Use blink.cmp instead
        panel = { enabled = false },      -- Not needed
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
        or "make",
    event = "VeryLazy",
    version = false,
    config = function(_, opts)
      -- Ensure copilot is setup before avante
      require("copilot").setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
      })
      -- Check if copilot is authenticated before using copilot provider
      local copilot_hosts = vim.fn.expand("~/.config/github-copilot/hosts.json")
      local copilot_apps = vim.fn.expand("~/.config/github-copilot/apps.json")
      if vim.fn.filereadable(copilot_hosts) == 0 and vim.fn.filereadable(copilot_apps) == 0 then
        vim.notify("Copilot not authenticated. Run :Copilot auth first, or change avante provider.", vim.log.levels.WARN)
        opts.provider = "claude" -- Fallback to claude if copilot not authenticated
      end
      require("avante").setup(opts)
    end,
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

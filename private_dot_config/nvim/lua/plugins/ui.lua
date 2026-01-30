-- UI related plugins
return {
  -- Theme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        transparent_background = false,
        show_end_of_buffer = false,
        term_colors = true,
        no_italic = true,
        no_bold = true,
        no_underline = true,
        styles = {
          comments = {},
          conditionals = {},
        },
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          treesitter = true,
          native_lsp = {
            enabled = true,
          },
          notify = false,
          mini = false,
        },
      })

      vim.cmd.colorscheme("catppuccin")
    end,
  },
  -- Monokai
  {
    "polirritmico/monokai-nightasty.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("monokai-nightasty").setup({
        on_colors = function(colors)
          colors.bg = "#1a1a1a"
        end,
      })
      -- vim.cmd.colorscheme("monokai-nightasty")
      -- monokai用のwhitespace設定
      local function set_monokai_whitespace()
        if vim.g.colors_name and vim.g.colors_name:match("monokai") then
          vim.api.nvim_set_hl(0, "Whitespace", { fg = "#6a6a6a" })
          vim.api.nvim_set_hl(0, "NonText", { fg = "#6a6a6a" })
          vim.api.nvim_set_hl(0, "IblWhitespace", { fg = "#6a6a6a" })
        end
      end
      set_monokai_whitespace()
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "monokai*",
        callback = set_monokai_whitespace,
      })
    end,
  },

  -- Nightfox (nightfox, dayfox, dawnfox, nordfox, terafox, carbonfox, duskfox)
  {
    "EdenEast/nightfox.nvim",
    lazy = true,
    opts = {},
  },

  -- Tokyo Night (night, storm, day, moon)
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      style = "night",
    },
  },

  -- Rose Pine (main, moon, dawn)
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = true,
    opts = {},
  },

  -- Kanagawa (wave, dragon, lotus)
  {
    "rebelot/kanagawa.nvim",
    lazy = true,
    opts = {},
  },

  -- Set lualine as statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        icons_enabled = false,
        theme = "catppuccin",
        component_separators = "|",
        section_separators = "",
      },
    },
  },

  -- Add indentation guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "VeryLazy",
    opts = {
      indent = {
        char = "│",
      },
      whitespace = {
        highlight = "IblWhitespace",
        remove_blankline_trail = false,
      },
      scope = {
        enabled = true,
      },
    },
    config = function(_, opts)
      -- monokai用の設定
      if vim.g.colors_name and vim.g.colors_name:match("monokai") then
        vim.api.nvim_set_hl(0, "IblWhitespace", { fg = "#6a6a6a" })
      end
      require("ibl").setup(opts)
    end,
  },

  -- Bufferline
  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup()
    end,
  },

  -- Noice - UI for messages, cmdline and popupmenu
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = false,
      },
    },
    keys = {
      { "<leader>sn", "", desc = "+noice" },
      { "<leader>snl", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
      { "<leader>snh", function() require("noice").cmd("history") end, desc = "Noice History" },
      { "<leader>sna", function() require("noice").cmd("all") end, desc = "Noice All" },
      { "<leader>snd", function() require("noice").cmd("dismiss") end, desc = "Dismiss All" },
    },
  },

  -- Todo comments
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      signs = true,
      sign_priority = 8,
      keywords = {
        FIX = {
          icon = " ",
          color = "error",
          alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
        },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      },
      gui_style = {
        fg = "NONE",
        bg = "BOLD",
      },
      merge_keywords = true,
      highlight = {
        multiline = true,
        multiline_pattern = "^.",
        multiline_context = 10,
        before = "",
        keyword = "wide",
        after = "fg",
        pattern = [[.*<(KEYWORDS)\s*:]],
        comments_only = true,
        max_line_len = 400,
        exclude = {},
      },
      colors = {
        error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
        warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
        info = { "DiagnosticInfo", "#2563EB" },
        hint = { "DiagnosticHint", "#10B981" },
        default = { "Identifier", "#7C3AED" },
        test = { "Identifier", "#FF00FF" },
      },
      search = {
        command = "rg",
        args = {
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
        },
        pattern = [[\b(KEYWORDS):]],
      },
    },
  },
}

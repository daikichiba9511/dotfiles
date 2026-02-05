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

      -- vim.cmd.colorscheme("catppuccin")
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
    opts = {
      options = {
        styles = {
          comments = "NONE",
          keywords = "NONE",
          types = "NONE",
        },
      },
    },
  },

  -- Tokyo Night (night, storm, day, moon)
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      style = "night",
      styles = {
        comments = { italic = false },
        keywords = { italic = false },
        functions = {},
        variables = {},
      },
    },
  },

  -- Rose Pine (main, moon, dawn)
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    opts = {
      styles = {
        italic = false,
      },
      palette = {
        main = {
          base = "#0f0f14", -- darker background
        },
      },
    },
    config = function(_, opts)
      require("rose-pine").setup(opts)
      vim.cmd.colorscheme("rose-pine")
    end,
  },

  -- Kanagawa (wave, dragon, lotus)
  {
    "rebelot/kanagawa.nvim",
    lazy = true,
    opts = {
      commentStyle = { italic = false },
      keywordStyle = { italic = false },
      statementStyle = { bold = false },
    },
  },

  -- Mode indicator via cursor line highlight
  {
    "mvllow/modes.nvim",
    event = "VeryLazy",
    opts = {
      colors = {
        insert = "#9ccfd8",  -- foam
        visual = "#eb6f92",  -- love
        delete = "#eb6f92",  -- love
        copy = "#f6c177",    -- gold
      },
      line_opacity = 0.2,
      set_cursor = true,
      set_cursorline = true,
      set_number = true,
    },
  },

  -- Floating statusline (right bottom)
  {
    "b0o/incline.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local devicons = require("nvim-web-devicons")
      require("incline").setup({
        window = {
          padding = 1,
          margin = { horizontal = 1, vertical = 1 },
          placement = { horizontal = "right", vertical = "bottom" },
        },
        hide = {
          cursorline = true,
          focused_win = false,
          only_win = false,
        },
        render = function(props)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          if filename == "" then
            filename = "[No Name]"
          end

          -- Show parent directory for common filenames
          local common_names = { "index", "init", "main", "mod" }
          local base = vim.fn.fnamemodify(filename, ":r")
          for _, name in ipairs(common_names) do
            if base == name then
              local parent = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":h:t")
              filename = parent .. "/" .. filename
              break
            end
          end

          -- File icon
          local ft_icon, ft_color = devicons.get_icon_color(filename)
          local icon = ft_icon and { ft_icon, " ", guifg = ft_color } or ""

          -- Modified indicator
          local modified = vim.bo[props.buf].modified
          local modified_icon = modified and { " ●", guifg = "#f6c177" } or ""

          -- Diagnostics
          local diagnostics = {}
          local icons = { Error = " ", Warn = " ", Hint = " ", Info = " " }
          local colors = { Error = "#eb6f92", Warn = "#f6c177", Hint = "#9ccfd8", Info = "#31748f" }
          for severity, icon_str in pairs(icons) do
            local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[string.upper(severity)] })
            if n > 0 then
              table.insert(diagnostics, { icon_str .. n .. " ", guifg = colors[severity] })
            end
          end

          return {
            icon,
            filename,
            modified_icon,
            #diagnostics > 0 and { " " } or "",
            diagnostics,
            guibg = "#26233a",
            guifg = "#e0def4",
          }
        end,
      })
    end,
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

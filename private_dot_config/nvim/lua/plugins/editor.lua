-- Editor enhancement plugins
return {
  -- Detect tabstop and shiftwidth automatically
  { "tpope/vim-sleuth", event = { "BufReadPost", "BufNewFile" } },

  -- "gc" to comment visual regions/lines
  { "numToStr/Comment.nvim", event = { "BufReadPost", "BufNewFile" }, opts = {} },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },

  -- Surround - add/change/delete surrounding pairs
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },

  -- Flash - fast navigation
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    },
  },

  -- Trouble - diagnostics list
  {
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
      { "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP Definitions / references" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
    },
  },

  -- Useful plugin to show pending keybinds
  { "folke/which-key.nvim", event = "VeryLazy", opts = {} },

  -- Highlight, edit, and navigate code
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    config = function()
      -- Setup nvim-treesitter (required for main branch)
      require("nvim-treesitter").setup({})

      -- Install parsers programmatically
      require("nvim-treesitter").install({
        "lua", "vim", "vimdoc", "python", "julia",
        "markdown", "markdown_inline", "tsx", "javascript", "typescript",
      })

      -- Enable treesitter highlighting (required for main branch)
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },

  -- Show current scope (function/class) at top of buffer while scrolling
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      max_lines = 3,
    },
    keys = {
      {
        "[C",
        function() require("treesitter-context").go_to_context() end,
        desc = "Go to context (top scope)",
      },
    },
  },

  -- Navigate and select by function/class/parameter
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require("nvim-treesitter-textobjects").setup({})

      local move = require("nvim-treesitter-textobjects.move")
      local select = require("nvim-treesitter-textobjects.select")

      -- Move between functions/classes
      local map = vim.keymap.set
      map({ "n", "x", "o" }, "]m", function() move.goto_next_start("@function.outer") end, { desc = "Next function start" })
      map({ "n", "x", "o" }, "]M", function() move.goto_next_end("@function.outer") end, { desc = "Next function end" })
      map({ "n", "x", "o" }, "[m", function() move.goto_previous_start("@function.outer") end, { desc = "Prev function start" })
      map({ "n", "x", "o" }, "[M", function() move.goto_previous_end("@function.outer") end, { desc = "Prev function end" })
      map({ "n", "x", "o" }, "]C", function() move.goto_next_start("@class.outer") end, { desc = "Next class start" })
      map({ "n", "x", "o" }, "[C", function() move.goto_previous_start("@class.outer") end, { desc = "Prev class start" })

      -- Select function/class textobjects
      map({ "x", "o" }, "af", function() select.select_textobject("@function.outer") end, { desc = "outer function" })
      map({ "x", "o" }, "if", function() select.select_textobject("@function.inner") end, { desc = "inner function" })
      map({ "x", "o" }, "ac", function() select.select_textobject("@class.outer") end, { desc = "outer class" })
      map({ "x", "o" }, "ic", function() select.select_textobject("@class.inner") end, { desc = "inner class" })
      map({ "x", "o" }, "aa", function() select.select_textobject("@parameter.outer") end, { desc = "outer parameter" })
      map({ "x", "o" }, "ia", function() select.select_textobject("@parameter.inner") end, { desc = "inner parameter" })
    end,
  },
}

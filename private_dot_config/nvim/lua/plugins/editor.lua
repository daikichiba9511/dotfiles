-- Editor enhancement plugins
local treesitter_parsers = {
  "javascript",
  "julia",
  "lua",
  "markdown",
  "markdown_inline",
  "python",
  "tsx",
  "typescript",
  "typst",
  "vim",
  "vimdoc",
}

return {
  -- Detect tabstop and shiftwidth automatically
  { "tpope/vim-sleuth", event = { "BufReadPost", "BufNewFile" } },

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

  -- Useful plugin to show pending keybinds
  { "folke/which-key.nvim", event = "VeryLazy", opts = {} },

  -- Highlight, edit, and navigate code
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = function()
      local treesitter = require("nvim-treesitter")
      treesitter.install(treesitter_parsers):wait(300000)
      treesitter.update(treesitter_parsers):wait(300000)
    end,
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },
}

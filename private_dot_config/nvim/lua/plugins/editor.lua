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
}

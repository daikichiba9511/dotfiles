-- Editor enhancement plugins
return {
  -- Detect tabstop and shiftwidth automatically
  "tpope/vim-sleuth",

  -- "gc" to comment visual regions/lines
  { "numToStr/Comment.nvim", opts = {} },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },

  -- Useful plugin to show pending keybinds
  { "folke/which-key.nvim", opts = {} },

  -- Highlight, edit, and navigate code
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      -- Setup nvim-treesitter (required for main branch)
      require("nvim-treesitter").setup({})

      -- Install parsers programmatically
      require("nvim-treesitter").install({ "lua", "vim", "vimdoc", "python", "julia" })

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

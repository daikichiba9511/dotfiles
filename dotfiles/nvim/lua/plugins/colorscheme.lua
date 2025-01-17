vim.opt.termguicolors = true
vim.opt.background = "dark"

return {
  {
    "LazyVim/LazyVim",
    opts = {
      -- colorscheme = "carbonfox",
      -- colorscheme = "tokyonight",
      -- colorscheme = "nightfox",
      -- colorscheme = "onedark",
      colorscheme = "catppuccin",
    },
  },
  {
    "folke/tokyonight.nvim",
    opts = {
      -- style = "night",
      style = "moon",
      styles = {
        comments = { italic = false },
        keywords = { italic = false },
      },
      transparent = true,
    },
  },
  {
    "EdenEast/nightfox.nvim",
    opts = {
      style = "carbon",
    },
  },
  {
    "catppuccin/nvim",
    priority = 1000,
    name = "catppuccin",
    opts = {
      flavour = "mocha",
      background = {
        light = "latte",
        black = "mocha",
      },
      transparent_background = true, -- disables setting the background color.
      no_italics = true,
      no_bold = true,
      no_underline = true,
      styles = {
        comments = {},
        keywords = {},
      },
      integrations = {
        cmp = true,
        gitsigns = true,
        treesitter = true,
        harpoon = true,
        telescope = true,
        mason = true,
        noice = true,
        notify = true,
        which_key = true,
        fidget = true,
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
          },
          underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
          },
          inlay_hints = {
            background = true,
          },
        },
      },
    },
  },
  {
    "navarasu/onedark.nvim",
    opts = {
      style = "darker",
      transparent = false,
      code_style = {
        comments = "none",
      },
    },
  },
}

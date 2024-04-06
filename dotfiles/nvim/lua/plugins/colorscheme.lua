return {
  {
    "LazyVim/LazyVim",
    opts = {
      -- colorscheme = "carbonfox",
      colorscheme = "tokyonight",
      -- colorscheme = "nightfox",
      -- colorscheme = "onedark",
      -- colorscheme = "catppuccin",
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
    opts = {
      flavour = "mocha",
      background = {
        light = "latte",
        black = "mocha",
      },
      transparent_background = true, -- disables setting the background color.
      no_italics = true,
      no_bold = true,
    },
    name = "catppuccin",
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

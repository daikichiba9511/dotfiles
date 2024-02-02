return {
  {
    "LazyVim/LazyVim",
    opts = {
      -- colorscheme = "carbonfox",
      colorscheme = "tokyonight",
      -- colorscheme = "nightfox",
      -- colorscheme = "onedark",
    },
  },
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night",
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
    name = "catppuccin",
    opts = {
      transparent_background = false,
      no_italics = true,
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

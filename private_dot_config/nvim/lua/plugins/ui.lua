-- UI related plugins
return {
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
}

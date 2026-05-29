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
        -- Kept for when switching back to the dark `rose-pine` variant.
        main = {
          base = "#0f0f14",
        },
      },
    },
    config = function(_, opts)
      require("rose-pine").setup(opts)
      vim.cmd.colorscheme("rose-pine-dawn")
    end,
  },
}

require("ibl").setup({
  enabled = true,
  scope = {
    enabled = true,
    show_start = false,
    show_end = true,
    injected_languages = true,
  },
  indent = {
    char = "│",
  },
  exclude = {
    buftypes = { "terminal" },
    filetypes = {
      "help",
      "lspinfo",
      "packer",
      "checkhealth",
      "man",
      "gitcommit",
      "TelescopePrompt",
      "TelescopeResults",
      "lspsagafinder",
      "log",
      "alpha",
      "toggleterm",
    },
  },
})

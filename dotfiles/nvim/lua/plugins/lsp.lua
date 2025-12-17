-- LSP Configuration & Plugins
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      {
        "williamboman/mason.nvim",
        cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonUninstall", "MasonUninstallAll", "MasonLog" },
        config = true,
      },
      {
        "williamboman/mason-lspconfig.nvim",
        lazy = true,
      },
      -- Useful status updates for LSP
      { "j-hui/fidget.nvim", opts = {} },
      -- Additional lua configuration
      "folke/neodev.nvim",
    },
  },
  {
    "folke/neodev.nvim",
  },
}

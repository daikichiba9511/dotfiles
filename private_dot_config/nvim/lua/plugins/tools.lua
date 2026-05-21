-- Utility and tool plugins
return {
  -- Formatter
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local conform = require("conform")

      conform.setup({
        formatters_by_ft = {
          python = { "ruff_format", "ruff_fix" },
          lua = { "stylua" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          javascriptreact = { "prettier" },
          typescriptreact = { "prettier" },
          json = { "prettier" },
          yaml = { "prettier" },
          markdown = { "prettier" },
          html = { "prettier" },
          css = { "prettier" },
          sql = { "sqlfluff" },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })

      -- Format keymap
      vim.keymap.set({ "n", "v" }, "<leader>mp", function()
        conform.format({
          lsp_fallback = true,
          async = false,
          timeout_ms = 500,
        })
      end, { desc = "Format file or range (in visual mode)" })
    end,
  },

  -- Markdown preview in terminal (Kitty graphics)
  {
    "delphinus/md-render.nvim",
    version = "*",
    ft = { "markdown" },
    dependencies = {
      { "nvim-tree/nvim-web-devicons", version = "*" },
      { "delphinus/budoux.lua", version = "*" },
    },
    keys = {
      { "<leader>mr", "<Plug>(md-render-preview)", desc = "Markdown render (float toggle)" },
      { "<leader>mR", "<Plug>(md-render-preview-tab)", desc = "Markdown render (tab toggle)" },
    },
  },

  -- Typst preview in browser
  {
    "chomosuke/typst-preview.nvim",
    version = "1.*",
    ft = "typst",
    opts = {},
    keys = {
      { "<leader>tp", "<cmd>TypstPreview<cr>", desc = "Typst Preview" },
      { "<leader>ts", "<cmd>TypstPreviewStop<cr>", desc = "Typst Preview Stop" },
      { "<leader>tt", "<cmd>TypstPreviewToggle<cr>", desc = "Typst Preview Toggle" },
    },
  },
}

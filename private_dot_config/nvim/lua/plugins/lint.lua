-- Diagnostic linters (non-LSP CLIs surfaced via vim.diagnostic)
return {
  {
    "mfussenegger/nvim-lint",
    ft = "markdown",
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        markdown = { "markdownlint-cli2" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
        callback = function(args)
          if vim.bo[args.buf].filetype == "markdown" then
            lint.try_lint()
          end
        end,
      })
    end,
  },
}

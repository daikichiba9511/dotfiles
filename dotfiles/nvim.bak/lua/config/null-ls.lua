local null_ls = require("null-ls")

local function file_exists(fname)
  local stat = vim.loop.fs_stat(vim.fn.expand(fname))
  return (stat and stat.type) or false
end

-- local spell_args = { "-" }
-- if file_exists("./.nvim/ignore_codespell.txt") then
-- 	spell_args = { "--ignore-words=./.nvim/ignore_codespell.txt", "-" }
-- end

-- highlight whitespace

local ignored_filetypes = {
  "TelescopePrompt",
  "diff",
  "gitcommit",
  "unite",
  "qf",
  "help",
  "markdown",
  "minimap",
  "packer",
  "dashboard",
  "telescope",
  "lsp-installer",
  "lspinfo",
  "NeogitCommitMessage",
  "NeogitCommitView",
  "NeogitGitCommandHistory",
  "NeogitLogView",
  "NeogitNotification",
  "NeogitPopup",
  "NeogitStatus",
  "NeogitStatusNew",
  "aerial",
  "null-ls-info",
}

local groupname = "vimrc_null_ls"

vim.api.nvim_create_augroup(groupname, { clear = true })
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = groupname,
  pattern = "*",
  callback = function()
    if vim.tbl_contains(ignored_filetypes, vim.bo.filetype) then
      return
    end

    vim.fn.matchadd("DiffDelete", "\\v\\s+$")
  end,
  once = false,
})

-- Python settings
local python_line_length = "89"

local ruff_is_executable = vim.fn.executable("ruff")

local sources = {
  null_ls.builtins.formatting.trim_whitespace.with({
    disabled_filetypes = ignored_filetypes,
    runtime_condition = function()
      local count = tonumber(vim.api.nvim_exec("execute 'silent! %s/\\v\\s+$//gn'", true):match("%w+"))
      if count then
        return vim.fn.confirm("Whitespace found, delete it?", "&No\n&Yes", 1, "Question") == 2
      end
    end,
  }),
  null_ls.builtins.formatting.clang_format.with({
    extra_args = {
      "-style=google",
    },
    condition = function()
      return vim.fn.executable("clang-format") > 0
    end,
  }),
  null_ls.builtins.formatting.stylua.with({
    condition = function()
      return vim.fn.executable("stylua") > 0
    end,
  }),
  null_ls.builtins.formatting.black.with({
    condition = function()
      return vim.fn.executable("black") > 0 and not ruff_is_executable
    end,
  }),
  null_ls.builtins.formatting.isort.with({
    condition = function()
      return vim.fn.executable("isort") > 0 and not ruff_is_executable
    end,
    extra_args = { "--profile", "black" },
  }),
  null_ls.builtins.diagnostics.pyproject_flake8.with({
    condition = function()
      return vim.fn.executable("pflake8") > 0 and not ruff_is_executable
    end,
  }),
  -- null_ls.builtins.diagnostics.ruff.with({
  --   condition = function()
  --     return ruff_is_executable
  --   end,
  -- }),
  -- null_ls.builtins.formatting.ruff.with({
  --   condition = function()
  --     return ruff_is_executable
  --   end,
  -- }),
  null_ls.builtins.formatting.prettier.with({
    condition = function()
      return vim.fn.executable("prettier") > 0
    end,
  }),
  null_ls.builtins.diagnostics.eslint.with({
    condition = function()
      return vim.fn.executable("eslint") > 0
    end,
  }),
  null_ls.builtins.formatting.shfmt.with({
    condition = function()
      return vim.fn.executable("shfmt") > 0
    end,
  }),
  null_ls.builtins.diagnostics.shellcheck.with({
    condition = function()
      return vim.fn.executable("shellcheck") > 0
    end,
  }),
  null_ls.builtins.diagnostics.shellcheck.with({
    condition = function()
      return vim.fn.executable("shellcheck") > 0
    end,
  }),
  null_ls.builtins.diagnostics.vale.with({
    diagnostics_postprocess = function(diagnostic)
      diagnostic.severity = vim.diagnostic.severity["WARN"]
    end,
    condition = function()
      return vim.fn.executable("vale") > 0
    end,
  }),
  null_ls.builtins.formatting.markdownlint.with({
    condition = function()
      return vim.fn.executable("markdownlint") > 0
    end,
  }),
  null_ls.builtins.code_actions.gitsigns,
}

-- FIX: pathを治す
if file_exists("./.nvim/local-null-ls.lua") then
  local local_null = dofile("./.nvim/local-null-ls.lua")
  sources = require("lua/utils").merge_lists(sources, local_null)
end

local lsp_formatting = function(bufnr)
  vim.lsp.buf.format({
    filter = function(client)
      return client.name ~= "tsserver"
    end,
    bufnr = bufnr,
  })
end

local augroup = vim.api.nvim_create_augroup("LspFormatting", { clear = true })
local on_attach = function(client, bufnr)
  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd({ "BufWritePre" }, {
      group = augroup,
      buffer = bufnr,
      callback = function()
        lsp_formatting(bufnr)
      end,
      once = false,
    })
  end
end

null_ls.setup({
  -- debug = true,
  sources = sources,
  on_attach = on_attach,
})

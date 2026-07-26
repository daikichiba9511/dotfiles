-- LSP configuration
-- References:
-- [1] http://zenn.dev/kawarimidoll/books/6064bf6f193b51/viewer/018161

local ls_names = {
  -- lua
  "emmylua_ls",
  -- python
  "ty",
  "ruff",
  -- typescript / mdx
  "denols",
  "ts_ls",
  "mdx_analyzer",
  -- terraform
  "terraformls",
  -- sql
  "sqls",
  -- cpp
  "clangd",
  -- markdown
  "markdown_oxide",
  "efm",
}

local mason_bin = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin")
vim.env.PATH = mason_bin .. ":" .. assert(vim.env.PATH, "PATH must be set")

vim.lsp.config("*", {
  capabilities = require("blink.cmp").get_lsp_capabilities(),
})

local julia_root = function(bufnr, on_dir)
  on_dir(vim.fs.root(bufnr, { "Project.toml", "Manifest.toml", ".git" }) or vim.fn.getcwd())
end

vim.lsp.config("jetls", {
  cmd = { vim.fn.expand("~/.julia/bin/jetls"), "--stdio" },
  filetypes = { "julia" },
  root_dir = julia_root,
})

vim.lsp.enable(ls_names)
vim.lsp.enable("jetls")

-- LSからのlint errorに(ls_name: error code)を追加
vim.diagnostic.config({
  virtual_text = {
    format = function(diagnostic)
      return string.format("%s (%s: %s)", diagnostic.message, diagnostic.source, diagnostic.code)
    end,
  },
})

-- LSPがバッファにアタッチされた時だけキーマップを入れる
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("MyLspKeymaps", { clear = true }),
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    -- 便利ヘルパ
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, noremap = true, desc = desc })
    end

    -- 基本: 定義/参照/型/実装/ホバー
    map("n", "gd", vim.lsp.buf.definition, "LSP: Go to definition")
    map("n", "gD", vim.lsp.buf.declaration, "LSP: Go to declaration")
    map("n", "gr", vim.lsp.buf.references, "LSP: References")
    map("n", "gy", vim.lsp.buf.type_definition, "LSP: Type definition")
    map("n", "gI", vim.lsp.buf.implementation, "LSP: Implementation")
    map("n", "K", vim.lsp.buf.hover, "LSP: Hover")

    -- リネーム/コードアクション/フォーマット
    map("n", "<leader>rn", vim.lsp.buf.rename, "LSP: Rename")
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "LSP: Code Action")
    map("n", "<leader>f", function()
      vim.lsp.buf.format({ async = false })
    end, "LSP: Format buffer")

    -- 必要なら inlay hints（対応サーバのみ）
    if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
      map("n", "<leader>ih", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ buf = bufnr }), { buf = bufnr })
      end, "LSP: Toggle inlay hints")
    end
  end,
})

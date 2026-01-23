-- LSP configuration
-- References:
-- [1] http://zenn.dev/kawarimidoll/books/6064bf6f193b51/viewer/018161

local ls_names = {
  -- general
  "copilot",
  -- lua
  "lua_ls",
  -- python
  "basedpyright", -- Fork of pyright with stricter type checking and Pylance features
  "ruff",
  -- typescript / mdx
  "ts_ls",
  "mdx_analyzer",
  -- terraform
  "terraformls",
  -- sql
  "sqls",
  -- cpp
  "clangd",
}

-- Setup Mason-lspconfig
require("mason-lspconfig").setup({
  automatic_installation = true,
  ensure_installed = ls_names,
})

vim.lsp.enable(ls_names)
vim.lsp.enable({ "jetls" })

vim.lsp.config("*", {
  capabilities = require("blink.cmp").get_lsp_capabilities(),
})

-- lua_ls specific configuration
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = { "vim" },
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

-- jetls configuration (Julia)
vim.lsp.config("jetls", {
  cmd = { vim.fn.expand("~/.julia/bin/jetls"), "--stdio" },
  filetypes = { "julia" },
  root_dir = function(fname)
    local root = vim.fs.root(fname, { "Project.toml", "Manifest.toml", ".git" })
    return root or vim.fn.getcwd()
  end,
})

-- Auto-attach LSP servers to Julia buffers
vim.api.nvim_create_autocmd("FileType", {
  pattern = "julia",
  callback = function(ev)
    local root = vim.fs.root(0, { "Project.toml", "Manifest.toml", ".git" }) or vim.fn.getcwd()
    local caps = require("blink.cmp").get_lsp_capabilities()

    -- Start JETLS (for advanced analysis, testing, etc.)
    vim.lsp.start({
      name = "jetls",
      cmd = { vim.fn.expand("~/.julia/bin/jetls"), "--stdio" },
      capabilities = caps,
      root_dir = root,
    })

    -- Start LanguageServer.jl (for hover, completion, etc.)
    -- インストール方法（コミュニティ推奨）:
    --   julia -e 'import Pkg; Pkg.add("LanguageServer"); Pkg.add("SymbolServer")'
    --
    -- NOTE: 初回起動時にSymbolServerのキャッシュ構築で時間がかかる場合があります。
    -- これはJulia 1.12のworld age変更による既知の動作です。
    -- 参考: https://github.com/julia-vscode/julia-vscode/issues/3874
    vim.lsp.start({
      name = "julials",
      cmd = {
        "julia",
        "--startup-file=no",
        "--history-file=no",
        "-e",
        [[
          using LanguageServer, SymbolServer;
          depot_path = get(ENV, "JULIA_DEPOT_PATH", "");
          project_path = dirname(something(Base.current_project(), pwd()));
          server = LanguageServer.LanguageServerInstance(stdin, stdout, project_path, depot_path);
          server.runlinter = true;
          run(server);
        ]],
      },
      capabilities = caps,
      root_dir = root,
    })
  end,
})

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

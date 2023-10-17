-- require("mason-lspconfig").setup()
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
local util = require("lspconfig/util")

local on_attach_fn = function(client, bufnr)
  local function buf_set_keymap(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end
  -- local function buf_set_option(...)
  -- 	vim.api.nvim_buf_set_option(bufnr, ...)
  -- end

  -- ruffのときはhover off
  if client.name == "ruff_lsp" then
    client.resolved_capabilities.hover = false
  end

  local opts = { noremap = true, silent = true }

  -- ignore semantic highlighting
  -- Ref:
  -- [1] https://neovim.discourse.group/t/annoying-enforcing-syntax-highlighting-rust-analyzer-lsp/3856
  client.server_capabilities.semanticTokensProvider = nil

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
  buf_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  buf_set_keymap("n", "?", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
  buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
  buf_set_keymap("n", "g?", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
  buf_set_keymap("n", "[lsp]wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
  buf_set_keymap("n", "[lsp]wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
  buf_set_keymap("n", "[lsp]wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
  buf_set_keymap("n", "[lsp]D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
  buf_set_keymap("n", "[lsp]rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
  buf_set_keymap("n", "[lsp]a", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
  buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
  buf_set_keymap("n", "[lsp]e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
  buf_set_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
  buf_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
  buf_set_keymap("n", "[lsp]q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
  buf_set_keymap("n", "[lsp]f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)

  require("nvim-navic").attach(client, bufnr)
  -- if vim.g.vscode then
  -- 	return nil
  -- else
  -- 	vim.cmd([[
  --            augroup lsp_document_hightlight
  --                autocmd! * <buffer>
  --                autocmd CursorHold,CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()
  --                autocmd CursorMoved,CursorMovedI <buffer> lua vim.lsp.buf.clear_references()
  --            augroup END
  --        ]])
  -- end
end

require("mason-lspconfig").setup_handlers({
  function(server_name)
    local opts = { capabilities = capabilities, on_attach = on_attach_fn }

    if server_name == "lua_ls" then
      opts.settings = {
        Lua = {
          semantic = {
            enable = false,
            keyword = false,
          },
          -- NOTE: use stylua as formatter. settings is in Null-ls
          -- format = {
          -- 	enable = true,
          -- 	-- NOTE: the value should be a string
          -- 	defaultConfig = {
          -- 		indent_style = "space",
          -- 		indent_size = "2",
          -- 	},
          -- },
          diagnostics = {
            globals = { "vim", "describe", "it" },
          },
          hint = {
            enable = true,
            arrayIndex = "Auto",
            setType = true,
          },
          workspace = {
            checkThirdParty = false,
            maxPreload = 10000,
            preloadFileSize = 10000,
            diagnostics = {
              globals = { "vim", "describe", "it" },
            },
          },
          telemetry = {
            enable = false,
          },
        },
      }
      lspconfig.lua_ls.setup(opts)
      -- return
    end

    if server_name == "pyright" then
      opts.root_dir = function(fname)
        return util.root_pattern(".git", "setup.py", "pyproject.toml", "requirements.txt")(fname)
          or util.path.dirname(fname)
      end
      opts.filetypes = { "python" }
      opts.settings = {
        python = {
          analysis = {
            typeCheckingMode = "basic",
            -- indexing = true,
            -- useFileIndexingLimit = 2000,
            diagnosticMode = "openFilesOnly",
            -- autoImportCompletions = false,
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            completeFunctionParens = true,
          },
        },
      }
      lspconfig.pyright.setup(opts)
      -- return
    end

    if server_name == "ruff_lsp" then
      opts.filetypes = { "python" }
      opts.settings = {
        lint = {
          run = "onSave",
          -- args = { "--config=./pyproject.toml" },
        },
        -- fixAll = true,
        organizeImports = true,
        args = {},
      }
      lspconfig.ruff_lsp.setup(opts)
      -- return
    end

    if server_name == "clangd" then
      opts.filetypes = { "c", "cpp" }
      opts.cmd = {
        "clangd",
        "--offset-encoding=utf-16",
      }
      lspconfig.clangd.setup(opts)
      -- return
    end

    -- if server_name == "rust_analyzer" then
    --   opts.settings = {
    --     ["rust-analyzer"] = {
    --       check = {
    --         command = "clippy",
    --       },
    --       diagnostics = {
    --         experimental = {
    --           enable = true,
    --         },
    --       },
    --     },
    --   }
    -- end

    lspconfig[server_name].setup(opts)
  end,
})

-- require("lspconfig")["satysfi-ls"].setup({ autostart = true })

-- require("mason-lspconfig").setup()
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
local util = require("lspconfig/util")

local function ruff_format(fname)
  vim.lsp.buf.execute_command({
    command = "ruff.applyFormat",
    -- arguments = { uri = vim.uri_from_bufnr(bufnr) },
    arguments = { uri = vim.uri_from_fname(fname) },
    description = "Ruff: Format texts",
  })
end
vim.api.nvim_create_user_command(
  "RuffFormat",
  "silent !ruff format --preview %",
  -- "!ruff format --preview %",
  { desc = "Ruff Format (alpha) defined in mason-lspconfig" }
)
vim.api.nvim_create_autocmd({ "BufWritePost" }, { pattern = "*.py", command = "RuffFormat" })

-- vim.api.nvim_create_autocmd(
--   { "BufWritePost" },
--   { pattern = { "*.py" }, callback = ruff_format, desc = "Ruff Format (alpha) defined in mason-config" }
-- )

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
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("UserRuffLspCFG", {}),
      callback = function(ev)
        ruff_format(ev.match)
      end,
    })
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

--- Specialized root pattern that allows for an exclustion
---@param opt { root: string[], exclude: string[] }
---@return fun(file_name: string): string | nil
---
--- Ref:
--- [1] https://www.npbee.me/posts/deno-and-typescript-in-a-monorepo-neovim-lsp
local function root_pattern_exclude(opt)
  local lsputil = require("lspconfig.util")

  return function(fname)
    local excluded_root = lsputil.root_pattern(opt.exclude)(fname)
    local included_root = lsputil.root_pattern(opt.root)(fname)

    if excluded_root then
      return nil
    else
      return included_root
    end
  end
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
      opts.init_options = {
        settings = {
          lint = {
            run = "onSave",
            -- args = { "--config=./pyproject.toml" },
          },
          -- fixAll = true,
          organizeImports = true,
          args = {},
        },
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

    -- Terraform {{{
    if server_name == "terraformls" then
      lspconfig.terraformls.setup(opts)
      vim.api.nvim_create_autocmd({ "BufWritePre" }, {
        pattern = { "*.tf", "*.tfvars" },
        callback = function()
          vim.lsp.buf.format()
        end,
      })
    end
    --}}}

    if server_name == "denols" then
      opts.filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" }
      opts.root_dir = util.root_pattern("deno.json", "deno.jsonc", "deno.lock")
      opts.init_options = {
        lint = true,
        suggest = {
          imports = {
            hosts = {
              ["https://deno.land"] = true,
            },
          },
        },
      }
      lspconfig.denols.setup(opts)
    end

    if server_name == "tsserver" then
      opts.filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" }
      opts.root_dir = root_pattern_exclude({
        root = { "package.json" },
        exclude = { "deno.json", "deno.jsonc" },
      })
      opts.single_file_support = false
      lspconfig.tsserver.setup(opts)
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

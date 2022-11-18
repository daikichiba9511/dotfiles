-- require("mason-lspconfig").setup()

vim.cmd([[
    highlight LspReferenceText  cterm=underline ctermbg=8 gui=underline guibg=#104040
    highlight LspReferenceRead  cterm=underline ctermbg=8 gui=underline guibg=#104040
    highlight LspReferenceWrite cterm=underline ctermbg=8 gui=underline guibg=#104040
]])

local on_attach_fn = function(client, bufnr)
    local function buf_set_keymap(...)
        vim.api.nvim_buf_set_keymap(bufnr, ...)
    end

    local function buf_set_option(...)
        vim.api.nvim_buf_set_option(bufnr, ...)
    end

    local opts = { noremap = true, silent = true }

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
    -- buf_set_keymap("n", "[lsp]rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts) buf_set_keymap("n", "[lsp]a", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts) buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts) buf_set_keymap("n", "[lsp]e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
    buf_set_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
    buf_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
    buf_set_keymap("n", "[lsp]q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
    buf_set_keymap("n", "[lsp]f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)

    vim.cmd([[
        augroup lsp_document_hightlight
            autocmd! * <buffer>
            autocmd CursorHold,CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()
            autocmd CursorMoved,CursorMovedI <buffer> lua vim.lsp.buf.clear_references()
        augroup END
    ]])

    require("nvim-navic").attach(client, bufnr)
end

local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
local opts = { capabilities = capabilities, on_attach = on_attach_fn }

require("mason-lspconfig").setup_handlers({
    function(server_name)
        -- if server_name == "denols" then
        --     opts.init_options = {
        --         lint = true,
        --         unstable = true,
        --         suggest = {
        --             imports = {
        --                 host = {
        --                     ["https://deno.land"] = true,
        --                     ["https://cdn.nest.land"] = true,
        --                     ["https://crux.land"] = true,
        --                 },
        --             },
        --         },
        --     }
        -- opts.root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc", "deps.ts", "import_map.json"),
        -- end

        lspconfig[server_name].setup(opts)
    end,

    ["rust_analyzer"] = function()
        local has_rust_tools, rust_tools = pcall(require, "rust-tools")
        if has_rust_tools then
            rust_tools.setup({ server = opts })
        else
            lspconfig.rust_analyzer.setup({})
        end
    end,

    ["sumneko_lua"] = function()
        local has_lua_dev, lua_dev = pcall(require, "neodev")
        if has_lua_dev then
            local l_dev = lua_dev.setup({
                library = {
                    vimruntime = true,
                    types = true,
                    plugins = { "nvim-treesitter", "plenary.nvim" },
                },
                runtime_path = false,
                lspconfig = opts,
            })
            lspconfig.sumneko_lua.setup(l_dev)
        else
            lspconfig.sumneko_lua.setup({
                settings = {
                    Lua = {
                        diagnostic = {
                            globals = { "vim" },
                        },
                    },
                },
            })
        end
    end,
})

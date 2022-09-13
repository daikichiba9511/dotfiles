local nvim_lsp = require("lspconfig")
local mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup_handlers({
    function(server_name)
        local opts = {}
        opts.on_attach = function(_, bufnr)
            local bufopts = { silent = true, buffer = bufnr }
            vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
            vim.keymap.set("n", "gd", vim.lsp.buf.type_definition, bufopts)
            vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
            vim.keymap.set("n", "<space>p", vim.lsp.buf.format, bufopts)
        end

        if server_name == "sumneko_lua" then
            opts.settings = {
                Lua = {
                    diagnostics = { global = { "vim" } }
                }
            }
        end
        nvim_lsp[server_name].setup(opts)
    end
})

mason_lspconfig.setup({
    ensure_installed = {
        "sumneko_lua",
        "pyright",
        "rust_analyzer",
        "julia-lsp",
        "clangd"
    }
})

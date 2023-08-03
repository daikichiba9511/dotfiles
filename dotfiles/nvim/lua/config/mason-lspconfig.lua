-- require("mason-lspconfig").setup()
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

local on_attach_fn = function(client, bufnr)
	local function buf_set_keymap(...)
		vim.api.nvim_buf_set_keymap(bufnr, ...)
	end
	-- local function buf_set_option(...)
	-- 	vim.api.nvim_buf_set_option(bufnr, ...)
	-- end

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

local opts = { capabilities = capabilities, on_attach = on_attach_fn }

require("mason-lspconfig").setup_handlers({
	function(server_name)
		lspconfig[server_name].setup(opts)
	end,
	["lua_ls"] = function()
		lspconfig["lua_ls"].setup({
			on_attach = on_attach_fn,
			capabilities = capabilities,
			settings = {
				Lua = {
					semantic = {
						enable = false,
						keyword = false,
					},
					runtime = {
						version = "LuaJIT",
					},
					diagnostics = {
						globals = { "vim" },
					},
					hint = {
						enable = true,
					},
					workspace = {
						checkThirdParty = false,
						diagnostics = {
							globals = { "vim" },
						},
					},
				},
			},
		})
	end,
	["pyright"] = function()
		lspconfig.pyright.setup({
			on_attach = on_attach_fn,
			capabilities = capabilities,
			settings = {
				-- pyright = {
				-- 	autoImportCompletions = false,
				-- },
				python = {
					-- venvPath = ".",
					-- pythonPath = "./.venv/bin/python",
					analysis = {
						typeCheckingMode = "basic",
						-- indexing = true,
						-- useFileIndexingLimit = 2000,
						diagnosticMode = "openFilesOnly",
						autoImportCompletions = false,
						autoSearchPaths = true,
						useLibraryCodeForTypes = true,
						completeFunctionParens = true,
						-- stubPath = vim.fn.stdpath("data") .. "/lazy/python-type-stubs",
						extraPaths = { "." },
					},
				},
			},
		})
	end,
})

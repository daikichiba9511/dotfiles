-- local function ts_disable(_, bufnr)
--     return vim.api.nvim_buf_line_count(bufnr) > 5000
-- end

--

---@type TSConfig
require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "bash",
    "python",
    "cpp",
    "javascript",
    "typescript",
    "json",
    "toml",
    "yaml",
    "lua",
    "rust",
    -- "julia",
    "markdown",
    "markdown_inline",
    "query",
    "regex",
    "vim",
    "vimdoc",
  }, -- one of 'all', 'language', or a list of languages
  highlight = {
    enable = true, -- false will disable the whole extension
    -- disable = {}, -- list of language that will be disabled
    disable = function(lang, bufnr)
      local byte_size = vim.fn.getfsize(vim.api.nvim_buf_get_name(bufnr))
      if byte_size > 512 * 1000 then
        return true
      end

      local ok = true
      ok = pcall(function()
        vim.treesitter.get_parser(bufnr, lang):parse()
      end) and ok
      ok = pcall(function()
        vim.treesitter.query.get(lang, "highlights")
        -- vim.treesitter.query.get_query(lang, "highlights")
      end) and ok
      if not ok then
        return true
      else
        return false
      end
    end,
    additional_vim_regex_highlighting = { "markdown" },
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      -- mappings for incremental selection (visual mappings)
      -- node_incremental = "grn", -- increment to the upper named parent
      -- scope_incremental = "grc", -- increment to the upper scope (as defined in locals.scm)
      -- init_selection = 'gnn', -- maps in normal mode to init the node/scope selection
      -- node_decremental = "grm" -- decrement to the previous node
      -- init_selection = "<CR>",
      -- scope_incremental = "<CR>",
      node_incremental = "v",
      node_decremental = "V",
    },
  },
  indent = { enable = false, disable = { "python" } },
  context_commentstring = { enable = true },
  yati = { enable = true, disable = { "markdown" } },
})

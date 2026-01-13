-- Git related plugins
return {
  {
    "tpope/vim-fugitive",
    keys = {
      { "<leader>gv", "<cmd>Gvdiffsplit<cr>", desc = "Git diff (vertical)" },
      { "<leader>gh", "<cmd>Gdiffsplit<cr>", desc = "Git diff (horizontal)" },
    },
  },
  "tpope/vim-rhubarb",

  -- Adds git related signs to the gutter
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end
        -- Navigation
        map("n", "]c", function()
          if vim.wo.diff then return "]c" end
          vim.schedule(function() gs.next_hunk() end)
          return "<Ignore>"
        end, "Next hunk")
        map("n", "[c", function()
          if vim.wo.diff then return "[c" end
          vim.schedule(function() gs.prev_hunk() end)
          return "<Ignore>"
        end, "Prev hunk")
        -- Actions
        map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
        map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")
      end,
    },
  },
}

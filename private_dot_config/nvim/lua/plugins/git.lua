-- Git related plugins
return {
  {
    "tpope/vim-fugitive",
    keys = {
      { "<leader>gv", "<cmd>Gvdiffsplit<cr>", desc = "Git diff (vertical)" },
      { "<leader>gh", "<cmd>Gdiffsplit<cr>", desc = "Git diff (horizontal)" },
    },
  },
  -- Multi-file diff viewer (useful for reviewing AI-generated changes)
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview: open" },
      { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Diffview: close" },
      { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: file history" },
    },
    opts = {
      enhanced_diff_hl = true,
    },
  },

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
          if vim.wo.diff then
            return "]c"
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return "<Ignore>"
        end, "Next hunk")
        map("n", "[c", function()
          if vim.wo.diff then
            return "[c"
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return "<Ignore>"
        end, "Prev hunk")
        -- Actions
        map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
        map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")
        map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line (full)")
        map("n", "<leader>hB", gs.toggle_current_line_blame, "Toggle inline blame")
      end,
    },
  },
}

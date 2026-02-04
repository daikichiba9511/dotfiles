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

  -- GitHub PR/Issue management
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>op", "<cmd>Octo pr list<cr>", desc = "List PRs" },
      { "<leader>oP", "<cmd>Octo pr checkout<cr>", desc = "Checkout PR" },
      { "<leader>od", "<cmd>Octo pr changes<cr>", desc = "PR changes (diff)" },
      { "<leader>or", "<cmd>Octo review start<cr>", desc = "Start review" },
      { "<leader>oS", "<cmd>Octo review submit<cr>", desc = "Submit review" },
      { "<leader>oa", "<cmd>Octo comment add<cr>", desc = "Add comment" },
      { "<leader>oi", "<cmd>Octo issue list<cr>", desc = "List Issues" },
      { "<leader>oc", "<cmd>Octo pr create<cr>", desc = "Create PR" },
      { "<leader>os", "<cmd>Octo search<cr>", desc = "Search" },
    },
    opts = {
      picker = "snacks",
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

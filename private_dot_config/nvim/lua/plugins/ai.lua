-- AI assistant plugins
return {
  -- Claude Code integration (coder/claudecode.nvim)
  -- WebSocket MCP protocol for bidirectional communication with Claude Code CLI
  -- Supports both:
  -- - Internal: Launch Claude in Neovim terminal via :ClaudeCode
  -- - External: Connect to Claude Code instance running outside Neovim
  {
    "coder/claudecode.nvim",
    event = "VeryLazy", -- Load early to avoid terminal opening on first keypress
    dependencies = {
      "folke/snacks.nvim",
    },
    opts = {
      -- Server auto-start (WebSocket for external Claude Code)
      auto_start = true,
      -- Terminal settings
      terminal = {
        split_side = "right",
        split_width_percentage = 0.4,
        provider = "snacks",
        show_native_term_exit_tip = false,
      },
      -- Diff settings
      -- open_in_new_tab: workaround for buffer leak issue (#155)
      diff = {
        auto_close_on_accept = true,
        open_in_new_tab = true,
      },
    },
    keys = {
      { "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude Code" },
      { "<leader>cf", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude Code" },
      {
        "<leader>cs",
        function()
          -- Send selection to external Claude Code without opening terminal
          local file_path = vim.fn.expand("%:p")
          local start_line, end_line
          local mode = vim.fn.mode()
          if mode == "v" or mode == "V" or mode == "\22" then
            start_line = vim.fn.line("v")
            end_line = vim.fn.line(".")
            if start_line > end_line then
              start_line, end_line = end_line, start_line
            end
          else
            start_line = vim.fn.line(".")
            end_line = start_line
          end
          -- Use _broadcast_at_mention to avoid terminal opening
          local cc = require("claudecode")
          if cc.state and cc.state.server then
            cc._broadcast_at_mention(file_path, start_line, end_line)
            vim.notify(
              string.format("Sent %s:%d-%d to Claude", vim.fn.expand("%:."), start_line, end_line),
              vim.log.levels.INFO
            )
          else
            vim.notify("Claude Code not connected. Run /ide in Claude Code first.", vim.log.levels.WARN)
          end
          -- Exit visual mode
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
        end,
        desc = "Send to Claude",
        mode = { "n", "v" },
      },
      { "<leader>ca", ":ClaudeCodeAdd ", desc = "Add file to Claude" },
      { "<leader>cda", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>cdd", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    },
    cmd = {
      "ClaudeCode",
      "ClaudeCodeFocus",
      "ClaudeCodeSend",
      "ClaudeCodeAdd",
      "ClaudeCodeDiffAccept",
      "ClaudeCodeDiffDeny",
    },
  },
}

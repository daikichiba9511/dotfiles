-- AI assistant plugins
return {
  -- GitHub Copilot (Lua version)
  -- Used as backend for:
  -- - blink-cmp-copilot (completion via blink.cmp)
  -- - CopilotChat (chat interface)
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = { enabled = false }, -- Use blink.cmp instead
        panel = { enabled = false }, -- Not needed
      })
    end,
  },

  -- Copilot Chat
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    cmd = { "CopilotChat", "CopilotChatOpen", "CopilotChatToggle" },
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    -- Use default configuration
    -- Run :CopilotChatModels to see available models
  },

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

  -- Sidekick.nvim - NES (Next Edit Suggestions) + AI CLI
  {
    "folke/sidekick.nvim",
    event = "VeryLazy",
    dependencies = {
      "folke/snacks.nvim",
    },
    opts = {
      nes = {
        enabled = true,
        debounce = 50,
      },
      cli = {
        tool = "claude",
        win = { layout = "right" },
        mux = { backend = "tmux", enabled = true },
      },
    },
    keys = {
      {
        "<C-g>",
        function()
          require("sidekick").nes_jump_or_apply()
        end,
        desc = "NES: Apply or Jump",
        mode = { "n", "i" },
      },
      {
        "<C-S-g>",
        function()
          require("sidekick.nes").jump(-1)
        end,
        desc = "NES: Jump Back",
        mode = { "n", "i" },
      },
      {
        "<C-.>",
        function() require("sidekick.cli").toggle() end,
        desc = "Toggle CLI",
        mode = { "n", "t", "i", "x" },
      },
      { "<leader>aa", "<cmd>Sidekick cli toggle<cr>", desc = "Toggle AI CLI" },
      { "<leader>as", "<cmd>Sidekick cli tool<cr>", desc = "Select AI Tool" },
      { "<leader>ap", "<cmd>Sidekick cli prompt<cr>", desc = "Select Prompt" },
      { "<leader>at", "<cmd>Sidekick cli send<cr>", desc = "Send context to CLI" },
      { "<leader>af", "<cmd>Sidekick cli send file<cr>", desc = "Send file to CLI" },
      { "<leader>av", "<cmd>Sidekick cli send<cr>", desc = "Send selection to CLI", mode = "x" },
      { "<leader>ad", "<cmd>Sidekick cli detach<cr>", desc = "Detach CLI session" },
    },
  },
}

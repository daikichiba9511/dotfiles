-- Keymaps configuration

local set_keymap = vim.keymap.set

-- Buffer navigation
set_keymap("n", "<C-j>", "<cmd>bprev<cr>", { silent = true, desc = "Prev buffer" })
set_keymap("n", "<C-k>", "<cmd>bnext<cr>", { silent = true, desc = "Next buffer" })

-- Window navigation
set_keymap("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
set_keymap("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Diagnostic keymaps
set_keymap("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
set_keymap("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
set_keymap("n", "<leader>de", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
set_keymap("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- Note: Fuzzy finder keymaps are configured in init.lua using Snacks.picker

-- Copilot Chat
local function quick_chat()
  local input = vim.fn.input("Quick chat: ")
  if input ~= "" then
    require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
  end
end

set_keymap("n", "<leader>ccq", quick_chat, { noremap = true, silent = true, desc = "CopilotChat - Quick chat" })

-- Claude Code keymaps
set_keymap("n", "<leader>cc", "<cmd>ClaudeCode<cr>", { desc = "Claude Code" })
set_keymap("v", "<leader>cc", "<cmd>ClaudeCode<cr>", { desc = "Claude Code with selection" })


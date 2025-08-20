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
set_keymap("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
set_keymap("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- Telescope additional keymaps
set_keymap("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
set_keymap("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
set_keymap("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })
set_keymap("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help tags" })
set_keymap("n", "<leader>fc", "<cmd>Telescope commands<cr>", { desc = "Commands" })
set_keymap("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Recent files" })
set_keymap("n", "<leader>fk", "<cmd>Telescope keymaps<cr>", { desc = "Keymaps" })
set_keymap("n", "<leader>fm", "<cmd>Telescope marks<cr>", { desc = "Marks" })

-- Git with Telescope
set_keymap("n", "<leader>gc", "<cmd>Telescope git_commits<cr>", { desc = "Git commits" })
set_keymap("n", "<leader>gb", "<cmd>Telescope git_branches<cr>", { desc = "Git branches" })
set_keymap("n", "<leader>gs", "<cmd>Telescope git_status<cr>", { desc = "Git status" })

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


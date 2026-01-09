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

-- View image locally (via vimg + WezTerm)
set_keymap("n", "<leader>vi", function()
  local file = vim.fn.expand("%:p")
  vim.fn.system("vimg " .. vim.fn.shellescape(file))
  vim.notify("Opening: " .. file, vim.log.levels.INFO)
end, { desc = "View image locally" })

-- Copy file path with line number/range to clipboard
-- Works over SSH and tmux via OSC 52
local function copy_file_location(use_absolute)
  local mode = vim.fn.mode()
  local file = use_absolute and vim.fn.expand("%:p") or vim.fn.expand("%:.")
  local start_line, end_line

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

  local text
  if start_line == end_line then
    text = string.format("%s:%d", file, start_line)
  else
    text = string.format("%s:%d-%d", file, start_line, end_line)
  end

  vim.fn.setreg("+", text)
  vim.notify("Copied: " .. text, vim.log.levels.INFO)

  if mode ~= "n" then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  end
end

-- Relative path (for Claude Code etc.)
set_keymap({ "n", "v" }, "<leader>yl", function() copy_file_location(false) end, { desc = "Copy file:line (relative)" })
-- Absolute path
set_keymap({ "n", "v" }, "<leader>yL", function() copy_file_location(true) end, { desc = "Copy file:line (absolute)" })


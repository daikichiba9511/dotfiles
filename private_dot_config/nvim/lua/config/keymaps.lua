-- Keymaps configuration

local set_keymap = vim.keymap.set

-- Buffer navigation
set_keymap("n", "<C-j>", "<cmd>bprev<cr>", { silent = true, desc = "Prev buffer" })
set_keymap("n", "<C-k>", "<cmd>bnext<cr>", { silent = true, desc = "Next buffer" })

-- Window navigation
set_keymap("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
set_keymap("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Terminal mode window navigation (for Claude Code terminal etc.)
-- Use Ctrl+h/j/k/l directly in terminal mode
set_keymap("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Go to left window" })
set_keymap("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Go to lower window" })
set_keymap("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Go to upper window" })
set_keymap("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Go to right window" })
-- Escape to normal mode
set_keymap("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Diagnostic keymaps
set_keymap("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
set_keymap("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
set_keymap("n", "<leader>de", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
set_keymap("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- Note: Fuzzy finder keymaps are configured in init.lua using Snacks.picker

-- Claude Code keymaps are defined in plugins/ai.lua

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


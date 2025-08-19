-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
local keymap = vim.api.nvim_set_keymap

-- OSC52 clipboard setup for SSH + tmux
if os.getenv("SSH_TTY") ~= nil then
  local function copy(lines, _)
    local text = table.concat(lines, "\n")
    local base64 = vim.base64.encode(text)
    local osc52 = string.format("\x1bPtmux;\x1b\x1b]52;c;%s\x07\x1b\\", base64)
    local tty = vim.fn.system("tmux display -p '#{pane_tty}'")
    tty = tty:gsub("\n", "")
    vim.fn.system(string.format("printf '%s' > %s", osc52, tty))
  end

  local function paste()
    return {
      vim.fn.split(vim.fn.getreg('"'), "\n"),
      vim.fn.getregtype('"'),
    }
  end

  vim.g.clipboard = {
    name = "OSC52-tmux",
    copy = {
      ["+"] = copy,
      ["*"] = copy,
    },
    paste = {
      ["+"] = paste,
      ["*"] = paste,
    },
  }
end

local function set_shell_fallback()
  local shell = os.getenv("SHELL")
  if shell then
    vim.opt.shell = shell
  else
    if vim.fn.executable("fish") == 1 then
      vim.opt.shell = "fish"
    elseif vim.fn.executable("zsh") == 1 then
      vim.opt.shell = "zsh"
    else
      vim.opt.shell = "bash"
    end
  end
end

set_shell_fallback()

vim.opt.clipboard = "unnamedplus"
-- vim.opt.spelllang = { "en", "cjk" }
vim.opt.spelllang = {}
vim.opt.list = true
-- opt.listchars = { tab = "»»", space = "·" }
-- opt.listchars = { tab = "»»" }
vim.opt.listchars = "tab:»»"
vim.opt.cmdheight = 0
vim.opt.conceallevel = 0

-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.ai_cmp = false
-- vim.g.copilot_no_tab_map = true

keymap("n", "<C-x>", "<Cmd>lua require('bufdelete').bufwipeout(0, true)<CR>", { noremap = true, silent = true })

local function quick_chat()
  local input = vim.fn.input("Quick chat: ")
  if input ~= "" then
    require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
  end
end

vim.keymap.set("n", "<leader>ccq", quick_chat, { noremap = true, silent = true, desc = "CopilotChat - Quick chat" })

-- Toggleterm {{{
function _G.set_terminal_keymaps()
  local opts = { noremap = true }
  vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\><C-n>]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "jk", [[<C-\><C-n>]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
-- vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
-- vim.cmd('autocmd! TermEnter term://*toggleterm#* tnoremap <silent><c-t> <Cmd> exe v:count1 . "ToggleTerm"<CR>')

vim.api.nvim_set_keymap("n", "<leader>tt", [[<Cmd>exe v:count1 . "ToggleTerm"<CR>]], { noremap = true, silent = true })
vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
-- }}}

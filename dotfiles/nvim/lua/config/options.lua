-- Vim options configuration
-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wrap = false
vim.opt.breakindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.winblend = 0 -- transparency for floating windows
vim.opt.pumblend = 0 -- transparency for popup menus
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.completeopt = "menuone,noselect"
vim.opt.undofile = true

-- 検索結果のハイライト
vim.opt.hlsearch = true
vim.opt.incsearch = true

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

  vim.o.clipboard = "unnamedplus"

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

vim.g.clipboard = {
  name = "OSC 52",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    ["+"] = paste,
    ["*"] = paste,
  },
}

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

-- Visual settings
vim.opt.list = true
vim.opt.listchars = "tab:»»"
vim.opt.cmdheight = 0
vim.opt.conceallevel = 0
vim.opt.spelllang = {}

-- Copilot settings
vim.g.ai_cmp = false

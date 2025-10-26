-- Vim options configuration
-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wrap = false
vim.opt.breakindent = true

vim.opt.tabstop = 4 -- タブ文字の表示幅
vim.opt.shiftwidth = 4 -- インデント幅
vim.opt.softtabstop = 4 -- タブキー押下時の挿入スペース数
vim.opt.expandtab = true -- タブをスペースに変換

vim.opt.termguicolors = true
vim.opt.winblend = 0 -- transparency for floating windows
vim.opt.pumblend = 0 -- transparency for popup menus
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.completeopt = "menuone,noselect"
vim.opt.undofile = true

vim.opt.undofile = true
-- 検索結果のハイライト
vim.opt.hlsearch = true
vim.opt.incsearch = true

--- @brief Clipboardにヤンクした内容を連携
if os.getenv("SSH") ~= nil then
  local function copy(lines, _)
    local text = table.concat(lines, "\n")
    local base64 = vim.base64.encode(text)

    if os.getenv("TMUX") ~= nil then
      -- local osc52 = string.format("\x1bPtmux;\x1b\x1b]52;c;%s\x07\x1b\\", base64)
      -- local tty = vim.fn.system("tmux display -p '#{pane_tty}'")
      -- tty = tty:gsub("\n", "")

      -- tmux 経由: pane の TTY に直接エスケープシーケンスを書き込む
      local tty = vim.fn.system("tmux display -p '#{pane_tty}'"):gsub("\n", "")
      -- シェル経由のprintfは quoting 落とすことがあるので Lua のIOで書く
      local f = io.open(tty, "w")
      if f then
        -- tmux 経由のOSC52: ESC P tmux; ESC ESC ]52;c;<base64> BEL ESC \
        f:write("\x1bPtmux;\x1b\x1b]52;c;" .. base64 .. "\x07\x1b\\")
        f:close()
      end
    -- vim.fn.system(string.format("printf '%s' > %s", osc52, tty))
    else
      vim.fn.setreg("+", text)
      vim.fn.setreg("*", text)
    end
  end
  local function paste()
    return { vim.fn.split(vim.fn.getreg('"'), "\n"), vim.fn.getregtype('"') }
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

vim.opt.clipboard = "unnamedplus"

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

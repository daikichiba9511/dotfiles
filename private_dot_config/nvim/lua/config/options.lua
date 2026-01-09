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
vim.opt.ttimeoutlen = 10  -- キー入力のタイムアウトを短く
vim.opt.completeopt = "menuone,noselect"
vim.opt.undofile = true
vim.opt.listchars = "tab:>-,space:·"
vim.opt.ambiwidth = "single"

vim.opt.undofile = true
-- 検索結果のハイライト
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- 外部でファイルが変更されたら自動で再読み込み
vim.opt.autoread = true

--- @brief Clipboardにヤンクした内容を連携
-- SSH接続時にOSC 52を使用してクライアントのクリップボードに同期
if os.getenv("SSH_CONNECTION") ~= nil or os.getenv("SSH_TTY") ~= nil then
  local function copy(lines, _)
    local text = table.concat(lines, "\n")
    -- テキストの末尾に改行がある場合は保持
    if #lines > 1 or lines[1] ~= "" then
      text = text
    end

    local base64 = vim.base64.encode(text)
    local osc52_sequence

    if os.getenv("TMUX") ~= nil then
      -- tmux 経由の場合: DCS tmux; ESC ]52;c;<base64> ST
      -- DCS = ESC P, ST = ESC \
      osc52_sequence = string.format("\x1bPtmux;\x1b\x1b]52;c;%s\x07\x1b\\", base64)
    else
      -- tmux外の場合: OSC 52を直接送信
      -- OSC = ESC ], ST = BEL (or ESC \)
      osc52_sequence = string.format("\x1b]52;c;%s\x07", base64)
    end

    -- 標準出力に書き込み
    io.stdout:write(osc52_sequence)
    io.stdout:flush()
  end

  local function paste()
    return { vim.fn.split(vim.fn.getreg('"'), "\n"), vim.fn.getregtype('"') }
  end

  vim.g.clipboard = {
    name = "OSC52",
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
vim.opt.cmdheight = 0
vim.opt.conceallevel = 0
vim.opt.spelllang = {}

-- Copilot settings
vim.g.ai_cmp = false

-- LSP-based folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.lsp.foldexpr()"
vim.opt.foldlevelstart = 99 -- 起動時は全て展開
vim.opt.foldenable = true

-- Keybindings configuration for WezTerm
local wezterm = require("wezterm")
local utils = require("utils")

local M = {}

-- OS detection for modifier keys
local function get_os_type()
  local handle = io.popen("uname")
  if handle == nil then
    return "unknown"
  end
  local result = handle:read("*a")
  handle:close()

  if result:match("Darwin") then
    return "macos"
  elseif result:match("Linux") then
    return "Linux"
  else
    return "unknown"
  end
end

local os_type = get_os_type()

-- OPT単体だとmacだと入力が変わってしまうのでOPT+h/j/k/lの入力がうまく行かない
-- Reference: https://github.com/wez/wezterm/discussions/4790#discussioncomment-8166466
local mod_key_mac_or_linux = os_type == "macos" and "CTRL|CMD" or "ALT"
local mod_key2_mac_or_linux = os_type == "macos" and "CTRL|SHIFT" or "ALT|SHIFT"

---------------------------------------------------------------
--- Tmux-style keybinds
---------------------------------------------------------------
local tmux_keybinds = {
  { key = "k", mods = mod_key_mac_or_linux, action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }) },
  { key = "j", mods = mod_key_mac_or_linux, action = wezterm.action({ CloseCurrentTab = { confirm = false } }) },
  { key = "h", mods = mod_key_mac_or_linux, action = wezterm.action({ ActivateTabRelative = -1 }) },
  { key = "l", mods = mod_key_mac_or_linux, action = wezterm.action({ ActivateTabRelative = 1 }) },
  { key = "h", mods = "ALT|CTRL", action = wezterm.action({ MoveTabRelative = -1 }) },
  { key = "l", mods = "ALT|CTRL", action = wezterm.action({ MoveTabRelative = 1 }) },
  { key = "k", mods = "ALT|CTRL", action = "ActivateCopyMode" },
  { key = "j", mods = "ALT|CTRL", action = wezterm.action({ PasteFrom = "PrimarySelection" }) },
  {
    key = "-",
    mods = mod_key_mac_or_linux,
    action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }),
  },
  {
    key = "\\",
    mods = mod_key_mac_or_linux,
    action = wezterm.action({
      SplitHorizontal = { domain = "CurrentPaneDomain" },
    }),
  },
  { key = "w", mods = mod_key_mac_or_linux, action = wezterm.action({ CloseCurrentPane = { confirm = true } }) },
  { key = "h", mods = mod_key2_mac_or_linux, action = wezterm.action({ ActivatePaneDirection = "Left" }) },
  { key = "l", mods = mod_key2_mac_or_linux, action = wezterm.action({ ActivatePaneDirection = "Right" }) },
  { key = "k", mods = mod_key2_mac_or_linux, action = wezterm.action({ ActivatePaneDirection = "Up" }) },
  { key = "j", mods = mod_key2_mac_or_linux, action = wezterm.action({ ActivatePaneDirection = "Down" }) },
  { key = "h", mods = "ALT|SHIFT|CTRL", action = wezterm.action({ AdjustPaneSize = { "Left", 1 } }) },
  { key = "l", mods = "ALT|SHIFT|CTRL", action = wezterm.action({ AdjustPaneSize = { "Right", 1 } }) },
  { key = "k", mods = "ALT|SHIFT|CTRL", action = wezterm.action({ AdjustPaneSize = { "Up", 1 } }) },
  { key = "j", mods = "ALT|SHIFT|CTRL", action = wezterm.action({ AdjustPaneSize = { "Down", 1 } }) },
  { key = "Enter", mods = "ALT", action = "QuickSelect" },
  -- Create a new workspace with a random name and switch to it
  { key = "i", mods = "CTRL|SHIFT", action = wezterm.action({ SwitchToWorkspace = {} }) },
}

---------------------------------------------------------------
--- Default keybinds
---------------------------------------------------------------
local default_keybinds = {
  -- Ctrl+[ as Escape (for vim mode in Claude Code etc.)
  { key = "[", mods = "CTRL", action = wezterm.action.SendKey({ key = "Escape" }) },
  -- Claude Code split (Cmd+Shift+a on macOS, Ctrl+Shift+a on Linux)
  {
    key = "a",
    mods = os_type == "macos" and "CMD|SHIFT" or "CTRL|SHIFT",
    action = wezterm.action.SplitHorizontal({
      args = { os.getenv("SHELL"), "-l", "-c", "claude" },
    }),
  },
  -- Full Screen
  -- Ref: https://wezfurlong.org/wezterm/config/lua/keyassignment/ToggleFullScreen.html
  { key = "n", mods = "SHIFT|CTRL", action = wezterm.action.ToggleFullScreen },
  { key = "c", mods = "CTRL|SHIFT", action = wezterm.action({ CopyTo = "Clipboard" }) },
  { key = "v", mods = "CTRL|SHIFT", action = wezterm.action({ PasteFrom = "Clipboard" }) },
  { key = "Insert", mods = "SHIFT", action = wezterm.action({ PasteFrom = "PrimarySelection" }) },
  { key = "=", mods = "CTRL", action = "ResetFontSize" },
  { key = "+", mods = "CTRL", action = "IncreaseFontSize" },
  { key = "-", mods = "CTRL", action = "DecreaseFontSize" },
  { key = "x", mods = "CTRL|SHIFT", action = "ActivateCopyMode" },
  { key = "PageUp", mods = "ALT", action = wezterm.action({ ScrollByPage = -1 }) },
  { key = "PageDown", mods = "ALT", action = wezterm.action({ ScrollByPage = 1 }) },
  { key = "z", mods = "ALT", action = "ReloadConfiguration" },
  { key = "z", mods = "ALT|SHIFT", action = wezterm.action({ EmitEvent = "toggle-tmux-keybinds" }) },
  { key = "e", mods = "ALT", action = wezterm.action({ EmitEvent = "trigger-nvim-with-scrollback" }) },
  { key = "q", mods = "ALT", action = wezterm.action({ CloseCurrentPane = { confirm = false } }) },
  { key = "x", mods = "ALT", action = wezterm.action({ CloseCurrentPane = { confirm = false } }) },
  { key = "h", mods = "CMD", action = wezterm.action.HideApplication },
}

---------------------------------------------------------------
--- Key tables
---------------------------------------------------------------
local key_tables = {
  resize_pane = {
    { key = "LeftArrow", action = wezterm.action({ AdjustPaneSize = { "Left", 1 } }) },
    { key = "h", action = wezterm.action({ AdjustPaneSize = { "Left", 1 } }) },
    { key = "RightArrow", action = wezterm.action({ AdjustPaneSize = { "Right", 1 } }) },
    { key = "l", action = wezterm.action({ AdjustPaneSize = { "Right", 1 } }) },
    { key = "UpArrow", action = wezterm.action({ AdjustPaneSize = { "Up", 1 } }) },
    { key = "k", action = wezterm.action({ AdjustPaneSize = { "Up", 1 } }) },
    { key = "DownArrow", action = wezterm.action({ AdjustPaneSize = { "Down", 1 } }) },
    { key = "j", action = wezterm.action({ AdjustPaneSize = { "Down", 1 } }) },
    -- Cancel the mode by pressing escape
    { key = "Escape", action = "PopKeyTable" },
  },
  copy_mode = {
    { key = "Escape", mods = "NONE", action = wezterm.action({ CopyMode = "Close" }) },
    { key = "q", mods = "NONE", action = wezterm.action({ CopyMode = "Close" }) },
    -- move cursor
    { key = "h", mods = "NONE", action = wezterm.action({ CopyMode = "MoveLeft" }) },
    { key = "LeftArrow", mods = "NONE", action = wezterm.action({ CopyMode = "MoveLeft" }) },
    { key = "j", mods = "NONE", action = wezterm.action({ CopyMode = "MoveDown" }) },
    { key = "DownArrow", mods = "NONE", action = wezterm.action({ CopyMode = "MoveDown" }) },
    { key = "k", mods = "NONE", action = wezterm.action({ CopyMode = "MoveUp" }) },
    { key = "UpArrow", mods = "NONE", action = wezterm.action({ CopyMode = "MoveUp" }) },
    { key = "l", mods = "NONE", action = wezterm.action({ CopyMode = "MoveRight" }) },
    { key = "RightArrow", mods = "NONE", action = wezterm.action({ CopyMode = "MoveRight" }) },
    -- move word
    { key = "RightArrow", mods = "ALT", action = wezterm.action({ CopyMode = "MoveForwardWord" }) },
    { key = "f", mods = "ALT", action = wezterm.action({ CopyMode = "MoveForwardWord" }) },
    { key = "\t", mods = "NONE", action = wezterm.action({ CopyMode = "MoveForwardWord" }) },
    { key = "w", mods = "NONE", action = wezterm.action({ CopyMode = "MoveForwardWord" }) },
    { key = "LeftArrow", mods = "ALT", action = wezterm.action({ CopyMode = "MoveBackwardWord" }) },
    { key = "b", mods = "ALT", action = wezterm.action({ CopyMode = "MoveBackwardWord" }) },
    { key = "\t", mods = "SHIFT", action = wezterm.action({ CopyMode = "MoveBackwardWord" }) },
    { key = "b", mods = "NONE", action = wezterm.action({ CopyMode = "MoveBackwardWord" }) },
    {
      key = "e",
      mods = "NONE",
      action = wezterm.action({
        Multiple = {
          wezterm.action({ CopyMode = "MoveRight" }),
          wezterm.action({ CopyMode = "MoveForwardWord" }),
          wezterm.action({ CopyMode = "MoveLeft" }),
        },
      }),
    },
    -- move start/end
    { key = "0", mods = "NONE", action = wezterm.action({ CopyMode = "MoveToStartOfLine" }) },
    { key = "\n", mods = "NONE", action = wezterm.action({ CopyMode = "MoveToStartOfNextLine" }) },
    { key = "$", mods = "SHIFT", action = wezterm.action({ CopyMode = "MoveToEndOfLineContent" }) },
    { key = "$", mods = "NONE", action = wezterm.action({ CopyMode = "MoveToEndOfLineContent" }) },
    { key = "e", mods = "CTRL", action = wezterm.action({ CopyMode = "MoveToEndOfLineContent" }) },
    { key = "m", mods = "ALT", action = wezterm.action({ CopyMode = "MoveToStartOfLineContent" }) },
    { key = "^", mods = "SHIFT", action = wezterm.action({ CopyMode = "MoveToStartOfLineContent" }) },
    { key = "^", mods = "NONE", action = wezterm.action({ CopyMode = "MoveToStartOfLineContent" }) },
    { key = "a", mods = "CTRL", action = wezterm.action({ CopyMode = "MoveToStartOfLineContent" }) },
    -- select
    { key = " ", mods = "NONE", action = wezterm.action.CopyMode({ SetSelectionMode = "Cell" }) },
    { key = "v", mods = "NONE", action = wezterm.action.CopyMode({ SetSelectionMode = "Cell" }) },
    {
      key = "v",
      mods = "SHIFT",
      action = wezterm.action({
        Multiple = {
          wezterm.action({ CopyMode = "MoveToStartOfLineContent" }),
          wezterm.action({ CopyMode = "MoveToEndOfLineContent" }),
        },
      }),
    },
    -- copy
    {
      key = "y",
      mods = "NONE",
      action = wezterm.action({
        Multiple = {
          wezterm.action({ CopyTo = "ClipboardAndPrimarySelection" }),
          wezterm.action({ CopyMode = "Close" }),
        },
      }),
    },
    {
      key = "y",
      mods = "SHIFT",
      action = wezterm.action({
        Multiple = {
          wezterm.action({ CopyMode = "MoveToEndOfLineContent" }),
          wezterm.action({ CopyTo = "ClipboardAndPrimarySelection" }),
          wezterm.action({ CopyMode = "Close" }),
        },
      }),
    },
    -- scroll
    {
      key = "G",
      mods = "SHIFT",
      action = wezterm.action({
        CopyMode = "MoveToScrollbackBottom",
      }),
    },
    {
      key = "G",
      mods = "NONE",
      action = wezterm.action({
        CopyMode = "MoveToScrollbackBottom",
      }),
    },
    { key = "g", mods = "NONE", action = wezterm.action({ CopyMode = "MoveToScrollbackTop" }) },
    { key = "H", mods = "NONE", action = wezterm.action({ CopyMode = "MoveToViewportTop" }) },
    { key = "H", mods = "SHIFT", action = wezterm.action({ CopyMode = "MoveToViewportTop" }) },
    { key = "M", mods = "NONE", action = wezterm.action({ CopyMode = "MoveToViewportMiddle" }) },
    {
      key = "M",
      mods = "SHIFT",
      action = wezterm.action({
        CopyMode = "MoveToViewportMiddle",
      }),
    },
    { key = "L", mods = "NONE", action = wezterm.action({ CopyMode = "MoveToViewportBottom" }) },
    {
      key = "L",
      mods = "SHIFT",
      action = wezterm.action({
        CopyMode = "MoveToViewportBottom",
      }),
    },
    { key = "PageUp", mods = "NONE", action = wezterm.action({ CopyMode = "PageUp" }) },
    { key = "PageDown", mods = "NONE", action = wezterm.action({ CopyMode = "PageDown" }) },
    { key = "b", mods = "CTRL", action = wezterm.action({ CopyMode = "PageUp" }) },
    { key = "f", mods = "CTRL", action = wezterm.action({ CopyMode = "PageDown" }) },
    -- search
    {
      key = "/",
      mods = "NONE",
      action = wezterm.action({
        Search = { CaseSensitiveString = "" },
      }),
    },
    { key = "n", mods = "NONE", action = wezterm.action({ CopyMode = "NextMatch" }) },
    { key = "N", mods = "SHIFT", action = wezterm.action({ CopyMode = "PriorMatch" }) },
  },
  search_mode = {
    { key = "Escape", mods = "NONE", action = wezterm.action({ CopyMode = "Close" }) },
    { key = "Enter", mods = "NONE", action = "ActivateCopyMode" },
    { key = "r", mods = "CTRL", action = wezterm.action({ CopyMode = "CycleMatchType" }) },
    { key = "/", mods = "NONE", action = wezterm.action({ CopyMode = "ClearPattern" }) },
  },
}

---------------------------------------------------------------
--- Mouse bindings
---------------------------------------------------------------
local mouse_bindings = {
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "NONE",
    action = wezterm.action({ CompleteSelection = "PrimarySelection" }),
  },
  {
    event = { Up = { streak = 1, button = "Right" } },
    mods = "NONE",
    action = wezterm.action({ CompleteSelection = "Clipboard" }),
  },
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "CTRL",
    action = "OpenLinkAtMouseCursor",
  },
}

---------------------------------------------------------------
--- Public API
---------------------------------------------------------------
function M.create_keybinds()
  return utils.merge_lists(default_keybinds, tmux_keybinds)
end

function M.get_default_keybinds()
  return default_keybinds
end

function M.get_tmux_keybinds()
  return tmux_keybinds
end

function M.get_key_tables()
  return key_tables
end

function M.get_mouse_bindings()
  return mouse_bindings
end

return M

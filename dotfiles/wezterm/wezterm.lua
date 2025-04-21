-- Ref:
-- [1] https://zenn.dev/yutakatay/articles/wezterm-intro#tmux-%E3%81%AE-window%2C-pane-%E5%88%87%E3%82%8A%E6%9B%BF%E3%81%88%E3%81%AE%E3%82%88%E3%81%86%E3%81%AA%E6%93%8D%E4%BD%9C%E3%81%8C%E3%81%A7%E3%81%8D%E3%81%AA%E3%81%84
-- [2] https://github.com/yutkat/dotfiles/blob/main/.config/wezterm/wezterm.lua

local wezterm = require("wezterm")
local utils = require("utils")

local function get_os_type()
  local handle = io.popen("uname")
  if handle == nil then
    return "unknown"
  end
  local result = handle:read("*a")
  handle:close()

  -- log(string.format("DETECTED: OS Type %s", result), "INFO", true)
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
-- Reference: [1] https://github.com/wez/wezterm/discussions/4790#discussioncomment-8166466
local mod_key_mac_or_linux = os_type == "macos" and "CTRL|CMD" or "ALT"
local mod_key2_mac_or_linux = os_type == "macos" and "CTRL|SHIFT" or "ALT|SHIFT"

---------------------------------------------------------------
--- keybinds
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
    -- mods = "ALT",
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
  { key = "Enter", mods = "ALT", action = "QuickSelect" }, -- switch to the default workspace { key = "y", mods = "CTRL|SHIFT", action = wezterm.action({ SwitchToWorkspace = { name = "default" } }) },
  -- Create a newworkspace with a random name and switch to it
  { key = "i", mods = "CTRL|SHIFT", action = wezterm.action({ SwitchToWorkspace = {} }) },
}

local default_keybinds = {
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

local function create_keybinds()
  return utils.merge_lists(default_keybinds, tmux_keybinds)
end

wezterm.on("toggle-tmux-keybinds", function(window, _)
  local overrides = window:get_config_overrides() or {}
  if not overrides.window_background_opacity then
    overrides.window_background_opacity = 0.95
    overrides.keys = default_keybinds
  else
    overrides.window_background_opacity = nil
    overrides.keys = utils.merge_lists(default_keybinds, tmux_keybinds)
  end
  window:set_config_overrides(overrides)
end)

---------------------------------------------------------------
--- load local_config
---------------------------------------------------------------
-- Write settings you don't want to make public, such as ssh_domains
local os = require("os")
package.path = os.getenv("HOME") .. "/.local/share/wezterm/?.lua;" .. package.path

local function load_local_config(module)
  local m = package.searchpath(module, package.path)
  if m == nil then
    return {}
  end
  return dofile(m)
end

local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local foreground = "#313244"
  local background = "#89b4fa"
  local edge_background = "none"

  if tab.is_active then
    background = "#a6e3a1"
  end

  local edge_foreground = background
  local active_tab_tilte = tab.active_pane.title
  local title = "   " .. wezterm.truncate_right(active_tab_tilte, max_width - 1) .. "   "

  return {
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_LEFT_ARROW },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = title },
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_RIGHT_ARROW },
  }
end)

---------------------------------------------------------------
--- Config
---------------------------------------------------------------
local config = {
  font = wezterm.font_with_fallback({
    "HackGen Console NF",
    "HackGenNerd Console",
    "Cica",
  }),
  use_ime = true,
  font_size = 15,
  color_scheme = "Catppuccin Mocha (Gogh)",
  adjust_window_size_when_changing_font_size = false,
  hide_tab_bar_if_only_one_tab = false,
  use_fancy_tab_bar = true,
  tab_and_split_indices_are_zero_based = true,
  show_new_tab_button_in_tab_bar = false,
  show_close_tab_button_in_tabs = false,
  colors = { tab_bar = { inactive_tab_edge = "none" } },
  window_frame = { inactive_titlebar_bg = "none", active_titlebar_bg = "none" },
  window_background_gradient = { colors = { "#000000" } },
  send_composed_key_when_left_alt_is_pressed = true,
  send_composed_key_when_right_alt_is_pressed = false,
  macos_forward_to_ime_modifier_mask = "SHIFT|CTRL",
  window_background_opacity = 0.75,
  text_background_opacity = 1.0,
  native_macos_fullscreen_mode = true,
  macos_window_background_blur = 20,
  status_update_interval = 300000, -- 300s
  warn_about_missing_glyphs = false,
  selection_word_boundary = " \t\n{}[]()\"'`,;:",
  window_padding = {
    left = 2,
    right = 2,
    top = 0,
    bottom = 0,
  },
  tab_bar_at_bottom = false,

  -- Hide title bar
  -- Ref: [1] https://wezfurlong.org/wezterm/config/lua/config/window_decorations.html
  window_decorations = "INTEGRATED_BUTTONS|RESIZE",
  disable_default_key_bindings = true,
  visual_bell = {
    fade_in_function = "EaseIn",
    fade_in_duration_ms = 150,
    fade_out_function = "EaseOut",
    fade_out_duration_ms = 150,
  },
  -- separate <Tab> <C-i>
  enable_csi_u_key_encoding = true,
  leader = { key = "Space", mods = "CTRL|SHIFT" },
  keys = create_keybinds(),
  key_tables = {
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
            -- wezterm.action({ CopyMode = "ToggleSelectionByCell" }),
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
            -- wezterm.action({ CopyMode = "ToggleSelectionByCell" }),
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
  },
  mouse_bindings = {
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
  },
  ssh_domains = load_local_config("local").ssh_domains,
}

return config

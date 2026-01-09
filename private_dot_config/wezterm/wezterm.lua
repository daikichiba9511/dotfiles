-- WezTerm Configuration
-- Ref:
-- [1] https://zenn.dev/yutakatay/articles/wezterm-intro
-- [2] https://github.com/yutkat/dotfiles/blob/main/.config/wezterm/wezterm.lua

local wezterm = require("wezterm")
local utils = require("utils")
local keybinds = require("keybinds")
local events = require("events")
local appearance = require("appearance")

---------------------------------------------------------------
--- Setup events
---------------------------------------------------------------
events.setup()

---------------------------------------------------------------
--- Load local config
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

---------------------------------------------------------------
--- Config
---------------------------------------------------------------
local config = {
  automatically_reload_config = true,
  font = appearance.get_font(),
  use_ime = true,
  font_size = 13.0,
  color_scheme = "Catppuccin Mocha (Gogh)",
  adjust_window_size_when_changing_font_size = false,
  send_composed_key_when_left_alt_is_pressed = true,
  send_composed_key_when_right_alt_is_pressed = false,
  macos_forward_to_ime_modifier_mask = "SHIFT|CTRL",
  native_macos_fullscreen_mode = true,
  status_update_interval = 300000, -- 300s
  warn_about_missing_glyphs = false,
  selection_word_boundary = " \t\n{}[]()\"'`,;:",
  disable_default_key_bindings = true,
  -- separate <Tab> <C-i>
  enable_csi_u_key_encoding = true,
  leader = { key = "Space", mods = "CTRL|SHIFT" },
  keys = keybinds.create_keybinds(),
  key_tables = keybinds.get_key_tables(),
  mouse_bindings = keybinds.get_mouse_bindings(),
  visual_bell = appearance.get_visual_bell_config(),
  ssh_domains = load_local_config("local").ssh_domains,
}

-- Merge window config
config = utils.merge_tables(config, appearance.get_window_config())

-- Merge tab bar config
config = utils.merge_tables(config, appearance.get_tab_bar_config())

return config

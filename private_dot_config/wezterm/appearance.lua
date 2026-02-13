-- Appearance configuration for WezTerm
local wezterm = require("wezterm")

local M = {}

---------------------------------------------------------------
--- OS detection
---------------------------------------------------------------
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

---------------------------------------------------------------
--- Font configuration
---------------------------------------------------------------
function M.get_font()
  if os_type == "Linux" then
    return wezterm.font_with_fallback({
      "UDEV Gothic 35NF",
      "HackGen35Nerd Console",
    })
  else
    return wezterm.font_with_fallback({
      "UDEV Gothic 35NF",
      "HackGen Console NFJ",
      "HackGen35 Console NFJ",
      "HackGenNerd Console",
      "Cica",
    })
  end
end

---------------------------------------------------------------
--- Window appearance
---------------------------------------------------------------
function M.get_window_config()
  return {
    -- window_background_opacity = 0.60,
    -- text_background_opacity = 0.60,
    window_background_opacity = 1.0,
    text_background_opacity = 1.0,
    macos_window_background_blur = 0,
    window_background_gradient = { colors = { "#000000" } },
    window_frame = { inactive_titlebar_bg = "none", active_titlebar_bg = "none" },
    window_padding = {
      left = 2,
      right = 2,
      top = 0,
      bottom = 0,
    },
    -- Hide title bar
    -- Ref: https://wezfurlong.org/wezterm/config/lua/config/window_decorations.html
    window_decorations = "INTEGRATED_BUTTONS|RESIZE",
  }
end

---------------------------------------------------------------
--- Tab bar appearance
---------------------------------------------------------------
function M.get_tab_bar_config()
  return {
    hide_tab_bar_if_only_one_tab = false,
    use_fancy_tab_bar = true,
    tab_and_split_indices_are_zero_based = true,
    show_new_tab_button_in_tab_bar = false,
    tab_bar_at_bottom = false,
    colors = { tab_bar = { inactive_tab_edge = "none" } },
  }
end

---------------------------------------------------------------
--- Visual bell
---------------------------------------------------------------
function M.get_visual_bell_config()
  return {
    fade_in_function = "EaseIn",
    fade_in_duration_ms = 150,
    fade_out_function = "EaseOut",
    fade_out_duration_ms = 150,
  }
end

return M

-- Event handlers for WezTerm
local wezterm = require("wezterm")
local utils = require("utils")
local keybinds = require("keybinds")

local M = {}

---------------------------------------------------------------
--- SSH Remote Image Viewer
--- Usage: vimg image.png (on SSH server)
---------------------------------------------------------------
local function setup_image_viewer()
  wezterm.on("user-var-changed", function(window, pane, name, value)
    wezterm.log_info("user-var-changed: name=" .. name .. ", value=" .. tostring(value))

    if name == "view-image" then
      -- value is already decoded by WezTerm
      -- "host:/path/to/image" 形式でパース
      local host, path = value:match("^([^:]+):(.+)$")
      wezterm.log_info("view-image: host=" .. tostring(host) .. ", path=" .. tostring(path))

      if host and path then
        local ext = path:match("%.([^%.]+)$") or "png"
        local tmp = "/tmp/wez-preview." .. ext
        local cmd = string.format('scp "%s:%s" "%s" && open "%s"', host, path, tmp, tmp)
        wezterm.log_info("Running: " .. cmd)

        -- scp でコピーして open で起動 (macOS)
        wezterm.background_child_process({
          "sh",
          "-c",
          cmd,
        })
      end
    end
  end)
end

---------------------------------------------------------------
--- Toggle tmux keybinds
---------------------------------------------------------------
local function setup_toggle_tmux_keybinds()
  wezterm.on("toggle-tmux-keybinds", function(window, _)
    local overrides = window:get_config_overrides() or {}
    if not overrides.window_background_opacity then
      overrides.window_background_opacity = 0.95
      overrides.keys = keybinds.get_default_keybinds()
    else
      overrides.window_background_opacity = nil
      overrides.keys = keybinds.create_keybinds()
    end
    window:set_config_overrides(overrides)
  end)
end

---------------------------------------------------------------
--- Tab title formatting
---------------------------------------------------------------
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle

local function setup_tab_title()
  wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local foreground = "#313244"
    local background = "#89b4fa"
    local edge_background = "none"

    if tab.is_active then
      background = "#a6e3a1"
    end

    local edge_foreground = background
    local active_tab_title = tab.active_pane.title
    local title = "   " .. wezterm.truncate_right(active_tab_title, max_width - 1) .. "   "

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
end

---------------------------------------------------------------
--- Public API
---------------------------------------------------------------
function M.setup()
  setup_image_viewer()
  setup_toggle_tmux_keybinds()
  setup_tab_title()
end

return M

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
      -- value is base64 encoded, decode it first
      local decoded = wezterm.base64_decode(value)
      wezterm.log_info("view-image decoded: " .. tostring(decoded))
      -- "host:/path/to/image" 形式でパース
      local host, path = decoded:match("^([^:]+):(.+)$")
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

-- Cache for SSH hosts (pane_id -> host)
local ssh_hosts = {}

-- Extract SSH host from process info
local function extract_ssh_host_from_process(pane)
  local info = pane:get_foreground_process_info()
  if not info then
    return nil
  end

  local name = info.name or ""
  if not name:match("ssh$") then
    return nil
  end

  -- Parse ssh arguments to find host
  local argv = info.argv or {}
  for i, arg in ipairs(argv) do
    -- Skip options (start with -)
    if not arg:match("^%-") then
      -- Skip "ssh" itself
      if arg ~= "ssh" and not arg:match("ssh$") then
        -- Extract host from user@host or just host
        local host = arg:match("@([^:]+)") or arg:match("^([^@:]+)$")
        if host then
          return host
        end
      end
    end
  end
  return nil
end

-- Update SSH host cache
local function setup_ssh_host_tracking()
  wezterm.on("update-status", function(window, pane)
    local pane_id = pane:pane_id()
    local host = extract_ssh_host_from_process(pane)
    ssh_hosts[pane_id] = host
  end)
end

local function setup_tab_title()
  wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    -- Rose Pine (main) colors
    local foreground = "#191724" -- base
    local background = "#6e6a86" -- muted (inactive)
    local edge_background = "none"

    if tab.is_active then
      background = "#c4a7e7" -- iris (active)
    elseif hover then
      background = "#908caa" -- subtle (hover)
    end

    local edge_foreground = background
    local pane = tab.active_pane
    local ssh_host = ssh_hosts[pane.pane_id]
    local active_tab_title = pane.title

    -- Prepend SSH host if connected
    if ssh_host then
      active_tab_title = "[" .. ssh_host .. "] " .. active_tab_title
    end

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
--- Toggle transparency
---------------------------------------------------------------
local function setup_toggle_transparency()
  wezterm.on("toggle-transparency", function(window, _)
    local overrides = window:get_config_overrides() or {}
    if overrides.window_background_opacity then
      overrides.window_background_opacity = nil
      overrides.text_background_opacity = nil
    else
      overrides.window_background_opacity = 0.8
      overrides.text_background_opacity = 0.8
    end
    window:set_config_overrides(overrides)
  end)
end

---------------------------------------------------------------
--- Public API
---------------------------------------------------------------
function M.setup()
  setup_image_viewer()
  setup_toggle_tmux_keybinds()
  setup_toggle_transparency()
  setup_ssh_host_tracking()
  setup_tab_title()
end

return M

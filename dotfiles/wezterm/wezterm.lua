local wezterm = require 'wezterm';
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local title = wezterm.truncate_right(utils.basename(tab.active_pane.foreground_process_name), max_width)
    if title == "" then
        title = wezterm.truncate_right(
        utils.basename(utils.convert_home_dir(tab.active_pane.current_working_dir)),
            max_width
        )
    end
    return {
        { Text = tab.tab_index + 1 .. ":" .. title },
    }
end)

return {
    font = wezterm.font("Hack Nerd Font Mono", {weight="Bold", stretch="Normal", style="Normal"}), -- /home/d-chiba/.local/share/fonts/NerdFonts/Hack Bold Nerd Font Complete Mono.ttf, FontConfig
    use_ime = true,
    font_size = 12.0,
    color_scheme = "nord",
    hide_tar_bar_if_only_one_tab = true,
    adjust_window_size_when_changing_font_size = false,
    window_background_opacity = 0.9,
    text_background_opacity = 0.8,
}



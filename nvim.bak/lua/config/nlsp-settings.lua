require("nlspsettings").setup({
    config_home = vim.fn.stdpath("config") .. "/config/nlsp-settings",
    local_settings_dir = ".nlsp-settings",
    local_settings_root_markers = { ".git" },
    -- append default schemas
    jsonls_append_default_schemas = true,
    nvim_notify = {
        enable = true,
        timeout = 5000,
    },
})

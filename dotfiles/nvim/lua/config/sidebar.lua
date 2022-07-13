require("sidebar-nvim").setup({
    disable_default_keybindings = 0,
    open = false,
    side = "left",
    sections = { 'todos', 'files', 'git',},  -- TODO: diagnositicsはbuild-inのlspから取ってくるからcocから移行したら設定する
    files = {
        icon = '',
        show_hidden = false,
        ignored_paths = {"%.git$"},
    },
    todos = {
        icon = '',
        ignored_paths = {'~'}, -- ignore certain paths, this will prevent huge folders like $HOME to hog Neovim with TODO searching
        initially_closed = false, -- whether the groups should be initially closed on start. You can manually open/close groups later.
    },
    symbols = {
        icon = 'ƒ',
    },
    buffers = {
        icon = "",
        ignored_buffers = {}, -- ignore buffers by regex
        sorting = "id", -- alternatively set it to "name" to sort by buffer name instead of buf id
        show_numbers = true, -- whether to also show the buffer numbers
        ignore_not_loaded = false, -- whether to ignore not loaded buffers
        ignore_terminal = true, -- whether to show terminal buffers in the list
    },

})

vim.api.nvim_set_keymap("n", "gs", "<Cmd>SidebarNvimToggle<CR>", { noremap = true, silent = true })

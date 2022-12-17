-- WIP
-- Reference
-- 1. https://zenn.dev/link/comments/d9547142490c77

function img_preview()
    -- 空のbufferを作る
    local buf = vim.api.nvim_create_buf(false, true)
    -- 作ったbufferを使ってfloating windowを作る
    local config = { relative = "win", height = 30, width = 40, col = 44, row = 14 }
    vim.api.nvim_open_win(buf, true, config)
    vim.api.nvim_exec("set winblend=100", false)
    vim.api.nvim_exec(":terminal img2sixel assets/neovim-tokyonight-20221124.png", true)
end

vim.api.nvim_create_user_command("ImgPreview", img_preview, {})

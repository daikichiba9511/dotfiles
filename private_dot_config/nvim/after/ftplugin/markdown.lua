-- カーソル位置に「log」スニペットを展開する関数
vim.api.nvim_create_user_command("InsertLog", function()
  local ls = require("luasnip")
  ls.snip_expand(ls.get_snippets("markdown")[1]) -- 先頭のスニペット（例では "log"）
end, {})

vim.keymap.set("n", "<leader>idl", "<cmd>InsertLog<CR>", { desc = "Insert Markdown Log snippet" })

vim.opt.tabstop = 2 -- タブ文字の表示幅
vim.opt.shiftwidth = 2 -- インデント幅
vim.opt.softtabstop = 2 -- タブキー押下時の挿入スペース数
vim.opt.expandtab = true -- タブをスペースに変換

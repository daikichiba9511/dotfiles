-- カーソル位置に「log」スニペットを展開する関数
vim.api.nvim_create_user_command("InsertLog", function()
  local ls = require("luasnip")
  ls.snip_expand(ls.get_snippets("markdown")[1]) -- 先頭のスニペット（例では "log"）
end, {})

vim.keymap.set("n", "<leader>idl", "<cmd>InsertLog<CR>", { desc = "Insert Markdown Log snippet" })

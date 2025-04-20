local function lazy_has(plugin_name)
  return require("lazy.core.config").spec.plugins[plugin_name] ~= nil
end

--- Reference
--- 1. https://zenn.dev/vim_jp/articles/041300c0f9cc50
local commit_bufnr = vim.api.nvim_get_current_buf()
if lazy_has("CopilotChat.nvim") then
  vim.keymap.set("n", "<leader>c", "<cmd>CopilotChatCommit<CR>", { buffer = commit_bufnr })
  vim.schedule(function()
    require("CopilotChat")
    vim.cmd.CopilotChatCommit()
  end)
  vim.api.nvim_create_autocmd("QuitPre", { command = "CopilotChatClose" })
  vim.keymap.set("ca", "qq", "execute 'CopilotChatClose' <bar> wqa")
end

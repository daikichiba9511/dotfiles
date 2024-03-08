local opt = vim.opt
local keymap = vim.api.nvim_set_keymap

opt.list = true
opt.listchars = { tab = "»»", space = "·" }

keymap("n", "<C-x>", "<Cmd>lua require('bufdelete').bufwipeout(0, true)<CR>", { noremap = true, silent = true })

local function quick_chat()
  local input = vim.fn.input("Quick chat: ")
  if input ~= "" then
    require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
  end
end

vim.keymap.set("n", "<leader>ccq", quick_chat, { noremap = true, silent = true, desc = "CopilotChat - Quick chat" })

return {}

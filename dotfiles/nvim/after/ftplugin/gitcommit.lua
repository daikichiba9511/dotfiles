local function lazy_has(plugin_name)
  return require("lazy.core.config").spec.plugins[plugin_name] ~= nil
end

--- Reference
--- 1. https://zenn.dev/vim_jp/articles/041300c0f9cc50
local commit_bufnr = vim.api.nvim_get_current_buf()
local commit_win_id = vim.fn.win_getid()
local commit_win = vim.api.nvim_get_current_win()

function FixCopilotChat()
  -- Replace the pattern (#file:<filename>-context?) with (<filename>)
  -- If the pattern is not found, do nothing
  local success = pcall(vim.cmd, [[%s/(#file:\(\w\+.\w\+\)-context\?)/(\1)]])
  if not success then
    print("Pattern not found")
  end
  vim.cmd("normal! G")
end

if lazy_has("CopilotChat.nvim") then
  vim.keymap.set("n", "<leader>c", "<cmd>CopilotChatCommit<CR>", { buffer = commit_bufnr })
  vim.schedule(function()
    ---@type CopilotChat
    local chat = require("CopilotChat")
    local commit_prompt = chat.config.prompts.Commit.prompt
    chat.ask("> #git:staged\n\n" .. commit_prompt, {
      callback = function(response, _)
        -- code fenceでgitcommitで囲まれた部分を取得する
        -- Extract content from the code fence
        local lines = vim.split(response.content, "\n")

        -- make commt message
        local in_gitcommit_block = false
        local commit_message = {}
        for _, line in ipairs(lines) do
          if line:match("^```gitcommit") then
            in_gitcommit_block = true
          elseif in_gitcommit_block then
            if line:match("^```") then
              in_gitcommit_block = false
            else
              table.insert(commit_message, line)
            end
          end
        end

        -- If no gitcommit block found, try to use the whole response
        if #commit_message == 0 then
          -- Skip code fences that aren't gitcommit blocks
          vim.notify("No gitcommit block found, using whole response", vim.log.levels.WARN)
        end

        if #commit_message > 0 then
          vim.api.nvim_buf_set_lines(commit_bufnr, 0, 0, false, commit_message)
        end
      end,
    })
  end)
  vim.api.nvim_create_autocmd("QuitPre", { command = "CopilotChatClose" })
  vim.keymap.set("ca", "qq", "execute 'CopilotChatClose' <bar> wqa")
end

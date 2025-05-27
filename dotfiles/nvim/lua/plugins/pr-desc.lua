---@diagnostic disable: undefined-global
local chat = require("CopilotChat") -- CopilotChat.nvim v3 以降を想定
local select = require("CopilotChat.select") -- CopilotChat.nvim v3 以降を想定

-- git diff を取り込み、scratch バッファを開く
local function open_branch_diff(base, new)
  local diff = vim.fn.system({ "git", "diff", ("%s..%s"):format(base, new) })
  if vim.v.shell_error ~= 0 then
    vim.notify("git diff failed", vim.log.levels.ERROR)
    return nil, nil
  end

  vim.cmd("enew") -- 新規バッファを開く
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "diff"
  vim.api.nvim_buf_set_name(buf, ("diff:%s..%s"):format(base, new))
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(diff, "\n"))
  return buf, diff
end

-- CopilotChat に PR 説明を依頼
local function ask_copilot(diff, base, new)
  local prompt = ([[以下は **%s..%s** の差分です。  
これを要約し、Pull Request の説明文を日本語で作成してください。
概要・詳細に分けて書き、概要はポイントを箇条書きで、詳細はポイントを箇条書きで変更理由とそれによってどういう影響があるかなど意図を説明してください。
]]):format(base, new)
  chat.ask(prompt, {
    selection = function(source)
      return select.buffer(source)
    end,
    title = ("PR %s→%s"):format(base, new),
  })
end

-- :PRDiff コマンド本体
vim.api.nvim_create_user_command("PRDiff", function(opts)
  -- 第 1 引数: base、第 2 引数: new。省略すると現在ブランチを new、main を base に。
  local base = opts.fargs[1] or "main"
  local new = opts.fargs[2] or vim.fn.systemlist({ "git", "symbolic-ref", "--short", "HEAD" })[1]

  local buf, diff = open_branch_diff(base, new)
  if diff and diff ~= "" then
    ask_copilot(diff, base, new)
    -- vim.bo[buf].modifiable = false -- 誤編集防止（必要なら外す）
  else
    vim.notify(("No diff between %s and %s"):format(base, new), vim.log.levels.INFO)
  end
end, {
  nargs = "*",
  complete = function(arglead) -- ブランチ名補完
    local branches = vim.fn.systemlist({ "git", "branch", "--format=%(refname:short)" })
    return vim.tbl_filter(function(b)
      return b:match("^" .. arglead)
    end, branches)
  end,
  desc = "Generate PR description with CopilotChat from git diff",
})

return {}

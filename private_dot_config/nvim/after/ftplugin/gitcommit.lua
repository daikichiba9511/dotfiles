--- Reference
--- 1. https://zenn.dev/vim_jp/articles/041300c0f9cc50
local commit_bufnr = vim.api.nvim_get_current_buf()
local commit_win_id = vim.fn.win_getid()

-- Auto-generate commit message with Claude CLI

-- 再実行防止フラグ
if vim.b.commit_message_generated then
  return
end
vim.b.commit_message_generated = true

local use_claude_cli = vim.fn.executable('claude') == 1

if use_claude_cli then
  vim.schedule(function()
    local diff_stat = vim.fn.system('git diff --cached --stat')
    local diff_content = vim.fn.system('git diff --cached')

    if diff_content == '' or diff_content:match('^fatal:') then
      return
    end

    -- 最近のコミット履歴を確認して言語を判定
    local recent_commits = vim.fn.system('git log -5 --pretty=%s 2>/dev/null')
    local use_japanese = recent_commits:match('[ぁ-ん]') or recent_commits:match('[ァ-ヴ]') or recent_commits:match('[一-龯]')

    -- .git/COMMIT_EDITMSGのパス
    local git_dir = vim.fn.system('git rev-parse --git-dir'):gsub('\n', '')
    local commit_file = git_dir .. '/COMMIT_EDITMSG'

    -- Claude Codeへのプロンプト（git diff --cachedはClaude Codeに実行させる）
    local claude_prompt
    if use_japanese then
      claude_prompt = string.format(
        'git diff --cached を実行して差分を確認し、Conventional Commits形式のコミットメッセージを生成して %s の先頭に書き込んでください。' ..
        'ルール: 1行目は <type>(<scope>): <subject>（50文字以内）、2行目は空行、3行目以降は変更の詳細説明。' ..
        'typeはfeat/fix/docs/style/refactor/perf/test/build/ci/chore/revertのいずれか。日本語で記述。',
        commit_file
      )
    else
      claude_prompt = string.format(
        'Run git diff --cached to see the changes, then generate a Conventional Commits format commit message and write it to the beginning of %s. ' ..
        'Rules: Line 1 is <type>(<scope>): <subject> (50 chars max), line 2 is blank, line 3+ is detailed explanation. ' ..
        'Type is one of feat/fix/docs/style/refactor/perf/test/build/ci/chore/revert. Write in English.',
        commit_file
      )
    end

    -- 右側に新しいウィンドウを作成
    vim.cmd('rightbelow vnew')
    local term_win = vim.api.nvim_get_current_win()

    -- プロンプトを一時ファイルに保存してcatでパイプ
    local tmpfile = vim.fn.tempname()
    vim.fn.writefile({ claude_prompt }, tmpfile)

    -- catでプロンプトをstdinに渡してClaude Codeを起動
    local shell_cmd = string.format(
      "cat %s | claude --allowedTools Bash,Read,Write,Edit; rm %s",
      tmpfile, tmpfile
    )

    vim.fn.termopen(shell_cmd, {
      on_exit = function()
        vim.schedule(function()
          -- コミットバッファをリロード
          if vim.api.nvim_buf_is_valid(commit_bufnr) then
            vim.api.nvim_buf_call(commit_bufnr, function()
              vim.cmd('edit!')
            end)
          end
          -- ターミナルウィンドウを閉じる
          if vim.api.nvim_win_is_valid(term_win) then
            vim.api.nvim_win_close(term_win, true)
          end
          -- コミットバッファに戻る
          if vim.api.nvim_win_is_valid(commit_win_id) then
            vim.fn.win_gotoid(commit_win_id)
          end
        end)
      end,
    })

    -- ターミナルモードに入る
    vim.cmd('startinsert')
  end)
end

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

-- Auto-generate commit message on gitcommit buffer open
-- Try Avante first, fallback to CopilotChat if Avante has issues
local use_avante = lazy_has("avante.nvim")

-- Check if Avante is properly built
if use_avante then
  local ok = pcall(function()
    require('avante.api')
  end)
  if not ok then
    use_avante = false
    vim.notify("Avante not properly built, using CopilotChat instead", vim.log.levels.WARN)
  end
end

if use_avante then
  vim.schedule(function()
    -- staged差分を取得
    local diff_stat = vim.fn.system('git diff --cached --stat')
    local diff_content = vim.fn.system('git diff --cached')

    if diff_content == '' or diff_content:match('^fatal:') then
      return
    end

    -- 最近のコミット履歴を確認して言語を判定
    local recent_commits = vim.fn.system('git log -5 --pretty=%s 2>/dev/null')
    local use_japanese = recent_commits:match('[ぁ-ん]') or recent_commits:match('[ァ-ヴ]') or recent_commits:match('[一-龯]')

    -- Conventional Commits形式のプロンプトを作成
    local custom_prompt
    if use_japanese then
      custom_prompt = string.format([[以下のgit差分を分析して、Conventional Commits形式のコミットメッセージを生成してください。

ルール:
- 1行目: <type>(<scope>): <subject> （50文字以内、命令形）
- 2行目: 空行
- 3行目以降: 変更の詳細な説明（何を変更したか、なぜ変更したか）
- type: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert のいずれか
- 日本語で記述
- コードブロック不要、そのままコミットメッセージとして使える形式で出力

例:
feat(nvim): コミットメッセージ自動生成機能を追加

Avanteを使用してgit差分からConventional Commits形式の
コミットメッセージを自動生成する機能を実装。
日本語と英語の両方に対応し、最近のコミット履歴から
言語を自動判定する。

変更サマリー:
%s

差分:
%s]], diff_stat, diff_content)
    else
      custom_prompt = string.format([[Analyze the following git diff and generate a commit message in Conventional Commits format.

Rules:
- Line 1: <type>(<scope>): <subject> (50 characters or less, imperative mood)
- Line 2: blank line
- Line 3+: detailed explanation (what changed and why)
- type: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
- Write in English
- Output as plain text (no code blocks), ready to use as commit message

Example:
feat(nvim): add auto commit message generation

Implement automatic commit message generation using Avante
that analyzes git diff and creates Conventional Commits format.
Supports both English and Japanese with automatic language
detection based on recent commit history.

Change summary:
%s

Diff:
%s]], diff_stat, diff_content)
    end

    vim.notify("Generating commit message with Avante...", vim.log.levels.INFO)

    -- コミット生成時のみ高速なモデルに一時変更
    local Config = require('avante.config')
    local original_model = Config.providers.copilot.model
    Config.providers.copilot.model = "gpt-4o-mini"

    -- AvanteInputSubmittedイベント後にポーリングで結果を待つ
    local check_count = 0
    local max_checks = 40

    local function check_and_insert()
      check_count = check_count + 1

      vim.schedule(function()
        local sidebar = require('avante').get()
        if not sidebar or not sidebar.containers or not sidebar.containers.result then
          if check_count < max_checks then
            vim.defer_fn(check_and_insert, 500)
          end
          return
        end

        local result_bufnr = sidebar.containers.result.bufnr
        if not vim.api.nvim_buf_is_valid(result_bufnr) then
          if check_count < max_checks then
            vim.defer_fn(check_and_insert, 500)
          end
          return
        end

        -- バッファの内容を取得（最後の50行のみ - 最新のレスポンスが含まれているはず）
        local total_lines = vim.api.nvim_buf_line_count(result_bufnr)
        local start_line = math.max(0, total_lines - 50)
        local lines = vim.api.nvim_buf_get_lines(result_bufnr, start_line, -1, false)

        -- 最後から順に、Conventional Commitsフォーマットの開始行を探す
        local commit_start_idx = nil
        for i = #lines, 1, -1 do
          local line = lines[i]:gsub('^%s+', ''):gsub('%s+$', '')
          -- Conventional Commits形式: type(scope): subject または type: subject
          if line:match('^%w+%(') or (line:match('^%w+:') and not line:match('^#+')) then
            -- コードブロックマーカーを除外
            if not line:match('^```') and #line > 10 and #line < 100 then
              commit_start_idx = i
              break
            end
          end
        end

        if not commit_start_idx then
          if check_count < max_checks then
            vim.defer_fn(check_and_insert, 500)
          end
          return
        end

        -- コミットメッセージの開始位置から最後まで取得
        local commit_lines = {}
        for i = commit_start_idx, #lines do
          local line = lines[i]
          -- コードブロックマーカーやマークダウンヘッダーを除外
          if not line:match('^```') and not line:match('^##') then
            table.insert(commit_lines, line)
          end
        end

        -- 最後の空行を削除
        while #commit_lines > 0 and commit_lines[#commit_lines]:match('^%s*$') do
          table.remove(commit_lines)
        end

        if #commit_lines == 0 then
          if check_count < max_checks then
            vim.defer_fn(check_and_insert, 500)
          end
          return
        end

        -- 最初の行がConventional Commits形式かチェック
        local first_line = commit_lines[1]:gsub('^%s+', ''):gsub('%s+$', '')
        local is_conventional = first_line:match('^%w+%(') or first_line:match('^%w+:')

        if is_conventional then
          -- コミットメッセージを挿入
          if vim.api.nvim_buf_is_valid(commit_bufnr) then
            -- バッファのmodifiableを一時的に有効化
            local was_modifiable = vim.api.nvim_get_option_value('modifiable', {buf = commit_bufnr})
            vim.api.nvim_set_option_value('modifiable', true, {buf = commit_bufnr})

            -- 複数行を挿入
            vim.api.nvim_buf_set_lines(commit_bufnr, 0, 0, false, commit_lines)

            -- modifiableを元に戻す
            vim.api.nvim_set_option_value('modifiable', was_modifiable, {buf = commit_bufnr})

            vim.notify("Commit message inserted!", vim.log.levels.INFO)

            -- モデルを元に戻す
            Config.providers.copilot.model = original_model

            -- Avanteを閉じる
            vim.defer_fn(function()
              pcall(function()
                require('avante').close_sidebar()
              end)
            end, 1000)
          end
        elseif check_count < max_checks then
          vim.defer_fn(check_and_insert, 500)
        else
          -- タイムアウト時もモデルを元に戻す
          Config.providers.copilot.model = original_model
          vim.notify("Timeout waiting for Avante response.", vim.log.levels.WARN)
        end
      end)
    end

    -- Avanteを使ってコミットメッセージを生成（新しいチャットとして開始）
    require('avante.api').ask({
      question = custom_prompt,
      new_chat = true, -- 過去の履歴を含めない
    })

    -- 4秒後にチェック開始
    vim.defer_fn(check_and_insert, 4000)
  end)
elseif lazy_has("CopilotChat.nvim") then
  -- Auto-generate with CopilotChat
  vim.schedule(function()
    local chat = require("CopilotChat")

    local diff_stat = vim.fn.system('git diff --cached --stat')
    local diff_content = vim.fn.system('git diff --cached')

    if diff_content == '' or diff_content:match('^fatal:') then
      return
    end

    local recent_commits = vim.fn.system('git log -5 --pretty=%s 2>/dev/null')
    local use_japanese = recent_commits:match('[ぁ-ん]') or recent_commits:match('[ァ-ヴ]') or recent_commits:match('[一-龯]')

    local custom_prompt
    if use_japanese then
      custom_prompt = string.format([[以下のgit差分を分析して、Conventional Commits形式のコミットメッセージを1行で生成してください。

ルール:
- フォーマット: <type>(<scope>): <subject>
- type: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert のいずれか
- subject: 50文字以内、命令形で記述
- 日本語で記述
- コミットメッセージの1行目のみを出力（説明不要、コードブロック不要）

例: feat(nvim): コミットメッセージ自動生成機能を追加

変更サマリー:
%s

差分:
%s]], diff_stat, diff_content:sub(1, 4000))
    else
      custom_prompt = string.format([[Analyze the following git diff and generate a commit message in Conventional Commits format.

Rules:
- Format: <type>(<scope>): <subject>
- type: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
- subject: 50 characters or less, imperative mood
- Write in English
- Output only the first line (no explanations, no code blocks)

Example: feat(nvim): add auto commit message generation

Change summary:
%s

Diff:
%s]], diff_stat, diff_content:sub(1, 4000))
    end

    vim.notify("Generating commit message with CopilotChat...", vim.log.levels.INFO)

    chat.ask(custom_prompt, {
      callback = function(response, _)
        local message = response.content or response
        if type(message) == 'string' then
          message = message:gsub('^```.-\n', ''):gsub('\n```$', ''):gsub('^%s+', ''):gsub('%s+$', '')
          local first_line = message:match('^[^\n]+') or message

          if first_line ~= '' and not first_line:match('^%s*$') then
            vim.api.nvim_buf_set_lines(commit_bufnr, 0, 0, false, { first_line })
            vim.notify("Commit message inserted!", vim.log.levels.INFO)
          end
        end
      end,
    })
  end)
end

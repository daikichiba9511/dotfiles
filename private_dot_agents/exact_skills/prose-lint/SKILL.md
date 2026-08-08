---
name: prose-lint
description: "Use for read-only linting and feedback on an existing Japanese draft's readability, structure, consistency, and naturalness, with line-specific severities and suggested fixes. Do not use when the user asks for direct rewriting or deep argument restructuring."
allowed-tools: Read, Glob, Grep, Bash(npx markdownlint:*), Bash(markdownlint:*)
---

# Prose Lint (日本語)

日本語の文章を読みやすさ・構造・自然さの観点でレビューする。
チェック項目と報告フォーマットは `references/lint-spec.md` を読む。

## Usage

`/prose-lint <file_path_or_glob>`

- `/prose-lint docs/blog.md`
- `/prose-lint docs/zettel/outputs/*.md`
- `/prose-lint` - 引数なしなら対象ファイルを聞く

## 手順

### Step 1: フォーマットlint（Markdownの場合のみ）

対象が `.md` ファイルなら:

1. `npx markdownlint` または `markdownlint` が使えるか確認する
2. 使える場合は実行し、結果を報告する
3. 使えない場合はスキップして Step 2 へ進む

### Step 2: 機械的チェック

`references/lint-spec.md` のチェック一覧に従い、機械的に検出できる項目を行番号付きで報告する。

### Step 3: 文章レビュー

`references/lint-spec.md` のレビュー観点に従い、文脈理解が必要な構造問題と文章品質の問題を `error` / `warning` 付きで報告する。

### Step 4: 報告

`references/lint-spec.md` の報告テンプレートに従い、サマリー、詳細、文章レビューの順で出す。

## ルール

- 指摘には必ず具体的な修正提案を添える
- 文体の統一性は文書全体で判断する（「です/ます」vs「だ/である」の混在など）
- 原文の意図を変えない修正を提案する
- 修正は提案のみで、ファイルは直接編集しない

$ARGUMENTS

---
name: zettel-init
description: "Initialize Zettelkasten directory structure for research and documentation projects. Use when the user wants to set up a note-taking system, organize research memos, create a documentation workspace, or start a new Zettelkasten. Also trigger when the user mentions concept notes, atomic notes, research memo management, or says things like 'メモ管理を始めたい', '調査用のノートを整理したい', 'Zettelkasten を使いたい'."
allowed-tools: Read, Write, Bash(ls:*), Bash(mkdir:*), Glob
---

# Zettelkasten Init

プロジェクト内に Zettelkasten 用のディレクトリ構造と index.md を作成する。

## Usage

`/zettel-init [base_dir]`

- `/zettel-init` - デフォルトで `docs/zettel/` に作成
- `/zettel-init research` - `research/zettel/` に作成

## 手順

1. ベースディレクトリを確認（デフォルト: `docs/zettel/`）
2. 既にディレクトリが存在する場合は警告し、ユーザーに確認
3. 以下の構造を作成:

```
{base_dir}/
  ├── index.md          # メモ一覧 + リンクマップ
  ├── structs/          # 構造メモ
  └── outputs/          # 生成された長文
```

4. `index.md` を初期テンプレートで作成

## index.md テンプレート

```markdown
---
title: Zettelkasten Index
created: {today}
updated: {today}
description: メモ一覧とリンクマップ
---

# Zettelkasten Index

## メモ一覧

| ID | タイトル | タグ | 作成日 |
|----|---------|------|--------|

## リンクマップ

(メモ間の関連をここに記録)
```

## ルール

- 既存ファイルを上書きしない（確認なしに）
- 日付は実行日を使用
- 作成完了後、ディレクトリ構造を表示して報告

$ARGUMENTS

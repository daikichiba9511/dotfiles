---
name: zettel-init
description: "Initialize Zettelkasten directory structure for research and documentation projects. Use when the user wants to set up a note-taking system, organize research memos, create a documentation workspace, or start a new Zettelkasten. Also trigger when the user mentions concept notes, atomic notes, research memo management, or says things like 'メモ管理を始めたい', '調査用のノートを整理したい', 'Zettelkasten を使いたい'. Also use when creating a new research theme directory ('新しいテーマを作りたい', 'テーマディレクトリを作って')."
allowed-tools: Read, Write, Bash(ls:*), Bash(mkdir:*), Glob
---

# Zettelkasten Init

プロジェクト内に Zettelkasten 用のディレクトリ構造と `index.md` を作成する。
テンプレートや構造例は `references/templates.md` を読む。

## Usage

`/zettel-init [base_dir|theme:<theme_name>]`

- `/zettel-init` - デフォルトで `docs/zettel/` に作成
- `/zettel-init research` - `research/zettel/` に作成
- `/zettel-init theme:cv_inference_speedup` - 既存 zettel 内に新テーマディレクトリを作成

## 手順

### Step 1: ベースディレクトリ初期化

1. ベースディレクトリを確認する（デフォルト: `docs/zettel/`）
2. 既に存在する場合は警告し、ユーザーに確認する
3. `references/templates.md` の構造に従ってディレクトリを作成する
4. `references/templates.md` のテンプレートで `index.md` を作成する

### Step 2: テーマディレクトリ作成 (`theme:` 指定時)

1. 既存の zettel ベースディレクトリを `**/zettel/index.md` で検出する
2. テーマ名を英語スネークケースで正規化する
3. `references/templates.md` のテーマテンプレートに従ってディレクトリと `README.md` を作成する
4. ベースの `index.md` のテーマ一覧に追記する

## ルール

- 既存ファイルを確認なしに上書きしない
- 日付は実行日を使う
- テーマ名は英語スネークケースにする
- テーマ作成時はベースの `index.md` も更新する
- 作成完了後、ディレクトリ構造を表示して報告する

$ARGUMENTS

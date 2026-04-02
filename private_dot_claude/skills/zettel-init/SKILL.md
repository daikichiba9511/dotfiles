---
name: zettel-init
description: "Initialize Zettelkasten directory structure for research and documentation projects. Use when the user wants to set up a note-taking system, organize research memos, create a documentation workspace, or start a new Zettelkasten. Also trigger when the user mentions concept notes, atomic notes, research memo management, or says things like 'メモ管理を始めたい', '調査用のノートを整理したい', 'Zettelkasten を使いたい'. Also use when creating a new research theme directory ('新しいテーマを作りたい', 'テーマディレクトリを作って')."
allowed-tools: Read, Write, Bash(ls:*), Bash(mkdir:*), Glob
---

# Zettelkasten Init

プロジェクト内に Zettelkasten 用のディレクトリ構造と index.md を作成する。
テーマディレクトリの新規作成にも対応する。

## Usage

`/zettel-init [base_dir|theme:<theme_name>]`

- `/zettel-init` - デフォルトで `docs/zettel/` に作成
- `/zettel-init research` - `research/zettel/` に作成
- `/zettel-init theme:cv_inference_speedup` - 既存zettel内に新テーマディレクトリを作成

## 手順

### ベースディレクトリ初期化

1. ベースディレクトリを確認（デフォルト: `docs/zettel/`）
2. 既にディレクトリが存在する場合は警告し、ユーザーに確認
3. 以下の構造を作成:

```
{base_dir}/
  ├── index.md          # テーマ一覧 + メモ一覧 + リンクマップ
  ├── structs/          # 構造メモ
  └── outputs/          # 生成された長文
```

4. `index.md` を初期テンプレートで作成

### テーマディレクトリ作成 (`theme:` 指定時)

1. 既存のzettelベースディレクトリを検出（`**/zettel/index.md` を検索）
2. テーマ名を英語スネークケースで正規化
3. テーマディレクトリと README.md を作成:

```
{base_dir}/{theme_name}/
  └── README.md         # テーマのメタ情報・メモ一覧
```

4. ベースの `index.md` のテーマ一覧に追記

## ディレクトリ構造の全体像

```
{base_dir}/
  ├── index.md                     # 全体のインデックス
  ├── cv_inference_speedup/        # テーマディレクトリ
  │   ├── README.md                # テーマのメタ情報・所属メモ一覧
  │   ├── zk-20260401-001_tensorrt_optimization.md
  │   └── zk-20260401-002_onnx_runtime_tips.md
  ├── attention_mechanism/
  │   ├── README.md
  │   └── zk-20260402-001_flash_attention_v2.md
  ├── structs/                     # 構造メモ
  └── outputs/                     # 生成された長文
```

**設計意図**: テーマ単位でディレクトリを渡すだけで、関連メモ一式をコンテキストとして提供できる。

## index.md テンプレート

```markdown
---
title: Zettelkasten Index
created: {today}
updated: {today}
description: テーマ一覧・メモ一覧・リンクマップ
---

# Zettelkasten Index

## テーマ一覧

| テーマ | 説明 | メモ数 | 作成日 |
|--------|------|--------|--------|

## メモ一覧

| ID | タイトル | テーマ | タグ | 作成日 |
|----|---------|--------|------|--------|

## リンクマップ

(メモ間の関連をここに記録)
```

## テーマ README.md テンプレート

```markdown
---
theme: {theme_name}
title: {テーマの日本語タイトル}
created: {today}
updated: {today}
description: テーマの1行説明
status: active
tags: [tag1, tag2]
---

# {テーマの日本語タイトル}

## 概要

(このテーマで何を調べているか、目的・背景)

## メモ一覧

| ID | タイトル | 概要 | 作成日 |
|----|---------|------|--------|

## 関連テーマ

- (他テーマへのリンク)

## 今後の調査予定

- [ ] (調べたいこと)
```

## ルール

- 既存ファイルを上書きしない（確認なしに）
- 日付は実行日を使用
- テーマ名は英語スネークケース（例: `cv_inference_speedup`）
- テーマ作成時はベースの `index.md` も更新する
- 作成完了後、ディレクトリ構造を表示して報告

$ARGUMENTS

---
name: zettel-compose
description: "Compose a long-form document from Zettel memos. Specify output format, direction, and target memos. Generates a structure note and draft with a list of source memos used. Use when the user wants to write a blog post, report, or documentation from research notes, or says things like 'メモからブログ記事を書いて', 'レポートにまとめたい', 'メモを元にドキュメントを作成して', '調査結果を文章にして'. Trigger whenever the user wants to synthesize multiple memos into a cohesive document."
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Zettel Compose

指定した Zettel メモ群から構造メモを作成し、長文ドラフトを生成する。

## Usage

`/zettel-compose <instructions>`

ユーザーは以下を指定する:

- **使用するメモ**: ID指定、タグ指定、または「全部」
- **出力フォーマット**: ブログ記事、技術レポート、実験レポート、ドキュメント等
- **方向性・目的**: 誰向けか、何を伝えたいか、トーン等

### 例

- `/zettel-compose transformer関連のメモからブログ記事を書いて。初学者向けに`
- `/zettel-compose zk-20260331-001, 002, 005 を使って実験レポート`
- `/zettel-compose attentionタグのメモ全部で技術ドキュメント。チーム内共有用`

## Zettelディレクトリの検出

1. プロジェクト内で `**/zettel/index.md` を Glob で検索
2. 1件見つかればそのディレクトリをベースとして使用
3. 複数見つかればユーザーに選択を求める
4. 見つからなければ `/zettel-init` の実行を提案

## 手順

### Step 1: メモの収集

1. 指定されたメモ（ID、タグ、キーワード）をベースディレクトリから収集
2. 各メモの内容を読み込み
3. 収集したメモ一覧をユーザーに提示し、過不足がないか確認

### Step 2: 構造メモの作成

1. 収集したメモ群の関係性を分析
2. 長文のアウトライン（構造メモ）を作成
3. `structs/` に保存。ファイル名: `{YYYYMMDD}-{slug}.md`
4. アウトラインをユーザーに提示し、構成の確認を取る

#### 構造メモのフォーマット

```markdown
---
title: 構造メモタイトル
created: YYYY-MM-DD
source_zettels: [zk-XXXXXXXX-NNN, ...]
output_format: ブログ記事
target_audience: 初学者
---

## アウトライン

1. セクション名
   - 使用メモ: zk-XXXXXXXX-NNN
   - ポイント: ...
2. セクション名
   ...
```

### Step 3: ドラフト生成

1. 構造メモに基づいてドラフトを生成
2. `outputs/` に保存。ファイル名: `{YYYYMMDD}-{slug}.md`

### Step 4: 報告

以下を表示:
- 生成したドラフトのパス
- 使用メモ一覧（ID + タイトル）
- 使用しなかったメモがあればその一覧（ブラッシュアップ時の参考用）

## ドラフトのフッター

生成されたドラフトの末尾に、再生成時の参考情報を付記する。ブラッシュアップ時に同じメモ群+修正指示で再生成しやすくするため:

```markdown
---
<!-- zettel-compose metadata -->
<!-- source_zettels: zk-XXXXXXXX-NNN, zk-XXXXXXXX-NNN, ... -->
<!-- structure_note: structs/YYYYMMDD-slug.md -->
<!-- generated: YYYY-MM-DD -->
<!-- instructions: (ユーザーが指定した方向性) -->
```

## ルール

- ドラフト生成前に必ずアウトラインの確認を取る
- メモの内容を歪めない（メモにない情報を捏造しない）
- メモ間の矛盾がある場合は明示する（訂正履歴も考慮）
- 使用メモ一覧は必ず報告する（再生成・ブラッシュアップに必要）

$ARGUMENTS

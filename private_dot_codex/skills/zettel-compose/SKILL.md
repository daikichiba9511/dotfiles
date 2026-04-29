---
name: zettel-compose
description: "Compose documents or assist writing from Zettel memos. Two modes: (1) generate mode — produce full document (technical docs, reports), (2) assist mode — analyze memos, map relationships, identify gaps, suggest outlines for user to write (blog posts, essays). Use when the user says 'ドキュメントを生成して', 'レポートにまとめて', 'ブログ書きたい', 'メモを元に書きたい', 'どのメモが使えるか整理して', '執筆の準備をしたい'. Trigger whenever the user wants to create or prepare writing from memos."
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Zettel Compose

Zettel メモ群から文書を生成する、または執筆の補助を行う。
構造メモや出力のフォーマットを使うときは `references/structure-note-format.md` を読む。

## モード判定

- `generate`: 「生成して」「作って」「まとめて」「ドキュメントにして」のように完成原稿を求めているとき
- `assist`: 「書きたい」「準備したい」「整理して」「どのメモが使える？」のように執筆補助を求めているとき
- ブログやエッセイなどユーザー自身の声が重要なら `assist` を優先する
- 判断が曖昧なら確認する

## Usage

`/zettel-compose <instructions>`

- `/zettel-compose theme:cv_inference_speedup でドキュメントを生成して` → generate
- `/zettel-compose transformer関連のメモでブログ書きたい。初学者向けに` → assist
- `/zettel-compose zk-20260331-001, 002, 005 で実験レポートを作って` → generate
- `/zettel-compose theme:attention_mechanism で記事の準備をしたい` → assist

## Zettelディレクトリの検出

1. プロジェクト内で `**/zettel/index.md` を Glob で検索
2. 1件見つかればそのディレクトリをベースとして使用
3. 複数見つかればユーザーに選択を求める
4. 見つからなければ `/zettel-init` の実行を提案

## 手順

### Step 1: メモの収集と選別

1. 指定されたメモ ID、タグ、キーワード、`theme:` を元に候補を集める
2. `theme:` 指定時はそのテーマ配下を優先する
3. 各メモの frontmatter と本文を読み、`主要素材` `補助素材` `関連するが不要` に分類する
4. 分類結果をユーザーに見せる

### Step 2: 構造分析

以下を整理する。

- 依存関係: 前提知識の流れ
- 補完関係: 別角度や関連概念
- 矛盾・対立: 訂正履歴も含めた不一致
- ギャップ: 既存メモで足りない論点

### Step 3: 構造メモの作成

`references/structure-note-format.md` のテンプレートに従い、`structs/{YYYYMMDD}-{slug}.md` を作る。

### Step 4: モード別処理

`generate` のとき:

1. 構造メモのアウトライン案を提示し、確認を取る
2. 確認後に全文ドラフトを生成する
3. `references/structure-note-format.md` のフッター形式に従って `outputs/{YYYYMMDD}-{slug}.md` に保存する
4. 生成したドラフト、使用メモ、未使用メモを報告する

`assist` のとき:

1. 全文ドラフトは生成しない
2. 素材マップ、関係性、ギャップ、アウトライン案、注意点だけを報告する
3. ユーザーが自分の言葉で書けるように見通しを渡す

## ルール

- メモの内容を歪めない（メモにない情報を捏造しない）
- メモ間の矛盾がある場合は明示する（訂正履歴も考慮）
- アウトラインは「案」として提示し、ユーザーの判断を尊重する
- ギャップは具体的に指摘する（「足りない」ではなく「Xについてのメモがない」）
- generate モードでもドラフト生成前に必ずアウトラインの確認を取る
- 素材メモの内容は変更しない

$ARGUMENTS

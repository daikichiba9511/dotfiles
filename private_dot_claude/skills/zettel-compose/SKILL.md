---
name: zettel-compose
description: "Compose documents or assist writing from Zettel memos. Two modes: (1) generate mode — produce full document (technical docs, reports), (2) assist mode — analyze memos, map relationships, identify gaps, suggest outlines for user to write (blog posts, essays). Use when the user says 'ドキュメントを生成して', 'レポートにまとめて', 'ブログ書きたい', 'メモを元に書きたい', 'どのメモが使えるか整理して', '執筆の準備をしたい'. Trigger whenever the user wants to create or prepare writing from memos."
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Zettel Compose

Zettel メモ群から文書を生成する、または執筆の補助を行う。
2つのモードがあり、用途に応じて使い分ける。

## モード

| モード | 用途 | 出力 |
|--------|------|------|
| **generate** | ドキュメント・レポート等を生成してほしい | 構造メモ + 全文ドラフト |
| **assist** | ブログ等を自分で書くための補助 | 構造メモ（素材分類・関係性・ギャップ・アウトライン案） |

## モード判定

以下の手がかりから判定する。判断がつかない場合はユーザーに確認する。

**generate になるケース:**
- 「生成して」「作って」「まとめて」「ドキュメントにして」
- 技術ドキュメント、実験レポートなど定型的な成果物
- ユーザー自身の文体・主張が求められない出力

**assist になるケース:**
- 「書きたい」「準備したい」「整理して」「どのメモが使える？」
- ブログ記事、エッセイなどユーザーの声で書くもの
- 構造や素材の整理を求めている

## Usage

`/zettel-compose <instructions>`

### 例

- `/zettel-compose theme:cv_inference_speedup でドキュメントを生成して` → generate
- `/zettel-compose transformer関連のメモでブログ書きたい。初学者向けに` → assist
- `/zettel-compose zk-20260331-001, 002, 005 で実験レポートを作って` → generate
- `/zettel-compose theme:attention_mechanism で記事の準備をしたい` → assist

## Zettelディレクトリの検出

1. プロジェクト内で `**/zettel/index.md` を Glob で検索
2. 1件見つかればそのディレクトリをベースとして使用
3. 複数見つかればユーザーに選択を求める
4. 見つからなければ `/zettel-init` の実行を提案

## 共通手順

### Step 1: メモの収集と選別

1. 指定されたメモ（ID、タグ、キーワード、テーマ名）をベースディレクトリの全テーマディレクトリから収集
2. `theme:` 指定時はそのテーマディレクトリ内の全メモを対象とする
3. 各メモの frontmatter と内容を読み込み
4. 執筆目的に対する各メモの関連度を判定し、以下に分類:
   - **主要素材**: 記事の核になるメモ
   - **補助素材**: 背景説明や補足に使えるメモ
   - **関連するが不要**: テーマに近いが今回の方向性に合わないメモ
5. 分類結果をユーザーに提示

### Step 2: 構造分析

メモ間の関係性を分析し、以下を明らかにする:

1. **依存関係**: どのメモがどのメモの前提知識になっているか
2. **補完関係**: 対になるメモ、異なる角度から同じ概念を扱うメモ
3. **矛盾・対立**: メモ間で主張が異なる箇所（訂正履歴も考慮）
4. **ギャップ**: 既存メモでカバーできていない領域、論理の飛躍箇所

### Step 3: 構造メモの作成

分析結果を構造メモとして `structs/` に保存する。

ファイル名: `{YYYYMMDD}-{slug}.md`

```markdown
---
title: 構造メモタイトル
created: YYYY-MM-DD
mode: generate | assist
source_zettels: [zk-XXXXXXXX-NNN, ...]
output_format: ブログ記事
target_audience: 初学者
---

## 素材メモ

### 主要素材
- zk-XXXXXXXX-NNN (タイトル) — この記事での役割の1行説明
- ...

### 補助素材
- zk-XXXXXXXX-NNN (タイトル) — 使いどころ
- ...

## メモ間の関係性

(依存・補完・対立の関係を図示または箇条書き)

## アウトライン案

1. セクション名
   - 使用メモ: zk-XXXXXXXX-NNN
   - ポイント: このセクションで伝えること
2. セクション名
   ...

## ギャップ・要追加調査

- (既存メモで足りていない領域)
- (読者が疑問に思いそうだがメモがない箇所)

## 執筆時の注意点

- (メモ間の矛盾箇所とどちらを採用すべきか)
- (前提知識の説明が必要な箇所)
```

**ここまではモード共通。** Step 4 以降がモードで分岐する。

---

## generate モード

### Step 4: アウトライン確認

構造メモのアウトライン案をユーザーに提示し、構成の確認を取る。

### Step 5: ドラフト生成

1. 構造メモに基づいて全文ドラフトを生成
2. `outputs/` に保存。ファイル名: `{YYYYMMDD}-{slug}.md`

### Step 6: 報告

以下を提示:
- 生成したドラフトのパス
- 使用メモ一覧（ID + タイトル）
- 使用しなかったメモがあればその一覧

### ドラフトのフッター

```markdown
---
<!-- zettel-compose metadata -->
<!-- mode: generate -->
<!-- source_zettels: zk-XXXXXXXX-NNN, zk-XXXXXXXX-NNN, ... -->
<!-- structure_note: structs/YYYYMMDD-slug.md -->
<!-- generated: YYYY-MM-DD -->
<!-- instructions: (ユーザーが指定した方向性) -->
```

---

## assist モード

### Step 4: 報告

構造メモを作成した上で、以下を提示する:

- **素材マップ**: どのメモが何に使えるか（分類付き一覧）
- **関係性の要約**: メモ同士がどう繋がっているか
- **ギャップ**: 書くにあたって足りていない情報・調査が必要な箇所
- **アウトライン案**: セクション構成の提案（あくまで案）
- **注意点**: 矛盾箇所、前提知識の要否など

**assist モードでは全文ドラフトを生成しない。**
ユーザーが自分の言葉で書くための材料と見通しを提供する。

---

## ルール

- メモの内容を歪めない（メモにない情報を捏造しない）
- メモ間の矛盾がある場合は明示する（訂正履歴も考慮）
- アウトラインは「案」として提示し、ユーザーの判断を尊重する
- ギャップは具体的に指摘する（「足りない」ではなく「Xについてのメモがない」）
- generate モードでもドラフト生成前に必ずアウトラインの確認を取る
- 素材メモの内容は変更しない

$ARGUMENTS

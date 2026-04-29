---
name: zettel-link
description: "Scan existing Zettel memos and propose links between related concepts. Use when the user wants to find connections between notes, organize memo relationships, discover related concepts, or says things like 'メモの関連を整理して', 'リンクを追加したい', '関連するメモを探して', 'メモ間のつながりを見つけて'. Trigger whenever the user asks about relationships or connections between their research notes."
allowed-tools: Read, Edit, Glob, Grep
---

# Zettel Link

既存の Zettel メモをスキャンし、関連するメモ間のリンクを提案する。

## Usage

`/zettel-link [scope]`

- `/zettel-link` - 全テーマ横断でスキャンしてリンク提案
- `/zettel-link zk-20260331-001` - 特定メモの関連を検索
- `/zettel-link transformer` - タグやキーワードで絞り込み
- `/zettel-link theme:cv_inference_speedup` - テーマ内のメモに絞ってリンク提案

## Zettelディレクトリの検出

1. プロジェクト内で `**/zettel/index.md` を Glob で検索
2. 1件見つかればそのディレクトリをベースとして使用
3. 複数見つかればユーザーに選択を求める
4. 見つからなければ `/zettel-init` の実行を提案

## 手順

1. ベースディレクトリ内の全テーマディレクトリからメモを収集（`structs/`, `outputs/` は除外）
2. scope が指定されていれば対象を絞り込み（テーマ名での絞り込みも可）
3. 以下の観点で関連を分析:
   - **タグの共通性**: 同じタグを持つメモ
   - **内容の関連性**: 概念的に関連するメモ
   - **参照の共通性**: 同じ情報源を参照しているメモ
   - **補完関係**: 一方が他方の前提知識、発展、反例になるメモ
4. リンク提案をユーザーに提示

## スケーラビリティ

メモが30件以上ある場合、全件の本文を読み込むとコンテキストを圧迫する。以下の2段階アプローチを取る:

1. **軽量スキャン**: 全メモの frontmatter（タイトル、タグ、リンク、サマリー）のみを読み込み、タグ共通性と既存リンクから候補を絞る
2. **詳細分析**: 有望な候補ペアに絞って本文を読み、内容の関連性と補完関係を判定

## 提案フォーマット

各提案を以下の形式で提示する。関連度の高い順に並べ、上位10件に絞る:

```
### 提案 1
- **メモA**: zk-20260331-001 (Attention機構の計算量)
- **メモB**: zk-20260331-003 (Transformerのスケーリング則)
- **関係**: メモAの計算量がメモBのスケーリングのボトルネック
- **推奨**: 双方向リンク
```

## ユーザー確認後の処理

ユーザーが承認した提案について:

1. 各メモの frontmatter `links` フィールドにリンク先IDを追加
2. 各メモの `updated` フィールドを更新
3. `index.md` のリンクマップセクションを更新
4. 変更内容をサマリー表示

## ルール

- リンクの書き込みは必ずユーザーの承認後に行う
- 提案は根拠とともに提示（なぜ関連があるのか）
- 既に存在するリンクは重複提案しない

$ARGUMENTS

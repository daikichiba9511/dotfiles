---
name: zettel-create
description: "Create an atomic Zettel (concept memo) from a research theme or provided content. Supports two modes: (A) give a theme and Claude researches and creates a memo, (B) give content and Claude formats it into a Zettel. Use when the user wants to create a research note, document a concept, save investigation results, or says things like '調べてメモにして', 'この内容をメモにまとめて', 'ノートを作って', '概念メモを追加'. Trigger during any research or investigation workflow where the user is capturing knowledge."
allowed-tools: Read, Write, Edit, Glob, Grep, WebSearch, WebFetch, Agent
---

# Zettel Create

調査テーマまたは調査結果から、1概念=1メモのアトミックな Zettel を作成する。

## Usage

`/zettel-create <theme_or_content>`

- `/zettel-create Attention機構の計算量について調べて` - モードA: 調査→メモ生成
- `/zettel-create 以下の内容をメモにして: ...` - モードB: フォーマットしてメモ生成

## モード判定

- 引数が調査テーマ（短文、疑問形、「調べて」等）→ **モードA**: 調査してからメモ作成
- 引数が具体的な内容やテキスト → **モードB**: そのままフォーマットしてメモ作成
- 判断がつかない場合はユーザーに確認

## 手順

### 共通: Zettelディレクトリの検出

1. プロジェクト内で `**/zettel/index.md` を Glob で検索
2. 1件見つかればそのディレクトリをベースとして使用
3. 複数見つかればユーザーに選択を求める
4. 見つからなければ `/zettel-init` の実行を提案

### 共通: ID 採番

1. ベースディレクトリ内の既存メモ (`zk-*.md`) をスキャン
2. 今日の日付で `zk-YYYYMMDD-NNN` 形式のIDを採番（NNN は今日の連番、001始まり）

### モード A: 調査→メモ生成

1. テーマに基づいて調査（WebSearch, WebFetch, コード読解など）
2. 調査結果を1概念にまとめる
3. 概念が複数ある場合はユーザーに提示し、分割するか確認
4. メモを作成

### モード B: フォーマット→メモ生成

1. 渡された内容を Zettel フォーマットに整形
2. タイトル、タグ、サマリーを提案
3. メモを作成

### 共通: メモ作成

1. Zettel ファイルをベースディレクトリに作成
2. 既存メモとの関連を簡易チェックし、リンク候補を提示
3. `index.md` のメモ一覧に追加
4. 作成したメモの内容を表示して報告

## Zettel フォーマット

```markdown
---
id: zk-YYYYMMDD-NNN
title: メモタイトル
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [tag1, tag2]
links: []
summary: 1行の概要
---

## 内容

(本文)

## 参考

- 情報源のURL、論文、コード等
```

## Immutable ルール

作成済みメモの内容は削除・書き換えしない。間違いを消すと同じ間違いを繰り返す原因になるため、訂正は追記で行う:

```markdown
## 訂正 (YYYY-MM-DD)

> 訂正内容と理由
> 参照: zk-XXXXXXXX-NNN
```

訂正時は `updated` フィールドを更新する。

## ルール

- 1メモ = 1概念（アトミック）。概念が大きすぎる場合は分割を提案
- タグは既存メモで使われているタグを優先的に再利用（表記ゆれ防止）
- メモ作成後、必ず index.md を更新

$ARGUMENTS

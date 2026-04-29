---
name: zettel-create
description: "Create an atomic Zettel (concept memo) from a research theme or provided content. Supports two modes: (A) give a theme and Codex researches and creates a memo, (B) give content and Codex formats it into a Zettel. Use when the user wants to create a research note, document a concept, save investigation results, or says things like '調べてメモにして', 'この内容をメモにまとめて', 'ノートを作って', '概念メモを追加'. Trigger during any research or investigation workflow where the user is capturing knowledge."
allowed-tools: Read, Write, Edit, Glob, Grep, WebSearch, WebFetch, Agent
---

# Zettel Create

調査テーマまたは調査結果から、1概念=1メモのアトミックな Zettel を作成する。
メモ本文や訂正追記を作るときは `references/zettel-format.md` を読む。

## Usage

`/zettel-create [theme_dir:] <theme_or_content>`

- `/zettel-create Attention機構の計算量について調べて` - モードA: 調査→メモ生成
- `/zettel-create 以下の内容をメモにして: ...` - モードB: フォーマットしてメモ生成
- `/zettel-create theme:cv_inference_speedup TensorRTの最適化手法` - テーマ指定でメモ作成

## モード判定

- 引数が調査テーマ（短文、疑問形、「調べて」等）ならモード A
- 引数が具体的な内容やテキストならモード B
- 判断がつかない場合はユーザーに確認する

## 手順

### Step 1: Zettelディレクトリの検出

1. プロジェクト内で `**/zettel/index.md` を Glob で検索
2. 1件見つかればそのディレクトリをベースとして使用
3. 複数見つかればユーザーに選択を求める
4. 見つからなければ `/zettel-init` の実行を提案

### Step 2: テーマディレクトリの決定

1. `theme:` が明示されていればそのテーマディレクトリを使用
2. 未指定なら既存テーマの `README.md` を読み、関連度が高い候補を提案する
3. 適切なテーマがなければ新テーマ作成を提案し、承認後に `/zettel-init theme:{name}` 相当の処理を行う

### Step 3: ID 採番とファイル名

1. ベースディレクトリ内の全テーマディレクトリから既存メモ (`zk-*.md`) をスキャンする
2. 今日の日付で `zk-YYYYMMDD-NNN` 形式のIDを採番する
3. IDはベースディレクトリ全体でユニークにする
4. ファイル名は `zk-YYYYMMDD-NNN_slug.md` とし、スラッグは英語スネークケースにする

### Step 4: モード別処理

モード A:

1. テーマに基づいて調査する
2. 調査結果を 1 概念にまとめる
3. 複数概念になりそうなら分割を提案する

モード B:

1. 渡された内容を Zettel 形式に整える
2. タイトル、タグ、サマリーを提案する

### Step 5: メモ作成と更新

1. Zettel ファイルをテーマディレクトリ内に作成する
2. 作成時は `references/zettel-format.md` のテンプレートに従う
3. 既存メモとの関連を簡易チェックし、リンク候補を提示する
4. テーマの `README.md` のメモ一覧に追加する
5. ベースの `index.md` のメモ一覧に追加する
6. 作成したメモの内容を表示して報告する

## ルール

- 1メモ = 1概念（アトミック）。概念が大きすぎる場合は分割を提案
- タグは既存メモで使われているタグを優先的に再利用する
- メモ作成後、テーマの `README.md` とベースの `index.md` の両方を更新する
- テーマディレクトリが存在しない場合は勝手に作らず提案する
- 作成済みメモの本文は削除・書き換えせず、訂正は `references/zettel-format.md` の追記形式を使う

$ARGUMENTS

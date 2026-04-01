---
name: prose-lint
description: "Review Japanese prose for readability, structure, and naturalness. Runs mechanical lint checks and stylistic review with severity levels (error/warning/info). Use when the user wants to check writing quality, review a draft, improve readability, or says things like '文章をチェックして', 'この文章おかしくない？', '読みやすさを確認して', 'レビューして', '文章のlintして'. Trigger for any Japanese text review, proofreading, or writing quality assessment."
allowed-tools: Read, Glob, Grep, Bash(npx markdownlint:*), Bash(markdownlint:*)
---

# Prose Lint (日本語)

日本語の文章を読みやすさ・構造・自然さの観点でレビューする。

## Usage

`/prose-lint <file_path_or_glob>`

- `/prose-lint docs/blog.md`
- `/prose-lint docs/zettel/outputs/*.md`
- `/prose-lint` - 引数なしなら対象ファイルを聞く

## 手順

### Step 1: フォーマットlint（Markdownの場合のみ）

対象が `.md` ファイルの場合:

1. markdownlint が使えるか確認（`npx markdownlint` or `markdownlint`）
2. 使える場合は実行し、結果を報告
3. 使えない場合はスキップして Step 2 へ

### Step 2: 機械的チェック

文字数カウントや正規表現で検出可能なチェック。行番号付きで報告する。

#### error

| ID | チェック | 基準 |
|----|---------|------|
| E01 | 見出し階層の飛び | h2→h4 のように階層が飛んでいる |

#### warning

| ID | チェック | 基準 |
|----|---------|------|
| W01 | 文が長い | 1文が80字を超える |
| W02 | セクションが長い | 1セクション（見出し間）が400字を超える |
| W03 | 受動態の連続 | 3文以上連続で受動態 |
| W04 | 同一表現の反復 | 近接する文で同じ表現が3回以上 |
| W05 | パラグラフが長い | 1段落が4文を超える |
| W06 | 同義語の混在 | 同じ概念に複数の表記（例: 「行う」と「実施する」の混在） |

#### info

| ID | チェック | 基準 |
|----|---------|------|
| I01 | 文末の単調さ | 「です/ます」「だ/である」が5文以上連続 |
| I02 | 漢字率が高い | 段落の漢字率が50%を超える（硬い印象） |
| I03 | 読点が少ない | 40字以上の文に読点がない |
| I04 | 接続詞の多用 | 「しかし」「また」「さらに」等が連続 |

### Step 3: 文章レビュー

文脈理解が必要な観点をレビューする。以下の項目は severity を付けて報告する（E = error, W = warning）:

#### 構造の問題（error相当）

- **E02 パラグラフのトピック混在**: 1パラグラフに明らかに複数トピックが混在している
- **E03 指示語の曖昧参照**: 「これ」「それ」の指す先が文脈から特定できない

#### 文章の質（warning相当）

- **論理構成**: セクション間の流れに飛躍がないか
- **語彙の不自然さ**: 文脈に対して堅すぎ/くだけすぎ、文体の不統一
- **トピックセンテンス**: 各パラグラフの冒頭でそのパラグラフの要旨が示されているか
- **読者への配慮**: 前提知識の説明不足、専門用語の未説明
- **冗長性**: 同じ情報の繰り返し、削除しても意味が変わらない文

### Step 4: 報告

以下の形式で報告:

```
## Lint結果サマリー

- error: N件
- warning: N件
- info: N件

## 詳細

### error

**E01** L5: 見出し階層の飛び
> h2 の直下に h4 が出現しています。
> 提案: h3 に変更するか、間に h3 セクションを追加

**E02** L15-22: パラグラフのトピック混在
> 「Attentionの計算量」と「Transformerの歴史」が1段落に混在しています。
> 提案: L18以降を別パラグラフに分割

### warning

**W01** L8: 文が長い (92字)
> 「Self-Attentionは...計算される。」
> 提案: 「...で表現される。これにより...計算される。」に分割

...

## 文章レビュー

### 論理構成
- ...

### 語彙・文体
- ...
```

## ルール

- 指摘には必ず具体的な修正提案を添える
- 文体の統一性は文書全体で判断する（「です/ます」vs「だ/である」の混在等）
- 原文の意図を変えない修正を提案する
- 修正は提案のみ。ファイルを直接編集しない

$ARGUMENTS

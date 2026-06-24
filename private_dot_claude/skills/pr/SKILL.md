---
name: pr
description: gh pr create でPRを作成する。Google CL best practice に従い、レビュアーの負担を最小化する簡潔なPR。長い説明は書かない。
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git push:*), Bash(git checkout:*), Bash(git branch:*), Bash(gh pr:*), Bash(gh api:*)
---

PRを作成する。レビュアーが最速で判断できることだけを目指す。

## 手順

1. 現在の状態を把握する

!git status --short
!git log --oneline main..HEAD
!git diff --stat main...HEAD

2. 未コミットの変更があれば、先に `/commit` を案内して終了する
3. コミットが0件ならエラーで終了する
4. コミット履歴とdiffからPRのtitleとbodyを書く（後述のフォーマットに従う）
5. リモートにpushしていなければ `git push -u origin HEAD` する
6. `gh pr create` でPRを作成する
7. PR URLを報告する

## PRフォーマット

Google CL best practice に従う。レビュアーが読む量を最小にする。

### title

- 命令形の動詞で始める（Add, Fix, Remove, Refactor, Update）
- 50文字以内（日本語の場合は25文字程度）
- コミットメッセージが日本語なら日本語、英語なら英語
- conventional commits の type prefix は付けない（gh が見づらくなる）

### body

```
## What
[1-3行。何を変えたか。コードを読めばわかることは書かない]

## Why
[1-3行。なぜこの変更が必要か。Issue番号があればここに書く]
```

以下はオプショナル。該当する場合だけ追加する。

```
## Note
[レビュアーに判断を仰ぎたい点、既知の制約、意図的に選んだトレードオフ。1-2行]
```

これ以外のセクションは書かない。

## 絶対に書かないもの

- Test plan セクション（テストはコードで書く。PRに手順を書いても誰も実行しない）
- 変更ファイルの一覧（diffを見ればわかる）
- 実装の詳細説明（コードを読めばわかる）
- 箇条書きの羅列（3項目を超えたら書きすぎ）
- 「Generated with Claude Code」のようなフッター
- emoji

## 判断基準

- bodyの合計が6行を超えたら削る
- レビュアーが「これ読まなくてもdiff見ればわかるな」と思う情報は全部消す
- 迷ったら短い方を選ぶ

## 追加指示

$ARGUMENTS
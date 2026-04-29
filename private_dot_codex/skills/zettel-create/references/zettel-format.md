# Zettel Format

`zettel-create` がメモ本文や訂正追記を作るときのテンプレート。

## File Naming

- 形式: `zk-YYYYMMDD-NNN_slug.md`
- 例: `zk-20260402-001_tensorrt_optimization.md`
- `slug` は英語スネークケースで、検索時に内容が推測できる短い語にする

## Memo Template

```markdown
---
id: zk-YYYYMMDD-NNN
title: メモタイトル
theme: テーマディレクトリ名
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

## Correction Entry

作成済みメモの内容は削除・書き換えせず、訂正は追記で行う。

```markdown
## 訂正 (YYYY-MM-DD)

> 訂正内容と理由
> 参照: zk-XXXXXXXX-NNN
```

訂正時は `updated` フィールドも更新する。

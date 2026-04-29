# Zettelkasten Init Templates

`zettel-init` がベース構造や初期ファイルを書くときのテンプレート。

## Base Directory Layout

```text
{base_dir}/
  ├── index.md          # テーマ一覧 + メモ一覧 + リンクマップ
  ├── structs/          # 構造メモ
  └── outputs/          # 生成された長文
```

## Full Example Layout

```text
{base_dir}/
  ├── index.md
  ├── cv_inference_speedup/
  │   ├── README.md
  │   ├── zk-20260401-001_tensorrt_optimization.md
  │   └── zk-20260401-002_onnx_runtime_tips.md
  ├── attention_mechanism/
  │   ├── README.md
  │   └── zk-20260402-001_flash_attention_v2.md
  ├── structs/
  └── outputs/
```

設計意図: テーマ単位でディレクトリを渡すだけで、関連メモ一式をコンテキストとして提供できる。

## index.md Template

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

## Theme README.md Template

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

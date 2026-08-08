# Structure Note Format

`zettel-compose` が構造メモや生成ドラフトを作るときに使うテンプレート集。

## Structure Note Template

保存先: `structs/{YYYYMMDD}-{slug}.md`

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
   使用メモ: zk-XXXXXXXX-NNN
   ポイント: このセクションで伝えること
2. セクション名
   使用メモ: zk-XXXXXXXX-NNN
   ポイント: このセクションで伝えること

## ギャップ・要追加調査

- (既存メモで足りていない領域)
- (読者が疑問に思いそうだがメモがない箇所)

## 執筆時の注意点

- (メモ間の矛盾箇所とどちらを採用すべきか)
- (前提知識の説明が必要な箇所)
```

## Draft Footer

`generate` モードで `outputs/` に保存するドラフト末尾に付ける。

```markdown
---
<!-- zettel-compose metadata -->
<!-- mode: generate -->
<!-- source_zettels: zk-XXXXXXXX-NNN, zk-XXXXXXXX-NNN, ... -->
<!-- structure_note: structs/YYYYMMDD-slug.md -->
<!-- generated: YYYY-MM-DD -->
<!-- instructions: (ユーザーが指定した方向性) -->
```

# 文書形式

## ディレクトリ

```text
<doc-dir>/
├── reader-term-contract-<document-id>.md
├── source.md
├── learning.json
└── dist/
    ├── index.html
    └── agent.md
```

`dist/` は `build` が生成するため、原稿作成時には作らない。

## source.md

先頭行を `learning.json` の `title` と一致するH1見出しにする。
各概念を説明する位置の直前へ、概念識別子を一度だけ置く。

```markdown
# TCPの輻輳制御

<!-- concept:packet-loss -->

## パケット損失

**パケット損失**とは、送信したパケットが宛先へ届かなかった状態を指す。

{{diagram:loss-response}}

$$
cwnd_{next} = cwnd_{current} / 2
$$
```

図の挿入位置は `{{diagram:<id>}}` と書く。 ブロック数式は、`$$` だけの行で囲む。
生のHTMLは書かない。

## learning.json

すべての項目を必須とする。 値がない配列も省略せず `[]` と書く。

```json
{
  "schema_version": 1,
  "document_id": "tcp-congestion-control",
  "title": "TCPの輻輳制御",
  "language": "ja",
  "reader": {
    "goal": "パケット損失後に送信量を減らす理由を説明できる",
    "known": ["TCPは通信プロトコルである"],
    "not_assumed": ["輻輳ウィンドウの計算"]
  },
  "concepts": [
    {
      "id": "packet-loss",
      "name": "パケット損失",
      "definition": "送信したパケットが宛先へ届かなかった状態",
      "prerequisites": []
    }
  ],
  "diagrams": [
    {
      "id": "loss-response",
      "kind": "sequence",
      "title": "損失を検出した後の処理",
      "steps": [
        {
          "id": "detect",
          "label": "損失を検出する",
          "description": "確認応答が返らないことなどから損失を判断する"
        },
        {
          "id": "reduce",
          "label": "送信量を減らす",
          "description": "追加の混雑を避けるため送信上限を下げる"
        }
      ],
      "caption": "損失の検出を起点として送信上限を変更する。"
    }
  ],
  "checks": [
    {
      "id": "check-loss-response",
      "concepts": ["packet-loss"],
      "type": "apply",
      "question": "損失後に送信量を増やすと何が起きますか。",
      "expected_points": ["混雑が悪化する", "追加の損失が起こりうる"]
    }
  ]
}
```

`type` は次のいずれかにする。

- `recall`：定義または因果を本文を見ずに説明する。
- `explain`：例の各段階が必要な理由を説明する。
- `apply`：新しい事例へ概念を適用する。
- `diagnose`：誤った説明の問題点を特定する。

概念、図、問題の識別子には英小文字、数字、ハイフンだけを使う。

## 回答JSON

HTMLの「回答をJSONで保存」ボタンは次の形式を生成する。

```json
{
  "schema_version": 1,
  "document_id": "tcp-congestion-control",
  "answered_at": "2026-07-28T12:00:00.000Z",
  "answers": [
    {
      "check_id": "check-loss-response",
      "answer": "送信量を増やすと混雑が悪化し、損失が増える可能性がある。"
    }
  ]
}
```

`document_id` は教材の `learning.json` と一致させる。 `answers`
にはすべての問題を一度ずつ含め、未回答は空文字列のまま残す。 `prepare-check`
は不足、重複、未知の問題識別子を失敗させる。

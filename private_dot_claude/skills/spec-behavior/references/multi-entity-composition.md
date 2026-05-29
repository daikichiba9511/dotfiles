# Multi-entity 合成 / refinement / 実装詳細との分離

SKILL.md 本体の補足。以下のケースで参照する:

| いつ読む | 何のため |
|---------|---------|
| 仕様の中に**2 つ以上のサブシステム**が出る (連携・broadcast 等) | エンティティ越えの合成 |
| 1 つの状態の内部が大きく、**抽象 spec と詳細 spec を分けたい** | 仕様の段階的詳細化 (refinement) |
| 仕様にミドルウェア名 (SNS/SQS/Lambda 等) が混じりそう | 実装詳細との分離 |

## 目次

- [エンティティ越えの合成 (multi-entity)](#エンティティ越えの合成-multi-entity)
- [仕様の段階的詳細化 (refinement)](#仕様の段階的詳細化-refinement)
- [実装詳細との分離](#実装詳細との分離)

---

## エンティティ越えの合成 (multi-entity)

1 つの状態機械では収まらない、複数サブシステムが絡む仕様の書き方。

**選択肢**:

| 手段 | 適用場面 | 強み | 弱み |
|------|---------|------|------|
| 別図 + イベント契約表 | サブシステム間のイベント連携 | Mermaid 複数で可読、現実解 | 同期セマンティクスが暗黙 |
| シーケンス図併用 | プロトコル交渉部分 | やり取りの順序が見える | 内部状態は stateDiagram で別途 |
| 単一図を保つ | サブシステム間の結合が強い | 全体が 1 枚で読める | 複雑化で読めなくなる |

実用解は **別図 + イベント契約表**。各エンティティに stateDiagram 1 枚、別セクションに以下の表を置く。

### イベント契約表のフォーマット

| イベント | producer | consumer | sync性 | payload | 備考 |
|---------|---------|---------|--------|---------|------|
| `event_a` | Subsystem A | Subsystem B | async / at-least-once / broadcast | `{key: type, ...}` | 補足 |
| `event_b` | 運用者 (手動) | Subsystem A | async / 手動キック | `{id: str}` | |

### 規律

- 共有イベントは**全エンティティで同名** (broadcast 規律の延長)
- **sync** (発火元が完了を待つ) と **async** (発火しっぱなし) を必ず明示
- payload は型・形式まで書く (実装の契約として効く)
- **共有状態** (複数 diagram が読み書きする変数) は契約表とは別に列挙し、**排他制御方針** (lock / 単一書き込み元 / CAS 等) を設計メモに書く

### 補助図 (multi-entity では必須相当)

契約表 + 各エンティティの stateDiagram だけでは「誰と誰が」「どんな順で」のかが見えない。以下を併記すると読み手の認知負荷が下がる。

- **通信マップ** (flowchart): エンティティをノード、共有イベントを矢印ラベルで書く。契約表の**視覚化版**。

  ```mermaid
  flowchart LR
      A[エンティティA<br/>状態機械]
      B[エンティティB<br/>状態機械]
      C[外部システム]
      A -->|event1<br/>event2<br/>async| B
      B -->|event3<br/>sync| C
  ```

- **典型プロトコル** (sequenceDiagram, 任意): happy path の代表シナリオを時系列で。異常系は無理に併記せず別図にする。

  ```mermaid
  sequenceDiagram
      participant A
      participant B
      A ->> B: event1 (async)
      B ->> A: event2 (sync)
  ```

役割分担:

- **flowchart** = 静的な「誰が誰に」の俯瞰
- **sequenceDiagram** = 動的な順序の典型例 (1 シナリオ)
- **stateDiagram** = 各エンティティの内部振る舞い詳細
- **契約表** = 形式的縛り (sync性 / payload)

stateDiagram で全部やろうとしない (composite 間遷移は Statechart 標準外で可読性も崩れる)。

---

## 仕様の段階的詳細化 (refinement)

複雑な状態を別 spec ファイルで展開する。

- **親 spec**: 抽象状態を 1 つ書き、内部の詳細は省略する (例: `state ParallelSetup` の中身を空にする)
- **子 spec**: 別ファイルで詳細を書く (内部の状態機械)
- **リンク**: 親 spec の設計メモに「`XX` の詳細は [child-spec.md](./child-spec.md) を参照」、子 spec の冒頭に「親 spec の `XX` 状態を展開した内部仕様」と明記する

階層 (Harel) で 1 つの図に書ききるか refinement で分けるかの判断:

- **階層**: 内部状態が小規模 (≤ 5 状態程度)、全体把握優先
- **refinement**: 内部が大きい、または読者層が違う (アーキ層 vs 実装層)

---

## 実装詳細との分離

**振る舞い仕様 = 作業依頼**、**実装詳細 = 作業詳細**。読み手の役割が違うので別 doc に切る。

| 振る舞いに含める (in) | 実装詳細 (別 doc に出す) |
|--------------------|---------------------|
| sync / async | ミドルウェア名 (SNS / SQS / Kafka 等) |
| 配信保証 (at-most-once / at-least-once / exactly-once) | クラウドサービス名 (Lambda / Fargate / ECS 等) |
| 順序保証 (FIFO / per-channel / なし) | IAM、queue 名、topic ARN、関数名 |
| 通信形態 (broadcast / point-to-point / pub-sub) | 言語・ライブラリ・フレームワーク選定 |
| 永続性 (crash で失われるか) | デプロイ方式、スケーリング、コスト、運用詳細 |
| 状態遷移とイベントのルール | リトライ機構の具体実装 (DLQ 設定値等) |

**書き換え例**:

| 悪い (実装混入) | 良い (抽象) |
|---------------|-----------|
| `async (SNS pub)` | `async / at-least-once / broadcast` |
| `publish_to_prelabel_topic` | `emit_prelabel_completed_event` |
| `start_sampling_lambda` | `enter_sampling` (状態遷移そのもので表現) |
| `Lambda: サンプリング (VPC内)` | `Sampling` (状態名のみ、実行基盤は別 doc) |
| `SQS DLQ のリトライ回数` | `リトライキューのリトライ回数 (実装層が決定)` |

**配置**:

- 振る舞い: `xxx-spec.md`
- 実装詳細: `xxx-impl.md` 別 doc 推奨、または refinement の子 spec として
- 設計メモに相互リンクを書く

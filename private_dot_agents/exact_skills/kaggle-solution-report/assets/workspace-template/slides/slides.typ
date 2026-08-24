#import "@preview/polylux:0.4.0": *
#import "@preview/metropolis-polylux:0.1.0" as metropolis
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import "@preview/cetz:0.5.2" as cetz
#import "theme.typ": *
#import "../figures/gold-pipelines.typ": rendered-gold-pipeline, gold-pipeline-placeholder

#show: metropolis.setup.with(
  footer: [{{COMPETITION_TITLE}}],
  text-font: "BIZ UDPGothic",
  math-font: "New Computer Modern Math",
  code-font: "HackGen35 Console NFJ",
  text-size: 17pt,
)
#set text(lang: "ja")
#set par(leading: 0.66em)
#set list(spacing: 0.38em)

#let arrow = align(center + horizon)[#text(size: 19pt, fill: gray)[→]]
#let diagram-label(title, body: none) = align(center)[
  #text(size: 12.5pt, weight: "bold", fill: ink)[#title]
  #if body != none {
    v(2pt)
    text(size: 11pt, fill: gray)[#body]
  }
]

#slide[
  #set page(header: none, footer: none, margin: 3em, fill: ink)
  #set text(fill: white)
  #set align(left + horizon)
  #text(size: 10pt, weight: "bold", fill: accent.lighten(24%))[KAGGLE SOLUTION REPORT]
  #v(0.55em)
  #text(size: 28pt, weight: "bold")[{{COMPETITION_TITLE}}]
  #v(0.45em)
  #text(size: 18pt)[TODO: このコンペを説明する一文]
  #v(0.8em)
  #line(length: 72%, stroke: 2pt + accent)
  #v(0.7em)
  #text(size: 10pt, fill: white.darken(20%))[TODO: 最終順位の調査範囲 / 証拠の限界]
]

#explainer(
  [タスクの具体例],
  [TODO: このタスクで実際に何を当てるのか。],
  [
    TODO: 入力、予測単位、予測対象を読者が想像できる具体例で説明する。

    TODO: 通常の問題と異なる制約や、test時に初めて必要になる処理を説明する。
  ],
  none,
  source: [TODO: 公式のタスク説明。 #source-mark("S-001")],
  quiet: true,
)

#explainer(
  [評価指標],
  [TODO: 評価指標がモデル設計へ与える最重要の圧力。],
  [
    TODO: 評価指標の平均、重み、確率の打ち切り、対応付け、閾値等を説明する。

    TODO: なぜ正解率等の直感と異なる判断が必要になるかを説明する。
  ],
  [
    #align(center)[$"metric" = "TODO"$]
    #v(0.4em)
    #align(center)[#text(size: 12pt, fill: gray)[TODO: 一つの予測を変えると総合scoreがどう変わるか。]]
  ],
  source: [TODO: 公式の評価指標。],
  quiet: true,
)

#explainer(
  [最重要のデータ特性],
  [TODO: 最終順位を左右した一つのデータ特性。],
  [
    TODO: 正確な件数と分母を使い、その特性がどれほど頻繁か説明する。

    TODO: その特性がどの失敗を作り、どの設計判断へつながるか説明する。
  ],
  none,
  source: [TODO: 件数と由来を確認できるデータ出典。],
  quiet: true,
)

// Analyze and author these pages first, but render them after the abstract synthesis.
#let gold_solution_reference_pages = [
#explainer(
  [出典一覧],
  [TODO: 本文中の出典IDから、確認した情報源とその制約を逆引きできる。],
  [
    #source-entry(
      "S-001",
      [TODO: 出典名],
      [TODO: 安定したURLまたはローカルパス],
      [TODO: 確認した章、ページ、節、ファイル],
      [TODO: 取得日],
      [TODO: この出典だけでは判断できないこと],
    )
  ],
  none,
  quiet: true,
)

#solution-overview(
  [1st solution: TODOチームの全体像],
  [TODO: 入力から最終確率まで、解法全体が何をどの順序で処理するか。],
  [
    // Replace marker, label, and function with `gold-pipeline-<rank>-<team-slug>`.
    #rendered-gold-pipeline(
      "gold-pipeline-placeholder",
      <gold-pipeline-placeholder>,
      gold-pipeline-placeholder(text-size: 11pt),
    )
  ],
  orientation: [TODO: 図を読むのに必要な前提がある場合だけ、1段落で補う。],
  source: [TODO: 1st solutionの元投稿と一次成果物。],
)

#explainer(
  [1st solution: TODOとなる中心的な工夫],
  [TODO: この解法が重点的に扱った失敗と、そのために加えた処理。],
  [
    TODO: 失敗が起こる具体的な過程と、解法の工夫が何を変えるかを説明する。

    TODO: CV、Leaderboard、ablation、負の結果、または未公開情報を示し、どこまで信頼できるかを説明する。
  ],
  none,
  note: [TODO: 参加者報告、未再現、比較条件の違いなど。],
  source: [TODO: 1st solutionの検証結果またはQ&A。],
  quiet: true,
)

// Repeat the complete `Nth solution` overview and central-decision block for
// every method-bearing gold team inside this reference section.
]

#explainer(
  [上位解法の共通項],
  [TODO: 解法の詳細を確認できたチームに共通する一つの設計。],
  [
    TODO: 確認、不使用、未確認の分母を明示し、共通性を文章で説明する。

    TODO: 反例または別実装を示し、表面的な構成要素の名前より本質的な役割を説明する。
  ],
  none,
  note: [未記載を不使用として数えない。],
  quiet: true,
)

#explainer(
  [共通項が効く理由],
  [TODO: データまたは評価指標の性質に対して、共通する処理が何を改善するのか。],
  [
    TODO: データまたは評価指標の性質から、失敗が生まれるまでを説明する。

    TODO: 解法の要素が誤差をどう変え、どの証拠がそれを支持するか説明する。
  ],
  [
    #align(center)[
      #diagram(
        cell-size: (70mm, 21mm),
        node-stroke: 0.7pt + gray.lighten(28%),
        node-fill: pale,
        edge-stroke: 0.9pt + gray,
        node((0, 0), diagram-label([性質], body: [TODO]), width: 50mm, height: 18mm, corner-radius: 2pt),
        edge("-|>"),
        node((1, 0), diagram-label([失敗], body: [TODO]), width: 50mm, height: 18mm, corner-radius: 2pt),
        edge("-|>"),
        node((2, 0), diagram-label([解法で加えた処理], body: [TODO]), width: 50mm, height: 18mm, corner-radius: 2pt),
      )
    ]
  ],
  note: [TODO: 交絡要因または未検証の条件。],
)

#explainer(
  [Gold上位と下位の比較],
  [TODO: Gold上位が、確認したどの失敗へ追加の対策を入れていたか。],
  [
    TODO: 比較する順位群の定義と、観測できた差を説明する。

    TODO: 下位側の反例を示し、明確な境界ではない場合は結論を弱める。
  ],
  none,
  source: [TODO: 順位を対応付けた証拠。],
  quiet: true,
)

#explainer(
  [GoldとSilver上位の比較],
  [TODO: 公開証拠から言える差、または比較不能という結論。],
  [
    TODO: Silver側で公開解法を確認できた範囲を説明する。

    TODO: 未確認を不使用とみなさず、どこまでなら順位差として読めるか説明する。
  ],
  none,
  quiet: true,
)

#explainer(
  [データの事実を比較実験へつなげる],
  [TODO: 開始時点で確認できた一つの事実から、最初に行う比較を具体的に示す。],
  [
    TODO: 公式規則、データ定義、評価指標から確認できる事実を一つ説明する。

    TODO: 起こりうる失敗を述べ、同じ条件で比較する二つの対象と、結果に応じた次の実験を説明する。
  ],
  [
    #quiet-step([1], [データで確認した事実], [TODO: 件数、欠損、入力差など])
    #v(0.25em)
    #quiet-step([2], [起こりうる具体的な失敗], [TODO: 何が、どの処理で、どう誤るか])
    #v(0.25em)
    #quiet-step([3], [同じ条件で比べる対象], [TODO: AとB、固定する条件、測る値])
    #v(0.25em)
    #quiet-step([4], [結果に応じた次の実験], [TODO: どの数値なら何を改善するか])
  ],
  quiet: true,
)

#explainer(
  [失敗実験],
  [TODO: 一見よさそうな変更が、基準実験より悪化した理由。],
  [
    TODO: 予想した効果、実際に加えた変更、変更しない基準、観測結果を説明する。

    TODO: 別の説明を示し、次に同じ変更を採用するための数値条件を説明する。
  ],
  none,
  note: [TODO: 証拠の種別と、その証拠からは判断できないこと。],
  quiet: true,
)

#explainer(
  [次の類似課題で試す順序],
  [TODO: 何を測ってから次の実験へ進むかを、実行順に示す。],
  [
    TODO: 信頼できるCVと、入力から提出値まで通る小さな基準モデルを作る前半を説明する。

    TODO: 個別の失敗への対策、確率校正、アンサンブルへ進む条件を説明する。
  ],
  [
    #quiet-step([1], [信頼できるCV], [TODO: 分割単位と評価指標])
    #v(0.25em)
    #quiet-step([2], [小さな基準モデル], [TODO: 入力から提出値まで通す])
    #v(0.25em)
    #quiet-step([3], [二つの原因を見分ける比較], [TODO: 同じ条件で比べるAとB])
    #v(0.25em)
    #quiet-step([4], [改善が確認できた処理へ投資], [TODO: 採用する数値条件])
  ],
  pin-top: true,
  quiet: true,
)

#explainer(
  [まとめ],
  [TODO: 次の類似課題で最初に行う、具体的な観察または比較。],
  [
    TODO: タスク、データ、評価指標のどの事実から、上位解法の処理が必要になったかを説明する。

    TODO: 次の類似コンペで最初に試す行動へ言い換える。
  ],
  none,
  quiet: true,
)

#explainer(
  [調査範囲と限界],
  [TODO: 結論をどの調査範囲と不確実性のもとで読むべきか。],
  [
    TODO: 対象順位と、公開情報を十分に確認できた順位、一部だけ確認できた順位、解法を取得できなかった順位を説明する。その後で、台帳上のcomplete、partial、unavailableという状態名を対応付ける。

    TODO: 参加者による報告にとどまる結果、独立に再現されていない結果、公開解法の偏りが結論をどう弱めるか説明する。

    TODO: 次頁以降が、前半の学びを順位別の根拠へ戻って確認する個別解法の参照編であることを案内する。
  ],
  [
    #table(
      columns: (1fr, 1.5fr),
      inset: (x: 9pt, y: 4.5pt),
      stroke: (x: none, y: 0.55pt + gray.lighten(48%)),
      fill: (x, y) => if y == 0 { pale } else { white },
      [調査対象], [公開情報の確認状況],
      [TODO], [対象順位],
      [TODO], [complete / partial / unavailable],
    )
  ],
  source: [TODO: コンペ、評価指標、主催者、公開解法の出典。],
  quiet: true,
)

#gold_solution_reference_pages

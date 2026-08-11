#import "@preview/polylux:0.4.0": *
#import "@preview/metropolis-polylux:0.1.0" as metropolis
#import metropolis: focus
#import "theme.typ": *

#show: metropolis.setup.with(
  footer: [{{COMPETITION_TITLE}}],
  text-font: "BIZ UDPGothic",
  math-font: "New Computer Modern Math",
  code-font: "HackGen35 Console NFJ",
  text-size: 16pt,
)
#set text(lang: "ja")
#set par(leading: 0.64em)
#set list(spacing: 0.42em)
#show raw.where(block: true): it => block(
  width: 100%,
  fill: pale,
  stroke: 0.5pt + gray.lighten(55%),
  radius: 3pt,
  inset: 7pt,
  text(size: 9.5pt, it),
)

#slide[
  #set page(header: none, footer: none, margin: 2.5em, fill: ink)
  #set text(fill: white)
  #set align(left + horizon)
  #text(size: 9pt, weight: "bold", fill: accent.lighten(20%))[KAGGLE SOLUTION REPORT]
  #v(0.5em)
  #text(size: 29pt, weight: "bold")[{{COMPETITION_TITLE}}]
  #v(0.4em)
  #text(size: 16pt)[上位解法を、データと評価指標から読み解く]
  #v(0.75em)
  #line(length: 72%, stroke: 2pt + accent)
  #v(0.7em)
  #text(size: 10pt, fill: white.darken(20%))[Gold全チーム + Upper Silver（範囲と欠測を明示）]
]

#lesson([結論と調査範囲])[
  #claim[TODO: この発表の中心結論を一文で示す。]
  #v(0.4em)
  #columns(
    [#panel([Evidence], [TODO: 対象順位、方法証拠のあるteam数、主要な共通頻度。])],
    [#panel([Boundary], [TODO: partial/unavailableと比較できない範囲。])],
  )
  #source-note([Source: final private leaderboard and coverage manifest.])
]

#lesson([何を予測し、どこで失敗するか])[
  #columns(
    [#panel([Input → target], [TODO: 予測単位、入力、target、提出shape。], emphasis: true)],
    [#panel([Hidden subtask], [TODO: test時だけ必要な局在・matching・aggregation。])],
  )
  #takeaway[TODO: classification以外の主要bottleneck。]
  #source-note([Source: official competition overview.])
]

#lesson([評価指標が作るincentive])[
  $
    L = -frac(sum_i w_i y_i ln(p_i), sum_i w_i)
  $
  #columns(
    [#panel([Exact behavior], [TODO: weighting、averaging、edge caseを数値で示す。], emphasis: true)],
    [#panel([Modeling consequence], [TODO: calibration、threshold、rare classへの影響。])],
  )
  #takeaway[TODO: 指標から導かれる最小の設計判断。]
  #source-note([Source: official metric implementation.])
]

#lesson([データの性質を数で示す])[
  #columns(
    [#stat([TODO], [Primary count], detail: [denominatorを併記], emphasis: true)],
    [#stat([TODO], [Comparison count], detail: [modeling consequenceを示す])],
  )
  #v(0.35em)
  #table(
    columns: (1.2fr, 0.7fr, 1.8fr),
    fill: table-fill,
    stroke: table-rule,
    inset: 7pt,
    [*Property*], [*Count*], [*Why it matters*],
    [TODO], [TODO], [TODO],
    [TODO], [TODO], [TODO],
    [TODO], [TODO], [TODO],
  )
  #takeaway[TODO: leaderboardを形作った最重要data property。]
]

#lesson([上位に共通したpattern])[
  #table(
    columns: (1.8fr, 0.6fr, 0.6fr, 0.8fr),
    fill: table-fill,
    stroke: table-rule,
    inset: 7pt,
    [*Factor*], [*Yes*], [*No*], [*Unknown*],
    [TODO], [TODO], [TODO], [TODO],
    [TODO], [TODO], [TODO], [TODO],
    [TODO], [TODO], [TODO], [TODO],
  )
  #takeaway[未記載は`unknown`として分母から分離する。]
]

#lesson([なぜ共通patternが効いたか])[
  #panel([Mechanism chain], [
    task/data/metric property → failure mode → solution element → expected effect
  ], emphasis: true)
  #v(0.4em)
  #columns(
    [#panel([Observed evidence], [TODO: rank付き事例を二つ以上。])],
    [#panel([Counterevidence], [TODO: 反例、交絡、未検証条件。])],
  )
  #source-note([Source: comparison matrix and paired solution Markdown.])
]

#lesson([代表的なSolution pipeline])[
  #grid(
    columns: (1fr, auto, 1fr, auto, 1fr),
    gutter: 8pt,
    panel([Input / geometry], [TODO], emphasis: true),
    align(center + horizon)[→],
    panel([Localization], [TODO]),
    align(center + horizon)[→],
    panel([Classification], [TODO]),
  )
  #v(0.4em)
  #panel([Training–inference gap], [TODO: GTとpredicted inputの差、その吸収方法。])
  #takeaway[TODO: pipelineのどの継ぎ目がscoreを支配したか。]
]

#lesson([Top GoldとLower Goldの観測差])[
  #table(
    columns: (1.1fr, 1.4fr, 1.4fr, 0.8fr),
    fill: table-fill,
    stroke: table-rule,
    inset: 7pt,
    [*Factor*], [*Top Gold evidence*], [*Lower Gold evidence*], [*Strength*],
    [TODO], [TODO], [TODO], [TODO],
    [TODO], [TODO], [TODO], [TODO],
  )
  #takeaway[TODO: architecture名でなく、差を生んだerror-control。]
]

#lesson([GoldとUpper Silver：言えること／言えないこと])[
  #comparison(
    [Observed],
    [TODO: 比較可能な公開証拠。],
    [Not identifiable],
    [TODO: coverage不足で断定できない要素。],
    highlight: "left",
  )
  #takeaway[未記載を「使っていない」と数えない。]
]

#lesson([Key ideaを発見する最小実験])[
  #table(
    columns: (1fr, 1.2fr, 1.25fr, 1fr),
    fill: table-fill,
    stroke: table-rule,
    inset: 6pt,
    [*Clue*], [*Hypothesis*], [*Cheapest test*], [*Decision*],
    [TODO], [TODO], [TODO], [TODO],
    [TODO], [TODO], [TODO], [TODO],
    [TODO], [TODO], [TODO], [TODO],
  )
]

#lesson([実戦的なplaybook])[
  #columns(
    [
      1. Exact metric + trustworthy split
      2. Minimal end-to-end baseline
      3. Bottleneck-isolating comparison
      4. Task-specific representation
    ],
    [
      5. Error-matched augmentation
      6. OOF-only data intervention
      7. Calibration
      8. Structural ensemble last
    ],
  )
  #takeaway[TODO: このコンペ固有の停止条件・判断基準。]
]

#slide[
  #show: focus
  *TODO: 最も移植可能な原則*

  #v(0.5em)
  #text(size: 15pt)[TODO: 根拠と実務上の含意を二文で示す。]
]

#lesson([Coverage・limitations・references])[
  #set text(size: 12.5pt)
  - Coverage: TODO selected / complete / partial / unavailable
  - Participant-reportedと独立再現を区別
  - 比較不能なrank帯を明示
  - Official competition page: TODO
  - Final leaderboard: TODO
  - Official metric: TODO
  - Dataset or organizer context: TODO
  - Solution discussions and public artifacts: TODO
]

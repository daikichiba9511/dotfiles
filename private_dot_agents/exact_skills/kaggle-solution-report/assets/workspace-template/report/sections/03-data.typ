#import "../lib.typ": *

= データの解説

== データ生成と予測単位

TODO: train/testの由来、独立単位、ラベル生成、欠損、偏りを説明する。

== データから評価までの流れ

#align(center)[
  #table(
    columns: (1fr, auto, 1fr, auto, 1fr),
    stroke: none,
    inset: 5pt,
    [#panel([Train], [入力・ラベル], accent: blue)],
    [→],
    [#panel([Model], [学習・推論], accent: teal)],
    [→],
    [#panel([Metric], [提出・評価], accent: amber)],
  )
]

TODO: 実データの流れと、group/leakage/distribution shiftの境界へ置き換える。

== 検証上の危険

TODO: public/private LB、グループ分割、重複、リーク、shake-upを説明する。

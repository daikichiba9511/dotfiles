#import "../lib.typ": *

= どうやって戦えばよかったか

== 観察から仮説へ

TODO: ルール、データ、指標から気づけた手掛かりを並べる。

== 最小の識別実験

TODO: 仮説、最安のテスト、採否基準、次の投資を表にする。

== 推奨する順序

1. 信頼できるbaselineとsplitを作る。
2. metric-aligned error analysisを行う。
3. data/representation/modelの仮説を一つずつ検証する。
4. inference/postprocessingを評価する。
5. 最後にdiversity-aware ensembleへ投資する。

== 気をつけるべき点

TODO: public LB過適合、リーク、再現不能なgain、計算資源の交絡を扱う。

#import "../lib.typ": *

= 評価指標とタスク

#panel([Template warning], [
  The equation below is illustrative. Replace it with the competition's exact metric and edge-case behavior before publication.
], accent: red)

== 評価指標

$
  "RMSE" = sqrt(1 / n sum_(i=1)^n (y_i - hat(y)_i)^2)
$

ここで $n$ は評価対象数、$y_i$ は正解、$hat(y)_i$ は予測である。TODO: 正確な式、方向、集約、重み、閾値、例外処理へ置き換える。

== 小さな計算例

TODO: 数値例を用いて、どの誤差が強く効くかを示す。

== 指標が作るインセンティブ

TODO: 指標の性質から、モデル・検証・後処理へ何が要求されるかを導く。

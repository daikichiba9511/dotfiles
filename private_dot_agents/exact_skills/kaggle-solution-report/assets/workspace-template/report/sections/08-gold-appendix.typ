#import "../lib.typ": *
#import "../../figures/gold-pipelines.typ": rendered-gold-pipeline, rendered-gold-unavailable, gold-pipeline-placeholder

= Appendix：金メダル圏それぞれの解法の概要とポイント

// Duplicate this complete block for every gold row in scope/coverage.csv.
// Use `1位`, `2位`, ... in report prose and define the matching shared figure
// as `gold-pipeline-1-team-slug`, `gold-pipeline-2-team-slug`, ... under
// figures/gold-pipelines.typ. Use rank plus slug so tied teams stay distinct.
== 1位：Team TODO

=== 概要

TODO

=== Solutionの全体像

TODO: 入力から最終確率までを、図の読み順に説明する。

// Replace marker, label, and function with `gold-pipeline-<rank>-<team-slug>`.
#rendered-gold-pipeline(
  "gold-pipeline-placeholder",
  <gold-pipeline-placeholder>,
  gold-pipeline-placeholder(text-size: 9pt),
)

#source-note([図の出典: TODO: 1st solutionの元投稿と一次成果物。])

=== Solutionのポイント

TODO

=== 理解を深めるための解説

TODO

=== 検証・再現性・Evidence gap

TODO

#source-note([Paired sources: `solutions/rank-NNN-team-raw.md` and `solutions/rank-NNN-team.md`.])

// For a fully unavailable gold team, remove the method-bearing block and write:
// == N位：Team TODO
// === 公開情報の限界
// #rendered-gold-unavailable(
//   "gold-unavailable-N-team-slug",
//   <gold-unavailable-N-team-slug>,
//   [Explain the exhausted topic orderings, team/member/rank searches, linked artifacts,
//   missing body or team attribution, and why no pipeline is inferred.],
// )
// Add the paired raw/organized source note. Do not render a placeholder figure.

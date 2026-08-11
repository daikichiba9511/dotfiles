#import "lib.typ": *

#set document(
  title: "{{COMPETITION_TITLE}} — 上位解法分析",
  author: "",
)
#set page(
  paper: "a4",
  margin: (x: 23mm, top: 22mm, bottom: 22mm),
  header: context align(right, text(size: 7.5pt, fill: gray)[{{COMPETITION_TITLE}} — 上位解法分析]),
  footer: context align(center, text(size: 8pt, fill: gray)[
    #counter(page).display("1") / #counter(page).final().at(0)
  ]),
)
#set text(lang: "ja", font: "BIZ UDPGothic", size: 10.5pt, fill: ink)
#set par(justify: true, leading: 0.72em)
#set heading(numbering: "1.1")
#set math.equation(numbering: "(1)")
#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  set text(fill: ink)
  it
  line(length: 100%, stroke: 1.3pt + teal)
  v(5pt)
}
#show raw.where(block: true): it => block(
  width: 100%,
  breakable: true,
  fill: pale,
  stroke: 0.5pt + gray.lighten(55%),
  radius: 3pt,
  inset: 8pt,
  text(size: 8.5pt, it),
)

#align(center + horizon)[
  #text(size: 13pt, weight: "bold", fill: teal)[KAGGLE SOLUTION REPORT]
  #v(18pt)
  #text(size: 25pt, weight: "bold")[{{COMPETITION_TITLE}}]
  #v(8pt)
  #text(size: 17pt)[上位解法の横断分析]
  #v(26pt)
  #line(length: 62%, stroke: 2pt + amber)
  #v(20pt)
  #text(size: 10pt, fill: gray)[Gold全チーム + Upper Silver（scope/coverage.csvで定義）]
]

#pagebreak()
#outline(title: [目次], depth: 3, indent: auto)

#include "sections/01-overview.typ"
#include "sections/02-task-metric.typ"
#include "sections/03-data.typ"
#include "sections/04-common-elements.typ"
#include "sections/05-differentiators.typ"
#include "sections/06-strategy.typ"
#include "sections/07-summary.typ"
#include "sections/08-gold-appendix.typ"
#include "sections/09-evidence-and-references.typ"

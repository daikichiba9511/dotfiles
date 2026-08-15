// Replace this placeholder with one function per method-bearing gold team:
// `gold-pipeline-1-team-slug`, `gold-pipeline-2-team-slug`, and so on.
// Keep the semantic topology in the paired organized Markdown file.

#let pipeline-ink = rgb("#263238")
#let pipeline-accent = rgb("#00796b")
#let pipeline-gray = rgb("#6b777c")
#let pipeline-surface = rgb("#f4f7f8")
#let pipeline-accent-surface = rgb("#e9f3f1")

#let rendered-gold-pipeline(marker, label, visual) = block[
  #metadata(marker) #label
  #visual
]

#let rendered-gold-unavailable(marker, label, body) = block[
  #metadata(marker) #label
  #body
]

#let pipeline-node(body, width: 42mm, accent: false, text-size: 9pt) = block(
  width: width,
  inset: (x: 5pt, y: 5pt),
  radius: 3pt,
  stroke: 0.8pt + (if accent { pipeline-accent } else { pipeline-gray.lighten(35%) }),
  fill: if accent { pipeline-accent-surface } else { white },
  align(center, text(size: text-size, fill: pipeline-ink, body)),
)

#let pipeline-arrow(direction: [→], text-size: 11pt) = align(
  center + horizon,
  text(size: text-size, fill: pipeline-gray, direction),
)

#let pipeline-group(title, body, text-size: 9pt) = block(
  width: 100%,
  inset: 7pt,
  radius: 4pt,
  stroke: 0.7pt + pipeline-gray.lighten(45%),
  fill: pipeline-surface,
  [
    #text(size: text-size, weight: "bold", fill: pipeline-gray)[#title]
    #v(5pt)
    #body
  ],
)

#let gold-pipeline-placeholder(text-size: 9pt) = grid(
  columns: (0.8fr, 1.2fr, 0.8fr),
  gutter: 7pt,
  align: horizon,
  pipeline-node([TODO: 入力], text-size: text-size),
  pipeline-group([TODO: チーム固有の分岐], [
    #grid(
      columns: (1fr, 13pt, 1fr),
      gutter: 4pt,
      align: horizon,
      pipeline-node([TODO: 経路A], width: 31mm, text-size: text-size),
      pipeline-arrow(text-size: text-size + 2pt),
      pipeline-node([TODO: 予測A], width: 31mm, text-size: text-size),
    )
    #v(5pt)
    #grid(
      columns: (1fr, 13pt, 1fr),
      gutter: 4pt,
      align: horizon,
      pipeline-node([TODO: 経路B], width: 31mm, text-size: text-size),
      pipeline-arrow(text-size: text-size + 2pt),
      pipeline-node([TODO: 予測B], width: 31mm, text-size: text-size),
    )
  ], text-size: text-size),
  pipeline-node([TODO: 最終統合], text-size: text-size),
)

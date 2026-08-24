#import "@preview/polylux:0.4.0": slide

#let ink = rgb("#263238")
#let accent = rgb("#00796b")
#let gray = rgb("#6b777c")
#let pale = rgb("#f4f7f8")
#let pale-accent = rgb("#e9f3f1")

#let lesson(title, body, pin-top: false, quiet: false) = slide({
  set align(top)
  heading(level: 1, title)
  if pin-top {
    v(0.45em)
    body
  } else if quiet {
    v(0.38fr)
    body
    v(0.62fr)
  } else {
    v(0.24fr)
    body
    v(0.76fr)
  }
})

#let columns(left, right, widths: (1fr, 1fr), gutter: 20pt) = grid(
  columns: widths,
  gutter: gutter,
  left,
  right,
)

#let lead(body, size: 20pt, width: 94%) = block(width: width)[
  #text(size: size, weight: "bold", fill: ink)[#body]
]

#let prose(
  body,
  size: 16pt,
  width: 94%,
  leading: 0.7em,
  spacing: 0.65em,
) = block(width: width)[
  #set text(size: size)
  #set par(leading: leading, spacing: spacing)
  #body
]

#let accent-note(body, size: 15pt) = block(
  width: 100%,
  inset: (left: 11pt, right: 5pt, y: 3pt),
  stroke: (left: 2.4pt + accent),
  [#text(size: size, weight: "bold", fill: ink)[#body]],
)

#let claim(body) = grid(
  columns: (3pt, 1fr),
  gutter: 10pt,
  rect(width: 3pt, height: 28pt, radius: 1.5pt, fill: accent),
  text(size: 19pt, weight: "bold", fill: ink)[#body],
)

#let quiet-claim(body, width: 90%) = block(width: width)[
  #text(size: 18pt, weight: "bold", fill: ink)[#body]
]

#let supplement(body) = block(
  width: 100%,
  inset: (x: 9pt, y: 5pt),
  radius: 3pt,
  fill: pale,
  [
    #text(size: 9.5pt, weight: "bold", fill: gray)[補足]
    #h(0.7em)
    #text(size: 10.5pt, fill: ink)[#body]
  ],
)

#let source-note(body) = block(width: 100%)[
  #v(5pt)
  #align(right, text(size: 8.5pt, fill: gray)[#body])
]

#let source-mark(id) = text(size: 8.5pt, fill: gray)[[#id]]

#let source-entry(id, title, location, inspected, retrieved, limitation) = block(
  width: 100%,
  inset: (y: 4pt),
  [
    #text(size: 10pt, weight: "bold", fill: ink)[[#id] #title]
    #linebreak()
    #text(size: 8.5pt, fill: gray)[#location · 確認範囲: #inspected · 取得日: #retrieved]
    #if limitation != none {
      linebreak()
      text(size: 8.5pt, fill: gray)[制約: #limitation]
    }
  ],
)

#let explainer(
  title,
  point,
  explanation,
  visual,
  note: none,
  source: none,
  pin-top: false,
  quiet: false,
) = lesson(title, [
  #if quiet { quiet-claim(point) } else { claim(point) }
  #v(if quiet { 0.85em } else { 0.5em })
  #prose(
    explanation,
    size: if quiet { 16pt } else { 15.3pt },
    width: if quiet and visual == none { 86% } else { 100% },
    leading: if quiet { 0.86em } else { 0.76em },
    spacing: if quiet { 1.2em } else { 0.72em },
  )
  #if visual != none {
    v(if quiet { 0.5em } else { 0.65em })
    visual
  }
  #if note != none {
    v(0.55em)
    supplement(note)
  }
  #if source != none {
    source-note(source)
  }
], pin-top: pin-top, quiet: quiet)

#let solution-overview(
  title,
  point,
  visual,
  orientation: none,
  source: none,
) = lesson(title, [
  #claim(point)
  #v(0.75em)
  #visual
  #if orientation != none {
    v(0.55em)
    prose(orientation, size: 14.8pt, width: 100%, leading: 0.75em, spacing: 0.6em)
  }
  #if source != none {
    source-note(source)
  }
], quiet: true)

#let datum(value, label, detail: none, emphasis: false) = block(width: 100%)[
  #text(
    size: 25pt,
    weight: "bold",
    fill: if emphasis { accent } else { ink },
  )[#value]
  #v(2pt)
  #text(size: 12.5pt, weight: "bold", fill: ink)[#label]
  #if detail != none {
    v(2pt)
    text(size: 10.5pt, fill: gray)[#detail]
  }
]

#let tag(body, active: false) = box(
  inset: (x: 7pt, y: 3pt),
  radius: 8pt,
  stroke: 0.7pt + (if active { accent } else { gray.lighten(42%) }),
  fill: if active { pale-accent } else { white },
  text(size: 10pt, weight: "bold", fill: if active { accent } else { gray })[#body],
)

#let stage(title, body, active: false) = block(
  width: 100%,
  inset: (x: 10pt, y: 8pt),
  radius: 3pt,
  fill: if active { pale-accent } else { pale },
  stroke: (bottom: 1pt + (if active { accent } else { gray.lighten(42%) })),
  [
    #text(size: 11.5pt, weight: "bold", fill: if active { accent } else { ink })[#title]
    #v(3pt)
    #text(size: 12.5pt, fill: ink)[#body]
  ],
)

#let step(number, title, body, active: false) = grid(
  columns: (26pt, 1fr),
  gutter: 10pt,
  align(center + horizon)[
    #rect(
      width: 24pt,
      height: 24pt,
      radius: 12pt,
      fill: if active { accent } else { ink },
      inset: 0pt,
    )[
      #align(center + horizon)[#text(size: 11pt, weight: "bold", fill: white)[#number]]
    ]
  ],
  [
    #text(size: 12pt, weight: "bold", fill: if active { accent } else { ink })[#title]
    #v(2pt)
    #text(size: 11.2pt, fill: gray)[#body]
  ],
)

#let quiet-step(number, title, body) = grid(
  columns: (20pt, 1fr),
  gutter: 9pt,
  align(right)[#text(size: 10pt, weight: "bold", fill: gray)[#number]],
  [
    #text(size: 11.8pt, weight: "bold", fill: ink)[#title]
    #h(0.55em)
    #text(size: 11.2pt, fill: gray)[#body]
  ],
)

#let soft-rule() = line(length: 100%, stroke: 0.65pt + gray.lighten(50%))

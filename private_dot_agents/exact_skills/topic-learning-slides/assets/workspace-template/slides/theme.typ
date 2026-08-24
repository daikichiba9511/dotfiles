#import "@preview/polylux:0.4.0": slide

#let ink = rgb("#263238")
#let accent = rgb("#00796b")
#let gray = rgb("#6b777c")
#let pale = rgb("#f4f7f8")
#let pale-accent = rgb("#e9f3f1")

#let lesson(title, body, quiet: false) = slide({
  set align(top)
  heading(level: 1, title)
  if quiet {
    v(0.36fr)
    body
    v(0.64fr)
  } else {
    v(0.2fr)
    body
    v(0.8fr)
  }
})

#let claim(body, quiet: false) = if quiet {
  block(width: 90%)[
    #text(size: 18pt, weight: "bold", fill: ink)[#body]
  ]
} else {
  grid(
    columns: (3pt, 1fr),
    gutter: 10pt,
    rect(width: 3pt, height: 28pt, radius: 1.5pt, fill: accent),
    text(size: 19pt, weight: "bold", fill: ink)[#body],
  )
}

#let prose(body, quiet: false, width: 100%) = block(width: width)[
  #set text(size: if quiet { 16pt } else { 15.3pt })
  #set par(
    leading: if quiet { 0.86em } else { 0.76em },
    spacing: if quiet { 1.15em } else { 0.72em },
  )
  #body
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
  representation: none,
  note: none,
  source: none,
  quiet: false,
) = lesson(title, [
  #claim(point, quiet: quiet)
  #v(if quiet { 0.85em } else { 0.5em })
  #prose(
    explanation,
    quiet: quiet,
    width: if quiet and representation == none { 86% } else { 100% },
  )
  #if representation != none {
    v(if quiet { 0.5em } else { 0.65em })
    representation
  }
  #if note != none {
    v(0.55em)
    supplement(note)
  }
  #if source != none {
    source-note(source)
  }
], quiet: quiet)

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

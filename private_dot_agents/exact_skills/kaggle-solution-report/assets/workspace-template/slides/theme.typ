#import "@preview/polylux:0.4.0": slide

#let ink = rgb("#263238")
#let accent = rgb("#00796b")
#let gray = rgb("#6b777c")
#let pale = rgb("#f4f7f8")
#let pale-accent = rgb("#e9f3f1")
#let table-rule = 0.5pt + gray.lighten(52%)
#let table-fill = (x, y) => if y == 0 { pale-accent } else { white }

#let lesson(title, body, pin-top: false) = slide({
  set align(top)
  heading(level: 1, title)
  if pin-top {
    body
  } else {
    v(0.35fr)
    body
    v(0.65fr)
  }
})

#let columns(left, right, widths: (1fr, 1fr), gutter: 18pt) = grid(
  columns: widths,
  gutter: gutter,
  left,
  right,
)

#let panel(title, body, emphasis: false) = rect(
  width: 100%,
  radius: 4pt,
  stroke: 0.8pt + (if emphasis { accent } else { gray.lighten(48%) }),
  fill: if emphasis { pale-accent } else { pale },
  inset: 9pt,
  [
    #text(size: 0.82em, weight: "bold", fill: if emphasis { accent.darken(12%) } else { ink })[#title]
    #v(3pt)
    #body
  ],
)

#let claim(body) = panel([Primary claim], body, emphasis: true)

#let stat(value, label, detail: none, emphasis: false) = panel(
  label,
  [
    #text(
      size: 1.55em,
      weight: "bold",
      fill: if emphasis { accent.darken(12%) } else { ink },
    )[#value]
    #if detail != none {
      v(2pt)
      text(size: 0.76em, fill: gray)[#detail]
    }
  ],
  emphasis: emphasis,
)

#let comparison(
  left-title,
  left,
  right-title,
  right,
  highlight: none,
) = columns(
  [#panel(left-title, left, emphasis: highlight == "left")],
  [#panel(right-title, right, emphasis: highlight == "right")],
)

#let takeaway(body) = {
  v(6pt)
  block(
    width: 100%,
    inset: (left: 10pt, right: 8pt, y: 6pt),
    stroke: (left: 2.2pt + accent),
    fill: pale-accent,
    [#text(weight: "bold", fill: accent.darken(12%))[Implication] #h(0.6em) #body],
  )
}

#let source-note(body) = align(
  right,
  text(size: 7.6pt, fill: gray)[#body],
)

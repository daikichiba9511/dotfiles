#let ink = rgb("#263238")
#let teal = rgb("#00796b")
#let blue = rgb("#1565c0")
#let amber = rgb("#f9a825")
#let red = rgb("#c62828")
#let gray = rgb("#607d8b")
#let pale = rgb("#f4f7f8")

#let panel(title, body, accent: teal) = block(
  width: 100%,
  breakable: true,
  fill: accent.lighten(93%),
  stroke: (left: 2.2pt + accent),
  inset: (x: 10pt, y: 8pt),
  radius: 2pt,
  [
    #text(weight: "bold", fill: accent.darken(12%))[#title]
    #v(3pt)
    #body
  ],
)

#let source-note(body) = align(
  right,
  text(size: 7.8pt, fill: gray)[#body],
)

#let evidence-label(label, body) = panel(
  [Evidence: #label],
  body,
  accent: if label == "organizer-confirmed" { blue } else if label == "inference" { amber } else { teal },
)

#let mechanism-chain(property, failure, element, effect, evidence, uncertainty) = table(
  columns: (1fr, 1fr),
  stroke: 0.5pt + gray.lighten(55%),
  inset: 6pt,
  fill: (x, y) => if x == 0 { pale } else { white },
  [*Task/data/metric property*], property,
  [*Failure mode or incentive*], failure,
  [*Solution element*], element,
  [*Expected effect*], effect,
  [*Observed evidence*], evidence,
  [*Uncertainty*], uncertainty,
)

#let code-sample(label, body) = {
  panel([Code status: #label], body, accent: blue)
}

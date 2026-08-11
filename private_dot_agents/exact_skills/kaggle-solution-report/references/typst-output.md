# Typst report and public slide contract

## Contents

1. Shared rules
2. Typst-native math
3. Detailed report structure
4. Required technical devices
5. Gold-solution appendix
6. Public slide structure
7. Public-release rules
8. Compilation and visual QA

## 1. Shared rules

Use Typst for both deliverables. The report is A4 portrait. The deck is 16:9 Polylux with `metropolis-polylux`.

Use these local slide defaults when the fonts exist:

- Japanese text: `BIZ UDPGothic`
- math: `New Computer Modern Math`
- code: `HackGen35 Console NFJ`
- Polylux: `@preview/polylux:0.4.0`
- Metropolis: `@preview/metropolis-polylux:0.1.0`

If a font is absent, choose one installed Japanese font and record the change. Do not silently compile with missing-glyph boxes.

Every factual figure, table, metric definition, and solution claim needs a nearby source marker. Distinguish team-reported values from independently measured values in the caption or prose.

## 2. Typst-native math

Write equations with Typst math delimiters and functions only. A `.typ` file must not contain LaTeX math delimiters `\(...\)` or `\[...\]`, or LaTeX commands such as `\mathrm`, `\text`, `\hat`, `\frac`, `\sum`, `\ln`, `\in`, `\lceil`, or `\begin`.

Translate source notation into native Typst before compiling:

```typst
// Correct Typst
$c in {"SCS", "NFN", "SS"}$
$y_(i k)$
$hat(z)$
$frac(sum_i w_i y_i, sum_i w_i)$
$-ln(1 - q_s)$
```

Do not paste these LaTeX forms into Typst:

```text
\(c\in\{\mathrm{SCS},\mathrm{NFN},\mathrm{SS}\}\)
\hat z
\frac{\sum_i w_i y_i}{\sum_i w_i}
```

Define every symbol next to the equation and visually inspect the rendered page, because successful compilation does not prove that pasted LaTeX became math. Run `scripts/validate_workspace.py` before both report and slide compilation; it rejects common LaTeX-only syntax recursively under `report/` and `slides/`.

## 3. Detailed report structure

Keep this order:

1. Title page
2. Table of contents
3. コンペの説明と概要
4. 評価指標とタスク
5. データの解説
6. 上位に共通する要素とその背景考察
7. 上位の中で差を分けた要素とその背景考察
8. どうやって戦えばよかったか
9. まとめ
10. Appendix: 金メダル圏それぞれの解法の概要とポイント
11. Evidence coverage, limitations, and references

The report may grow as needed. Do not compress evidence to hit an arbitrary page target.

Use total-aware page numbering such as `current / total`, and include at least heading levels 1 through 3 in the outline when useful.

### コンペの説明と概要

Explain the real-world problem, prediction unit, target, constraints, submission shape, timeline, and final ranking basis.

### 評価指標とタスク

Write the exact metric equation, define every symbol, state whether larger or smaller is better, and work through at least one small example. Explain averaging, weighting, clipping, thresholds, matching, ties, and edge cases when relevant. Connect metric behavior to modeling incentives.

### データの解説

Show train/test provenance, unit of independence, group structure, label generation, missingness, imbalance, annotation uncertainty, leakage risks, and likely distribution shift. Add a task/data-flow diagram.

### 上位に共通する要素

Start from the comparison matrix. Include occurrence counts with `unknown` separated from `no`. For each factor, present the mechanism chain and counterevidence.

### 上位の中で差を分けた要素

First compare top-gold and lower-gold using the frozen group definition. Then compare gold and upper-silver when coverage supports it. Do not claim separation from a feature that was merely unreported below.

### どうやって戦えばよかったか

Present a chronological, testable playbook. Explain how the winning ideas could have been generated from task/data/metric clues, what cheap tests would reject them, and which validation traps would mislead the participant.

## 4. Required technical devices

Use technical devices only when they improve understanding, but include all of these somewhere in the report:

- metric equation with symbol definitions and a numerical example
- task/data/evaluation flow diagram
- at least one representative solution pipeline diagram
- rank-by-factor comparison table
- one plot or table that exposes the most important data or metric property
- small code or pseudocode sample for a non-obvious transformation, loss, validation, inference, or postprocessing step

Label code as one of:

- `verbatim source excerpt` with a precise source and short excerpt
- `adapted from source` with changes stated
- `reconstructed pseudocode` when no executable source exists

Do not present reconstructed code as the team's implementation. Keep examples minimal and define array shapes, units, or indexing when these affect correctness.

Use diagrams to expose mechanisms, not decorate pages. A good diagram answers one question in its caption.

## 5. Gold-solution appendix

Create one subsection per gold team, in final-rank order. Each subsection contains:

- overview
- end-to-end solution pipeline
- key points
- explanation of why the points fit the task
- validation and reported gains
- reproducibility and evidence gaps
- links to the paired raw and organized Markdown

The silver-upper solutions remain fully documented in `solutions/` and feed the comparison, but do not require equally long report appendices unless the user asks.

## 6. Public slide structure

The deck should stand on its own while remaining much shorter than the report. Use this default narrative:

1. Title and source/coverage disclosure
2. Competition and task
3. Metric and its incentive
4. Data property that shaped the leaderboard
5. Common top-solution pattern
6. Why the common pattern worked
7. What separated top-gold from lower-gold
8. Gold vs upper-silver, if evidence permits
9. Representative pipeline
10. How to have discovered the key ideas
11. Practical playbook
12. Summary
13. References and limitations

Add or remove slides based on the competition, but preserve this causal arc:

`problem -> metric/data pressure -> solution pattern -> rank difference -> discoverable strategy`

Prefer one claim per slide. Keep body text readable at presentation distance. Move detail to speaker notes only if the chosen toolchain preserves them; otherwise leave it in the report.

### Slide content contract

Make each analytical slide answer four questions in order:

1. **Claim:** What should the audience conclude?
2. **Evidence:** Which exact count, score, rank example, equation, or paired comparison supports it?
3. **Mechanism:** Why does the evidence fit the task, data, validation, or metric?
4. **Implication:** What modeling or experimental decision follows?

Most analytical slides should contain at least two concrete evidence items. A title, two short panels, and a generic takeaway are not sufficient. Prefer compact comparison tables, annotated equations, mechanism diagrams, and rank-tagged examples over lists of labels. Keep evidence limitations on the same slide when they change the conclusion.

Omit an agenda and section-divider slides by default. Include them only for a long live presentation where navigation benefit exceeds the lost information space. Title, references, and explicit section dividers do not count as substantive slides.

### Visual hierarchy and color

Use a restrained semantic palette:

- one dark neutral for titles and primary text
- one accent color for the single strongest emphasis on a slide
- neutral gray and very pale fills for structure
- at most one secondary alert color, only when warning status cannot be expressed by label, icon, weight, or border

Do not color-code pipeline stages, comparison groups, or panels with unrelated hues. Establish hierarchy in this order: claim-oriented title, spatial position, font size, weight, rule or border, then color. If every panel is colored, none is emphasized. The contact-sheet view should make the intended reading order and the one primary emphasis target obvious.

### Default design system

Use the bundled `assets/workspace-template/slides/theme.typ` as the canonical starting point. Keep these defaults unless the user provides a different public brand:

| role | default | use |
|---|---|---|
| canvas | white | content slides |
| title bar / title slide | dark ink `#263238` | stable frame and contrast |
| primary accent | teal `#00796b` | one selected claim or action |
| structural text | gray `#6b777c` | captions, borders, secondary labels |
| neutral surface | `#f4f7f8` | ordinary panels |
| accent surface | `#e9f3f1` | the single emphasized block |

Do not change the palette per slide. If a competition-specific accent is needed, replace teal once in `theme.typ`; do not add parallel hues in `slides.typ`.

Use the bundled primitives consistently:

- `lesson(title)[body]`: claim-oriented content slide
- `claim[body]`: the primary statement; normally zero or one per slide
- `panel(title)[body]`: neutral grouping, not decoration
- `stat(value, label, detail: ...)`: one exact number with context
- `comparison(...)`: symmetric two-sided comparison using labels, not colors
- `takeaway[body]`: the modeling or experimental implication
- `source-note[body]`: compact right-aligned evidence marker
- `table-fill` and `table-rule`: shared table header and border styling

### Typography and spacing

- Use 28–30 pt for the title slide title and the Metropolis heading scale for content titles.
- Use 15–17 pt for ordinary content, 11.5–13.5 pt for dense tables, and 7.5–9 pt only for sources or footers.
- Do not shrink analytical prose below 11.5 pt to fit a slide; split or simplify the slide.
- Use 16–20 pt gutters for two-column layouts and 8–12 pt between compact pipeline stages.
- Keep panels aligned to a shared grid. Avoid arbitrary offsets, floating labels, and boxes with inconsistent inset.
- Prefer a small number of larger blocks. More than three peer panels usually destroys hierarchy.
- Balance whitespace above and below the content group. Do not pin a short body immediately under the title while leaving the lower half empty.
- Use the default flexible vertical spacing in `lesson`; it moves sparse content toward the visual center and collapses for dense slides. Use `pin-top: true` only when a tall table or figure genuinely needs the full height.
- Aim for the content group's visual center near the middle of the usable canvas. A slightly upper center is acceptable because the title bar adds visual weight, but the body should not end near the midline on an otherwise empty slide.

### Composition recipes

Use one of these layouts instead of composing every slide from scratch:

1. **Claim + evidence:** one `claim`, one compact table or equation, then `takeaway` and `source-note`.
2. **Metric:** centered native Typst equation, one interpretation table, one implication bar.
3. **Comparison:** symmetric columns or a four-column evidence table; encode strength in text, not hue.
4. **Pipeline:** three to five aligned steps with only the bottleneck emphasized; add the train–test gap below.
5. **Data property:** exact count, denominator, modeling consequence, and provenance on the same slide.
6. **Negative result:** paired intervention/control evidence, followed by the acceptance rule.

Do not use colored cards as the primary organizing idea. A card is justified only when it groups information that must be read together. Prefer tables for repeated fields and equations or diagrams for mechanisms.

### Design QA

Judge the full-resolution pages and a contact sheet. A deck passes only when:

- every slide has an obvious first reading target within one second
- only one block per slide uses the accent surface or accent border
- all saturated colors across the deck are limited to the primary accent and, when essential, one alert color
- titles state conclusions rather than section names such as `Data` or `Patterns`
- tables remain readable at presentation distance and normally contain no more than eight body rows
- sources stay visually subordinate but legible
- empty space supports grouping; it does not expose missing evidence or a thin argument
- upper and lower whitespace feel intentional; the content mass is not visibly stuck to the title bar
- the deck remains understandable in grayscale because labels and structure carry meaning

## 7. Public-release rules

The public deck must not contain:

- Kaggle credentials, tokens, local usernames, or private filesystem paths
- raw comment dumps or long verbatim post excerpts
- private notebook contents or inaccessible artifacts
- participant claims stated as verified facts
- personal speculation without an `inference` label
- copyrighted figures copied without a permitted source and attribution

Redraw mechanisms from facts when appropriate and cite the underlying sources. Use stable official URLs. Add a coverage slide or footer that states the included rank range and number of unavailable/partial solutions.

## 8. Compilation and visual QA

Compile from the workspace root so includes and figures resolve consistently:

```bash
typst compile --root <workspace> <workspace>/report/main.typ <workspace>/report/report.pdf
typst compile --root <workspace> <workspace>/slides/slides.typ <workspace>/slides/slides.pdf
```

Before compiling, run the workspace validator and require zero Typst-source math errors:

```bash
uv run --python 3.11 scripts/validate_workspace.py <workspace>
```

After compiling both PDFs, rerun the same command with `--require-pdf`.

Then render every PDF page to an image. Inspect:

- glyphs and Japanese line breaking
- page number and total page count
- outline entries and destinations
- heading hierarchy and orphan headings
- equations, symbol definitions, and line overflow
- table width, repeated headers, and tiny text
- figure labels, captions, source markers, and resolution
- code wrapping and syntax visibility
- slide clipping, density, contrast, and footer collisions
- raw LaTeX delimiters or commands rendered as ordinary text
- color competition: multiple saturated panels with no dominant emphasis
- thin content: a claim without exact evidence, mechanism, or decision consequence
- layout drift: inconsistent panel insets, table rules, gutters, or source placement
- vertical imbalance: a short content group occupies only the upper half while the lower half remains unused
- grayscale ambiguity: comparison or status communicated by hue alone
- dead links and accidental local paths

Do not accept a successful compile as visual success. Fix, recompile, rerender, and inspect until all pages are usable.

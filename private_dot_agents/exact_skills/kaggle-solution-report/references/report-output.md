# Detailed Typst report contract

## Contents

1. Output and source rules
2. Typst-native math
3. Required report structure
4. Required technical devices
5. Gold-solution appendix
6. Compilation and visual QA

## 1. Output and source rules

Create an A4 portrait Typst report. It may grow as needed; do not compress evidence to meet an arbitrary page target.

Use total-aware page numbering such as `current / total`, add a table of contents, and include heading levels 1 through 3 in the outline when useful. Put a nearby source marker on every factual figure, table, metric definition, and solution claim. Distinguish participant-reported values from independently measured values in the caption or prose.

Use 10–11 pt for A4 body prose, 8.5–9.5 pt for diagram labels, and 7.5–8.5 pt for captions and sources. Never shrink body prose below 9.5 pt or diagram labels below 8 pt to fit. Enlarge or split the figure at a real processing boundary instead.

## 2. Typst-native math

Write equations with Typst math delimiters and functions only. A `.typ` file must not contain LaTeX delimiters `\(...\)` or `\[...\]`, or LaTeX commands such as `\mathrm`, `\text`, `\hat`, `\frac`, `\sum`, `\ln`, `\in`, `\lceil`, or `\begin`.

Translate source notation into native Typst before compiling:

```typst
// Correct Typst
$c in {"SCS", "NFN", "SS"}$
$y_(i k)$
$hat(z)$
$frac(sum_i w_i y_i, sum_i w_i)$
$-ln(1 - q_s)$
```

Never paste forms such as these into Typst:

```text
\(c\in\{\mathrm{SCS},\mathrm{NFN},\mathrm{SS}\}\)
\hat z
\frac{\sum_i w_i y_i}{\sum_i w_i}
```

Define every symbol next to its equation and inspect the rendered page. Successful compilation does not prove that pasted LaTeX became math. Run `<skill-root>/scripts/validate_workspace.py` before compilation; it rejects common LaTeX-only syntax in every workspace Typst source, including shared figures.

## 3. Required report structure

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

Present a chronological, testable playbook. Explain how the winning ideas could have been generated from task, data, and metric clues, what cheap tests would reject them, and which validation traps would mislead the participant.

## 4. Required technical devices

Use technical devices only when they improve understanding, but include all of these somewhere in the report:

- metric equation with symbol definitions and a numerical example
- task/data/evaluation flow diagram
- one team-specific end-to-end pipeline diagram for every method-bearing gold team, including partial evidence with explicit unknowns
- rank-by-factor comparison table
- one plot or table that exposes the most important data or metric property
- small code or pseudocode sample for a non-obvious transformation, loss, validation, inference, or postprocessing step

Label code as one of:

- `verbatim source excerpt` with a precise source and short excerpt
- `adapted from source` with changes stated
- `reconstructed pseudocode` when no executable source exists

Do not present reconstructed code as the team's implementation. Keep examples minimal and define array shapes, units, or indexing when these affect correctness. Use diagrams to expose mechanisms, not decorate pages; a useful diagram answers one question in its caption.

## 5. Gold-solution appendix

Create one subsection per gold team, in final-rank order. Include:

- overview
- for a method-bearing team, an end-to-end solution pipeline as both prose and a source-backed whole-solution figure; for a fully unavailable team, an explicit evidence-gap statement instead of a guessed figure
- key points
- explanation of why the points fit the task
- validation and reported gains
- reproducibility and evidence gaps
- links to the paired raw and organized Markdown

Keep upper-silver solutions fully documented under `solutions/` and use them in comparisons. They do not need equally long report appendices unless the user asks.

Each gold-team figure must let a reader recover the method at a glance before reading the detailed prose. Apply the topology, uncertainty, layout, and legibility contract in `diagram-design.md`.

Keep one shared Typst rendering source under `figures/` and import or parameterize it for the report and slides. The organized Markdown topology record is the semantic source of truth; the shared Typst is its single rendering implementation. A cross-team comparison figure may follow later; it does not satisfy the per-team figure requirement.

## 6. Compilation and visual QA

Use the mise-managed Typst toolchain. Compare `mise exec -- typst --version` with `mise latest typst` before the first compile. Unless the workspace pins an older compiler, install and select the latest stable Typst with mise, record the used version in `scope/scope.md`, and compile with that version. Check the minimum compiler version of imported Typst Universe packages.

Compile from the workspace root:

```bash
uv run --python 3.12 <skill-root>/scripts/validate_workspace.py <workspace>
mise exec -- typst compile --root <workspace> <workspace>/report/main.typ <workspace>/report/report.pdf
uv run --python 3.12 <skill-root>/scripts/validate_workspace.py <workspace> --require-pdf
```

Render every report page and inspect:

- glyphs and Japanese line breaking
- current/total page numbers and table-of-contents destinations
- heading hierarchy and orphan headings
- equations, symbol definitions, and line overflow
- table width, repeated headers, and text size
- figure labels, captions, source markers, and resolution
- code wrapping and syntax visibility
- raw LaTeX rendered as text
- dead links and accidental local paths

Fix, recompile, rerender, and inspect until every page is usable.

---
name: kaggle-solution-report
description: "Use when the user wants a completed Kaggle competition's gold-medal and upper-silver solutions collected from Kaggle discussions and linked artifacts, preserved as paired raw and synthesized Markdown, compared across ranks, and published as a detailed Japanese Typst report plus a public Polylux Metropolis slide deck. Do not use for one solution summary, live-competition advice, ordinary Kaggle research, or experiment execution."
---

# Kaggle Solution Report

Create an evidence-traceable archive, a long-form report, and a public slide deck for one completed Kaggle competition. Treat coverage and unavailable evidence as first-class outputs; never reconstruct a missing solution from rank, comments, or common practice.

## Required inputs

Resolve these before bulk collection:

- competition slug and official URL
- output directory and report language
- final leaderboard to use
- exact upper-silver boundary as either a maximum rank or a team count

Use the final private leaderboard. If medals were not awarded, the leaderboard is not final, or the upper-silver boundary is missing, stop before bulk collection and ask for the one decision that changes scope.

## Load the references

Read all four references before acting:

1. `references/workflow.md` for collection, evidence, coverage, and analysis rules.
2. `references/schemas.md` for the exact workspace and Markdown contracts.
3. `references/typst-output.md` for the report, slide, citation, diagram, and visual-QA contract.
4. `references/japanese-report-writing.md` for reader-tailored Japanese explanatory prose and the boundary between new drafting and revision.

## Initialize the workspace

Run:

```bash
uv run --python 3.11 scripts/init_workspace.py \
  --competition <slug> \
  --title "<competition title>" \
  --output <output-directory>
```

The script copies `assets/workspace-template/`. Preserve its directory names because validation relies on them.

## Kaggle access

Prefer an installed NVIDIA Kaggle Skill when it can return official Kaggle topic bodies, comments, leaderboard evidence, or linked notebooks with stable identifiers. Otherwise use `scripts/kaggle_uv` for every Kaggle CLI command. Do not invoke a bare `kaggle` executable.

```bash
scripts/kaggle_uv --version
scripts/kaggle_uv competitions topics list <slug> --sort-by top --format json --quiet
```

Keep access read-only. Never print, copy, inspect, or commit Kaggle credentials. Use the web only for official pages or linked primary artifacts that the CLI or NVIDIA Skill does not expose.

## Execute the gated workflow

### Gate 1: Freeze scope

Populate `scope/coverage.csv` with every gold team and every team in the explicit upper-silver band. Map by final team rank, not individual member. Define the top-gold/lower-gold split in `scope/scope.md` before reading methods deeply.

Do not proceed until each selected rank has one row and every row has a stable team label.

### Gate 2: Preserve raw evidence

For every selected team, create exactly this pair:

- `solutions/rank-NNN-team-slug-raw.md`
- `solutions/rank-NNN-team-slug.md`

Put the retrieved solution post and all retrieved comments in the raw file without paraphrasing their content. Record missing post bodies, pagination, inaccessible links, and discovery queries in the same file. Use `scripts/render_topic_raw.py` when the Kaggle CLI returned JSON.

When no public write-up exists, still create both files. The raw file must contain the search log; the organized file must say that the method is unavailable rather than infer it.

### Gate 3: Organize each solution

Complete the required headings from `references/schemas.md`. Separate direct evidence, participant claims, and inference. Explain the method as a pipeline and connect each claimed gain to its evaluation setting. Keep equations, diagrams, and code faithful to sources; label reconstructed pseudocode as reconstructed.

When writing Japanese explanatory prose, apply the new-draft mode in `references/japanese-report-writing.md`. Do not copyedit the raw file: it is an evidence archive, not a manuscript.

Do not start the cross-solution synthesis until every scoped row is `complete`, `partial`, or `unavailable` and has both Markdown files.

### Gate 4: Synthesize across ranks

Build the comparison matrix before prose. Analyze:

- factors common across the full scoped top field
- factors separating top-gold from lower-gold
- factors separating gold from upper-silver, when evidence permits
- why each factor fits the task, data, validation regime, and metric
- how a participant could have discovered the factor without hindsight

For every causal-looking conclusion, use the chain:

`task/data/metric property -> failure mode or incentive -> solution element -> expected effect -> observed evidence -> uncertainty`

Search non-solution discussions for organizer clarifications, data quirks, metric behavior, validation failures, leakage, shake-up, and negative results. Preserve those discussions under `sources/discussions/` and register claims in `sources/evidence-ledger.md`.

Draft the Japanese synthesis only after the matrix and evidence ledger are stable. Use the paragraph contract in `references/japanese-report-writing.md` so each paragraph carries one claim from observation through mechanism to implication without hiding uncertainty.

### Gate 5: Build the Typst report

Write the detailed report under `report/`. It may be long. Follow the mandatory section order and Appendix policy in `references/typst-output.md`. Include total-aware page numbers, a table of contents, metric equations, informative diagrams, comparison tables, and small code samples.

Use `references/japanese-report-writing.md` as the prose contract. For a new report or section, use its new-draft mode. Use its revision mode only when an existing manuscript is explicitly being rewritten or concrete review feedback is being incorporated; do not automatically run a second generic rewrite pass after drafting. Preserve verified facts, evidence labels, citations, numerical values, and the required section order during revision.

Write every equation in native Typst math syntax. Never paste LaTeX delimiters such as `\(...\)` or `\[...\]`, and never leave LaTeX commands such as `\mathrm`, `\hat`, `\frac`, or `\sum` in a `.typ` file. Translate source equations while preserving their meaning, then run the workspace validator before compiling.

Compile with:

```bash
typst compile --root <workspace> <workspace>/report/main.typ <workspace>/report/report.pdf
```

### Gate 6: Build the public slide deck

Derive the deck from the verified report, not directly from raw discussions. Use Polylux with `metropolis-polylux`, follow the local `~/MyVault/slides` font conventions when available, and remove private paths, credential details, raw comment dumps, and unsupported claims. Start from the bundled `slides/theme.typ`; reuse its claim, panel, statistic, comparison, implication, table, and source-note primitives instead of inventing a new visual system for each competition.

Use one semantic accent color plus neutral tones. Establish emphasis through the claim title, position, size, weight, and whitespace before adding color; do not assign a different hue to every stage or panel. Make analytical slides self-contained: state the claim, show concrete evidence, explain the mechanism or comparison, and end with the implication and source. Omit decorative agenda and section-divider slides unless they materially help navigation.

Compile with:

```bash
typst compile --root <workspace> <workspace>/slides/slides.typ <workspace>/slides/slides.pdf
```

### Gate 7: Validate and visually inspect

Run:

```bash
uv run --python 3.11 scripts/validate_workspace.py <workspace> --require-pdf
```

Render both PDFs to page images and inspect every page. Fix clipped content, unreadable figures, orphan headings, code overflow, broken links, empty pages, and slide density. Recompile and rerun validation after fixes.

The validator must report no LaTeX-only delimiters or commands in any report or slide `.typ` source. In the slide contact sheet, confirm that one emphasis target is visually dominant and that substantive slides contain evidence rather than only a short takeaway.

## Completion contract

Finish only when:

- scope covers every selected rank with no silent omissions
- every solution has a raw/organized Markdown pair
- missing evidence remains explicitly missing
- synthesis distinguishes observation from inference
- task, data, validation, and metric explain the conclusions
- Japanese prose satisfies the reader, terminology, paragraph, and uncertainty checks in `references/japanese-report-writing.md`
- report and slides compile and pass visual inspection
- public slides contain citations and no raw/private material

Report the coverage counts, unavailable/partial solutions, PDF paths, page counts, and validation result to the user.

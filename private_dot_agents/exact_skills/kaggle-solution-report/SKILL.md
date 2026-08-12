---
name: kaggle-solution-report
description: "Use for end-to-end research, publication, or later revision of a completed Kaggle competition solution report covering multiple top teams through gold and upper-silver. Preserve each scoped solution and comments as paired raw/organized Markdown, compare methods, and create a source-backed Japanese Typst report plus public Polylux deck. Do not use for one-solution summaries, bounded Kaggle lookups, live-competition advice, or experiment execution."
---

# Kaggle Solution Report

Produce three traceable outputs for one completed competition:

1. one raw and one organized Markdown file for every scoped team;
2. a detailed Japanese Typst report;
3. a public 16:9 Polylux Metropolis slide deck derived from the verified report.

Keep missing evidence missing. Never reconstruct an unavailable solution from rank, comments, or common practice.

## Required inputs

Resolve these before bulk collection:

- competition slug and official URL
- output directory
- final private leaderboard and medal status
- exact upper-silver boundary as a maximum rank or team count
- report language, intended reader, and public audience

If the leaderboard is not final, medals were not awarded, or the upper-silver boundary is unknown, stop before bulk collection and ask for the one decision that changes scope.

## Load only the reference needed for the current phase

Do not read every reference at startup. Read each selected file completely before performing that phase.

| Phase | Read |
|---|---|
| scope, final ranks, Kaggle discovery, raw collection | [collection-workflow.md](references/collection-workflow.md) |
| workspace paths and raw/organized Markdown contracts | [schemas.md](references/schemas.md) |
| per-solution analysis, comparison, task grounding, retrospective | [analysis-workflow.md](references/analysis-workflow.md) |
| evidence labels and non-inference rules | [evidence-rules.md](references/evidence-rules.md) |
| Japanese synthesis, report drafting, or prose revision | [japanese-report-writing.md](references/japanese-report-writing.md) |
| report structure, Typst math, appendix, report QA | [report-output.md](references/report-output.md) |
| reusable-learning narrative and team/factor synthesis for slides | [retrospective-learning-design.md](references/retrospective-learning-design.md) |
| slide composition, typography, color, spacing, public QA | [slide-design.md](references/slide-design.md) |
| diagrams, plots, arrows, nodes, or spatial schematics | [diagram-design.md](references/diagram-design.md) |
| final independent review across evidence, Japanese prose, diagrams, and cross-artifact parity | [release-review.md](references/release-review.md) |

For a full run, read references as their phases begin. For a local revision, read only the relevant reference plus any directly affected source file; for example, a diagram-only slide fix needs `slide-design.md` and `diagram-design.md`, not the collection or report references.

Resolve every `scripts/...`, `assets/...`, and `references/...` path relative to the directory containing this `SKILL.md`, regardless of the current working directory. In commands, substitute that directory for `<skill-root>`.

Before revising an older workspace, read the migration note in `schemas.md` and run:

```bash
uv run --python 3.12 <skill-root>/scripts/migrate_workspace.py <workspace>
```

The migration only adds current scaffolding. Resolve scope TODO values and evidence-dependent `method_status` values, update moved figure imports, and rerun incomplete discovery gates before publication; never fill them mechanically.

## Initialize the workspace

Run the deterministic initializer:

```bash
uv run --python 3.12 <skill-root>/scripts/init_workspace.py \
  --competition <slug> \
  --title "<competition title>" \
  --output <output-directory>
```

Preserve the generated directory names because validation depends on them.

## Execute the gated workflow

### 1. Freeze scope

Read `collection-workflow.md` and `schemas.md`. Write `scope/scope.md` and one `scope/coverage.csv` row for every selected final team rank. Define the upper-silver boundary and top-gold/lower-gold split before reading methods deeply.

Output: a stable rank-to-team coverage manifest with no omitted selected rank.

### 2. Preserve raw evidence

Read `collection-workflow.md` and `evidence-rules.md`. Use an installed NVIDIA Kaggle Skill when it exposes stable official topic bodies, comments, leaderboard evidence, or linked artifacts. Otherwise use `scripts/kaggle_uv`; never invoke bare `kaggle`. Keep access read-only and never display, copy, or commit credentials.

Use the bundled scripts for fragile retrieval operations:

- `scripts/collect_topic_raw.py` for one topic and all comment pages;
- `scripts/combine_topic_raw.py` when one team has multiple team-authored solution topics;
- `scripts/render_topic_raw.py` only when assembling already retrieved representations manually.

Create exactly one `solutions/rank-NNN-team-slug-raw.md` and one `solutions/rank-NNN-team-slug.md` per selected team. Preserve the post and all retrieved comments without paraphrasing in raw files. If no public solution is found, still create both files and record the search log and unavailable status.

Output: a complete raw/organized pair for every coverage row.

### 3. Organize each solution

Read `schemas.md`, `analysis-workflow.md`, `evidence-rules.md`, and `japanese-report-writing.md`. Explain each method as an end-to-end pipeline and complete every required heading. Separate directly observed evidence, organizer statements, participant reports, reproduction, inference, and unavailable evidence. Attach each numerical gain to its metric, split, baseline, and evidence status.

Do not rewrite raw evidence. Do not start cross-team synthesis until every coverage row is `complete`, `partial`, or `unavailable` and has both Markdown files.

Output: one evidence-labeled technical explanation per team.

### 4. Compare teams and explain the task

Read `analysis-workflow.md`, `evidence-rules.md`, and `japanese-report-writing.md`. Build `synthesis/comparison-matrix.md` before prose, then analyze:

- common elements across method-bearing scoped teams;
- top-gold versus lower-gold differences;
- gold versus upper-silver differences when coverage supports them;
- why each factor fits the task, data, validation regime, and metric;
- how a participant could have discovered and tested it without hindsight.

For every causal claim, preserve this chain:

`task/data/metric property -> failure mode or incentive -> solution element -> expected effect -> observed evidence -> uncertainty`

Search non-solution discussions for data properties, label generation, metric behavior, validation failure, leakage, shake-up, organizer clarification, and negative results. Preserve them under `sources/discussions/` and register claims in `sources/evidence-ledger.md`.

Output: stable comparison, common-element, differentiator, task-grounded, and strategy-retrospective synthesis files.

### 5. Build the detailed report

Read `japanese-report-writing.md`, `report-output.md`, and `diagram-design.md`. Draft from the organized solutions and stable synthesis, never directly from unreviewed raw posts. Use native Typst math, nearby source markers, the required section order, total-aware page numbers, table of contents, technical figures, code samples, and gold-team appendix.

Create one team-specific end-to-end pipeline figure for every method-bearing gold team. A partial solution is still method-bearing when at least one team-attributable real processing path can be drawn; preserve unknown connections explicitly. A cross-team comparison figure or a generic stage strip does not satisfy this requirement.

Output: `report/report.pdf` and its Typst sources.

### 6. Build the public slide deck

Read `retrospective-learning-design.md` and `slide-design.md`. Read `diagram-design.md` only when creating or editing a figure. Derive the deck from verified report claims and evidence.

Make the deck useful for the next similar competition: preserve each method-bearing gold team in an end-to-end block, retain upper-silver evidence in factor-level synthesis, reorganize evidence by bottleneck, distinguish entry conditions from rank differentiators, reconstruct `clue -> hypothesis -> cheapest test -> result -> decision -> transfer boundary`, and include negative or non-reproduced results when evidence exists.

Follow the page and salience contracts in `slide-design.md`; treat diagrams, tables, and emphasis as choices rather than page-completion requirements.

Give every method-bearing gold team its own whole-solution overview figure before the detailed team pages. Reuse the shared rendering derived from the organized semantic topology so the two artifacts cannot silently describe different pipelines.

Output: `slides/slides.pdf` and its Typst sources, containing no private paths, credentials, raw comment dumps, or unsupported public claims.

### 7. Validate and inspect

Run:

```bash
uv run --python 3.12 <skill-root>/scripts/validate_workspace.py <workspace>
mise exec -- typst compile --root <workspace> <workspace>/report/main.typ <workspace>/report/report.pdf
mise exec -- typst compile --root <workspace> <workspace>/slides/slides.typ <workspace>/slides/slides.pdf
uv run --python 3.12 <skill-root>/scripts/validate_workspace.py <workspace> --require-pdf
```

Render every report and slide page. Inspect full-resolution pages for legibility and geometry, and inspect a slide contact sheet for narrative rhythm and visual hierarchy. Fix, recompile, rerender, and revalidate after every meaningful change.

For a full run or a broad revision, read `release-review.md` and perform four independent read-only review passes after self-QA: evidence accuracy, Japanese terminology and explanation, rendered geometry, and report/slide parity. Apply accepted fixes in the main workflow, then rerun the affected reviews and all deterministic validation.

## Completion contract

Finish only when:

- every selected rank has a coverage row and raw/organized pair;
- unavailable and partial evidence remains explicit;
- synthesis distinguishes observation from inference and common conditions from differentiators;
- task, data, validation, and metric explain the conclusions;
- Japanese prose passes the reader, terminology, paragraph, and uncertainty checks;
- every complete or partial method-bearing scoped team has a persisted semantic topology and an organized Markdown diagram;
- every method-bearing gold team has a source-backed whole-solution figure in both report and slides, while unavailable topologies remain explicit;
- report and slides compile, validate, and pass rendered visual inspection;
- for a full run or broad revision, independent release review finds no unresolved high- or medium-priority issue;
- public slides contain citations and no raw or private material.

Report coverage counts, unavailable/partial ranks, output paths, page counts, and validation results to the user.

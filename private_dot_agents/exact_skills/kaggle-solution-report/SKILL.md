---
name: kaggle-solution-report
description: "Use for end-to-end research, publication, or later revision of a completed Kaggle competition solution report covering multiple top teams through gold and upper-silver. Preserve each scoped solution and comments as paired raw/organized Markdown, compare methods, and create a source-backed Japanese Typst report plus public Polylux deck. Do not use for one-solution summaries, bounded Kaggle lookups, live-competition advice, or experiment execution."
---

# Kaggle Solution Report

Produce five traceable outputs for one completed competition:

1. one raw and one organized Markdown file for every scoped team;
2. an audited ledger of every linked notebook, repository, paper, dataset, model, or external write-up discovered in scoped evidence;
3. a publication-evidence map that records which mechanisms, experiments, failures, and limitations are included or deliberately excluded;
4. a detailed Japanese Typst report;
5. a public 16:9 Polylux Metropolis slide deck derived from the verified report.

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
| general topic-to-understanding-deck workflow | sibling Skill `../topic-learning-slides/SKILL.md` and the phase references it selects |
| Kaggle-specific learning narrative and team/factor adapter | [retrospective-learning-design.md](references/retrospective-learning-design.md) |
| Kaggle-specific slide composition and public-release adapter | [slide-design.md](references/slide-design.md) |
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

Inventory every linked technical artifact in `sources/artifact-ledger.csv`. Material artifacts must be inspected and preserved locally, or marked unavailable with the failed access recorded. Non-material links need an explicit exclusion reason. Do not treat retrieval of the discussion body as completion while linked notebooks or repositories remain unaudited.

Output: a complete raw/organized pair for every coverage row and a closed artifact ledger.

### 3. Organize each solution

Read `schemas.md`, `analysis-workflow.md`, `evidence-rules.md`, and `japanese-report-writing.md`. Explain each method as an end-to-end pipeline and complete every required heading. Separate directly observed evidence, organizer statements, participant reports, reproduction, inference, and unavailable evidence. Attach each numerical gain to its metric, split, baseline, and evidence status.

Do not rewrite raw evidence. Do not start cross-team synthesis until every coverage row is `complete`, `partial`, or `unavailable` and has both Markdown files.

For each team, finish `外部Artifactの監査` and promote every consequential mechanism, validation result, ablation, failed idea, reasoning turn, reproducibility fact, and evidence limitation into `synthesis/publication-evidence.csv`. Do not decide slide length yet; first make the available evidence visible and dispositionable.

Output: one evidence-labeled technical explanation per team and a publication-candidate inventory with no silent omissions.

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

After synthesis, finalize every publication-evidence row as report-included/excluded and slide-included/factor-only/excluded. Every exclusion needs a reason. A method-bearing gold team must retain a whole pipeline, a central decision, and evidence that calibrates trust; richer sources may require several independent detail pages. Page count is never a substitute for this evidence coverage.

Output: stable comparison, common-element, differentiator, task-grounded, and strategy-retrospective synthesis files plus a closed publication-evidence map. Together with the organized solutions, coverage manifest, and official task/data/metric evidence, these files form the verified research packet passed to `topic-learning-slides`.

### 5. Build the detailed report

Read `japanese-report-writing.md`, `report-output.md`, and `diagram-design.md`. Draft from the organized solutions and stable synthesis, never directly from unreviewed raw posts. Use native Typst math, nearby source markers, the required section order, total-aware page numbers, table of contents, technical figures, code samples, and gold-team appendix.

Create one team-specific end-to-end pipeline figure for every method-bearing gold team. A partial solution is still method-bearing when at least one team-attributable real processing path can be drawn; preserve unknown connections explicitly. A cross-team comparison figure or a generic stage strip does not satisfy this requirement.

Output: `report/report.pdf` and its Typst sources.

### 6. Build the public slide deck

Resolve the sibling installed Skill at `<skill-root>/../topic-learning-slides/SKILL.md`, read it completely, and follow its selected phase references. Treat the completed competition as the topic and pass the verified research packet from steps 1–5 as its starting evidence. Do not repeat broad collection inside the slide phase; research only a concrete gap exposed by its C2 evidence checkpoint.

Before running the chained workflow, record these resolved mappings in `reviews/topic-slide-checkpoints.md`. Do not rely on an implied phrase such as “reuse the research packet”:

| chained role | canonical Kaggle artifact |
|---|---|
| `scope_artifact` | `scope/scope.md` |
| `source_ledger` | `sources/evidence-ledger.md` plus `sources/artifact-ledger.csv` |
| `claim_ledger` | `sources/evidence-ledger.md` for stable claim IDs; `synthesis/publication-evidence.csv` for report/slide disposition |
| `evidence_packet` | official competition sources, paired solution files, preserved discussions/artifacts, and stable synthesis files |
| `checkpoint_log` | `reviews/topic-slide-checkpoints.md` |
| `terminology_ledger` | `synthesis/terminology.md` |
| `prose_reconstruction` | `reviews/prose-reconstruction.csv` |

The Kaggle caller owns its established evidence vocabulary. Use this crosswalk only to interpret the generic checks; do not rename or duplicate ledger rows:

| generic meaning | Kaggle label |
|---|---|
| `official-or-organizer` | `organizer-confirmed` |
| `author-reported` | `participant-reported` |
| `directly-observed` | `directly-observed` |
| `independently-reproduced` | `independently-reproduced` |
| `inference` | `inference` |
| `unavailable` | `unavailable` |

Map the generic workflow to this competition:

| `topic-learning-slides` artifact | Kaggle input |
|---|---|
| scope and central question | reuse `scope/scope.md`; explain why the top solutions fit this task and what a participant should test next time |
| source and claim evidence | reuse official pages, paired solution evidence, `sources/` ledgers, discussion evidence, and `synthesis/publication-evidence.csv`; do not duplicate them into a second ledger |
| broad issue map | write `synthesis/argument-map.md`: task/data/metric pressure -> failure modes -> solution families -> common conditions and differentiators |
| slide outline and terminology | write `synthesis/slide-outline.md` and `synthesis/terminology.md` |
| checkpoint review | append authoritative C1–C6 attempts to `reviews/topic-slide-checkpoints.md`; never duplicate pass/fail state in synthesis files |
| detailed references | complete Gold solution blocks in rank order, followed by requested Upper Silver blocks |
| evidence limits | unavailable/partial ranks, participant-only results, missing artifacts, and non-reproduced gains |

Run C1–C6 from `topic-learning-slides`, including C2a before the issue map and C2b after it. Record C5 reconstructions in `reviews/prose-reconstruction.csv`. Then read `retrospective-learning-design.md` and `slide-design.md` as Kaggle-specific adapters. Read `diagram-design.md` only when creating or editing a figure. Derive the deck from verified report claims and evidence.

Compute each checkpoint artifact hash with the chained Skill's deterministic helper:

```bash
uv run --python 3.12 <skill-root>/../topic-learning-slides/scripts/checkpoint_hash.py \
  <workspace> "<semicolon-separated-artifact-paths>"
```

Append a new attempt whenever an artifact changes; do not edit a prior passing row to match the new hash.

Separate analysis order from reading order. Analyze every team end to end before cross-team synthesis, but normally present the public deck from abstraction to detail: establish the task and baseline, show how the solutions relate by bottleneck and strategy, derive common conditions, differentiators, counterexamples, and a reusable playbook, state coverage limits, and only then provide the complete team-by-team solution blocks as a reference section. Keep the opening synthesis understandable without requiring the reader to have memorized the later team pages, and make every abstract claim traceable to named ranks and later solution blocks.

Make the deck useful for the next similar competition: preserve each method-bearing gold team in an end-to-end reference block, retain upper-silver evidence in factor-level synthesis, reorganize evidence by bottleneck, distinguish entry conditions from rank differentiators, reconstruct `clue -> hypothesis -> cheapest test -> result -> decision -> transfer boundary`, and include negative or non-reproduced results when evidence exists. Do not use the abstract-first order to synthesize before the team evidence is stable or to replace real pipelines with a fictitious average solution.

Build from `synthesis/publication-evidence.csv`. Every core gold item must appear on a named slide; supporting or contextual items may be excluded only with a recorded rationale. Do not compress independent mechanisms, experiments, or reasoning turns into one memorable trick merely to shorten the deck.

Follow the page and salience contracts in `slide-design.md`; treat diagrams, tables, and emphasis as choices rather than page-completion requirements.

Give every method-bearing gold team its own whole-solution overview figure before the detailed team pages. Reuse the shared rendering derived from the organized semantic topology so the two artifacts cannot silently describe different pipelines.

After the generic C6 deck check, run a Kaggle adapter check:

- the rank scope and complete/partial/unavailable counts match `coverage.csv`;
- every abstract factor names the supporting teams and remains consistent with `comparison-matrix.md`;
- every method-bearing Gold team retains its exact end-to-end topology, central decision, evidence status, and unknowns;
- every core publication-evidence row has a named slide location;
- report and slides preserve the same terminology, numbers, branches, and uncertainty;
- the deck explains the solution space before the detailed blocks without replacing team-specific evidence with a fictitious average solution.

If the adapter check fails, return to the earliest relevant generic checkpoint: C2 for missing evidence, C3 for an incorrect issue map, C4 for narrative order, C5 for Japanese logic, or C6 for rendering. Record the correction and rerun downstream checkpoints.

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

For a full run or a broad revision, read `release-review.md` and perform five independent read-only review passes after self-QA: available-evidence saturation and artifact coverage, evidence accuracy, Japanese terminology and explanation, rendered geometry, and report/slide parity. Apply accepted fixes in the main workflow, then rerun the affected reviews and all deterministic validation.

## Completion contract

Finish only when:

- every selected rank has a coverage row and raw/organized pair;
- unavailable and partial evidence remains explicit;
- synthesis distinguishes observation from inference and common conditions from differentiators;
- every candidate technical artifact is inspected, explicitly unavailable, or explicitly non-material;
- every consequential available evidence item has a report and slide disposition, with reasons for exclusions;
- task, data, validation, and metric explain the conclusions;
- Japanese prose is revised in the order of technical meaning, logical completeness, sentence structure, terminology, and surface notation, and passes the reader, paragraph, and uncertainty checks;
- every complete or partial method-bearing scoped team has a persisted semantic topology and an organized Markdown diagram;
- every method-bearing gold team has a source-backed whole-solution figure in both report and slides, while unavailable topologies remain explicit;
- report and slides compile, validate, and pass rendered visual inspection;
- the `topic-learning-slides` C1–C6 checkpoints pass for the public deck, followed by the Kaggle adapter check;
- for a full run or broad revision, independent release review finds no unresolved high- or medium-priority issue;
- available-evidence saturation review confirms that raw posts, comments, and inspected artifacts contain no unaccounted core mechanism, experiment, failure, or reasoning turn;
- public slides contain citations and no raw or private material.

Report coverage counts, unavailable/partial ranks, output paths, page counts, and validation results to the user.

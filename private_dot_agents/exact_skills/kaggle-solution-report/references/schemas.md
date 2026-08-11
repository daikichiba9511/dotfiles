# Workspace and Markdown contracts

## Contents

1. Workspace tree
2. Coverage manifest
3. Raw solution Markdown
4. Organized solution Markdown
5. Evidence ledger
6. Synthesis files
7. Status semantics

## 1. Workspace tree

Use this stable tree:

```text
<workspace>/
├── scope/
│   ├── scope.md
│   └── coverage.csv
├── sources/
│   ├── competition.md
│   ├── leaderboard.csv
│   ├── evidence-ledger.md
│   └── discussions/
├── solutions/
│   ├── rank-001-team-slug-raw.md
│   └── rank-001-team-slug.md
├── synthesis/
│   ├── comparison-matrix.md
│   ├── common-elements.md
│   ├── differentiators.md
│   ├── task-grounded-analysis.md
│   └── strategy-retrospective.md
├── figures/
├── code/
├── report/
│   ├── main.typ
│   ├── lib.typ
│   ├── sections/
│   └── report.pdf
└── slides/
    ├── slides.typ
    ├── theme.typ
    └── slides.pdf
```

Use zero-padded final ranks and a stable lowercase team slug. Do not rename files after citations point to them.

## 2. Coverage manifest

`scope/coverage.csv` is the authoritative completeness boundary. Use this exact header:

```csv
rank,team,team_slug,medal_band,gold_group,selected,topic_refs,raw_path,summary_path,status,evidence_limit
```

Field rules:

- `rank`: final team rank, positive integer
- `team`: final leaderboard team label
- `team_slug`: lowercase letters, digits, and hyphens
- `medal_band`: `gold` or `silver-upper`
- `gold_group`: `top`, `lower`, or empty for silver
- `selected`: `true` for every scoped row
- `topic_refs`: semicolon-separated official topic refs or `none-found`
- `raw_path`: workspace-relative paired raw path
- `summary_path`: workspace-relative paired organized path
- `status`: `pending`, `complete`, `partial`, or `unavailable`
- `evidence_limit`: short reason for partial/unavailable evidence

Example:

```csv
rank,team,team_slug,medal_band,gold_group,selected,topic_refs,raw_path,summary_path,status,evidence_limit
1,Example Team,example-team,gold,top,true,competition-slug/12345,solutions/rank-001-example-team-raw.md,solutions/rank-001-example-team.md,pending,
```

## 3. Raw solution Markdown

Use this shape. Raw source content may be HTML inside the Markdown.

```markdown
---
competition: "competition-slug"
final_rank: 1
medal_band: "gold"
team: "Example Team"
topic_refs:
  - "competition-slug/12345"
retrieved_at: "2026-01-01T00:00:00Z"
retrieval_method: "Kaggle CLI 2.x via uv"
source_format: "html"
body_status: "retrieved"
comments_status: "complete"
---

# Raw solution: Rank 1 — Example Team

## Provenance

- Official URL: ...
- Authors/team mapping: ...
- Discovery queries/orderings: ...
- Pagination: ...
- Linked artifacts: ...

## Original post

<!-- Verbatim source content begins. -->
<p>...</p>
<!-- Verbatim source content ends. -->

## Comments

### Comment 123

- Author: ...
- Posted: ...
- Votes: ...
- Parent ID: ...

<!-- Verbatim source content begins. -->
<p>...</p>
<!-- Verbatim source content ends. -->

## Retrieval limitations

- None, or exact missing material.

## Search log

| time | method | query/ref | result |
|---|---|---|---|
```

When no public solution exists, keep the same headings. Put `Not retrieved` under Original post, retain the complete search log, and set `body_status: "unavailable"`.

## 4. Organized solution Markdown

Use this exact heading contract so validation can detect incomplete files:

```markdown
---
competition: "competition-slug"
final_rank: 1
medal_band: "gold"
team: "Example Team"
source_raw: "solutions/rank-001-example-team-raw.md"
status: "complete"
---

# Rank 1 — Example Team

## 概要

## Solutionの全体像

Describe the input-to-submission pipeline. Add a Mermaid or text diagram in Markdown when it clarifies the flow.

## Solutionのポイント

For each point, state source, setting, reported effect, and confidence.

## 理解を深めるための解説

Derive the important ideas. Define terms and symbols before using them.

## 検証・評価・再現性

Describe folds/splits, metric, public/private LB, ablations, seeds, compute, code availability, and gaps.

## 根拠と不確実性

| claim | evidence label | source | setting | confidence | limitation |
|---|---|---|---|---|---|

## 参照

- Stable official links and local raw path.
```

`Solutionの全体像` means the whole method, not a list of components. Show data flow, training, inference, postprocessing, and ensembling in their execution order.

## 5. Evidence ledger

Use one row per consequential claim in `sources/evidence-ledger.md`:

```markdown
| claim_id | claim | evidence_label | source | source_owner | scope | metric_setting | used_in | confidence | limitation |
|---|---|---|---|---|---|---|---|---|---|
| C-001 | ... | participant-reported | ... | Rank 1 team | fold 0-4 | CV metric | report 4.2 | medium | no code |
```

Use `source_owner` to distinguish Kaggle/host, organizer, team, other participant, vendor, paper author, and independent reproduction.

## 6. Synthesis files

### `comparison-matrix.md`

Start with scope and coverage counts, then a wide team-by-factor matrix. Use `yes`, `no`, `unknown`, or a concrete value. Silence is `unknown`.

### `common-elements.md`

For each factor include frequency, ranks, evidence strength, mechanism, counterexamples, and uncertainty.

### `differentiators.md`

Keep top-gold vs lower-gold separate from gold vs upper-silver. Include group definition, observed difference, plausible mechanism, confounders, and conclusion strength.

### `task-grounded-analysis.md`

Use one mechanism-chain table per factor:

```markdown
| property | failure/incentive | solution element | expected effect | observed evidence | uncertainty |
|---|---|---|---|---|---|
```

### `strategy-retrospective.md`

Organize as discovery cue, falsifiable hypothesis, cheapest test, decision rule, and next investment. Include mistakes to avoid and evidence that would have changed the path.

## 7. Status semantics

- `pending`: collection or analysis has not reached a conclusion
- `complete`: main post and materially relevant comments/artifacts were retrieved and organized
- `partial`: useful solution evidence exists but a material body, artifact, pagination segment, or team mapping is missing
- `unavailable`: no public team-attributable solution was found after the documented search

`partial` and `unavailable` are valid final research outcomes. They are not permission to omit the team or fill gaps with inference.

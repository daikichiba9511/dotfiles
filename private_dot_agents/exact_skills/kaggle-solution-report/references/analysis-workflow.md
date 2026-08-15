# Solution analysis and cross-team synthesis

## Contents

1. Per-solution analysis
2. Cross-solution synthesis
3. Task-grounded explanation
4. Strategy retrospective

## 1. Per-solution analysis

Complete organized Markdown only from retained sources. Include:

- a one-paragraph overview
- the end-to-end pipeline from input to prediction or submission
- key points and reported contributions or ablations
- an explanation of how the parts fit together
- validation design and public/private leaderboard relationship
- ensemble, postprocessing, external data, compute, and reproducibility details
- evidence/confidence table and unresolved questions
- a closed audit of every linked technical artifact and what it changes

For every complete or partial solution that exposes a method, add a Mermaid end-to-end diagram under `Solutionの全体像`. A solution is method-bearing when at least one real processing path can be drawn from team-attributable public evidence. Partial solutions still require a diagram when this condition holds; a fully unavailable solution does not. The diagram must show execution order from competition input to final prediction or submission and must retain material branches and convergence. Apply the semantic figure contract in `diagram-design.md`; do not replace the diagram with a component inventory, rank comparison, generic four-stage template, or prose-only arrow string.

Before drawing, extract a topology record with these fields:

- named input series, tables, or external data;
- position, region, sequence, or feature construction;
- condition-, view-, member-, or model-specific branches;
- classifier or sequence aggregator;
- ensemble, stacking, calibration, and postprocessing;
- training-only operations that materially change inference models;
- source reference for every node, edge, and branch, plus unresolved links. A single shared source reference may cover the entire record when one team-authored artifact supports the full pipeline.

Persist this record next to the diagram under `Solutionの全体像`; it is the only semantic source of truth for the organized Markdown, report figure, and slide figure. Mermaid is a generated reader-facing view of that record, not an independent specification. The shared Typst under `figures/` is the single publication rendering implementation. Change the semantic record first, then regenerate Mermaid and update the shared rendering; artifact-specific wrappers may rearrange labels and coordinates but must preserve its nodes, edges, conditions, sources, and uncertainty labels.

Use the fixed `### Topology record` table from `schemas.md`. Give every material node and edge a non-empty, unique, stable ID. The record must contain at least two distinct labeled nodes, one non-self edge, and a non-empty `source_ref` for every row; record an unknown connection as an edge with `uncertainty=unknown`, not as an inferred link.

Write the Mermaid view in the canonical checkable form: one node declaration per line (`N1[Label]`) and one edge per line (`N1 --> N2` or `N1 -->|condition| N2`). Keep exactly the same node IDs and directed edges as the Topology record. Put the one closed Mermaid block inside `## Solutionの全体像`; do not add a second independently edited graph.

For every numerical gain, record:

- metric and direction
- validation, public LB, or private LB
- baseline and comparison
- split, fold, seed, and model scope
- whether the number is participant-reported or reproduced

Never compare gains from different settings as if they were commensurate.

### Evidence saturation before synthesis

After organizing a team, read the raw post, all retained comments, and every inspected material artifact again as a coverage audit. Add one `publication-evidence.csv` row for each independent mechanism, experiment, failed idea, reasoning turn, reproducibility fact, and material limitation. The unit is a claim that could change what a reader builds, tests, trusts, or rejects; do not split incidental implementation details into artificial rows.

Then compare the organized headings and evidence table against this inventory:

- every row must point to retained primary evidence;
- every material artifact must connect to at least one row or explain why it adds no consequential evidence;
- every raw section describing `worked`, `didn't work`, `failed`, `ablation`, `CV`, `Public`, `Private`, `not used`, `dropped`, `unstable`, or a change of approach must be represented or explicitly classified as incidental;
- independent interventions must not be collapsed into one broad “other experiments” entry;
- missing quantitative controls remain limitations rather than fabricated results.

This is a semantic audit, not a word-count or slide-count target. A concise source may yield few items. A rich solution with several distinct mechanisms and negative results must remain correspondingly rich downstream.

## 2. Cross-solution synthesis

Construct `synthesis/comparison-matrix.md` before prose. Use one row per team and competition-specific columns such as:

- validation and split strategy
- cleaning or external data
- input representation and augmentation
- model families and backbones
- loss and metric alignment
- inference and test-time adaptation
- postprocessing
- ensembling and diversity
- compute and runtime
- reported gains and evidence strength

Answer three questions separately:

1. What appears across the full scoped field?
2. What differs between top-gold and lower-gold?
3. What differs between gold and upper-silver?

Frequency is descriptive, not causal. Test alternative explanations:

- Is the factor correlated with more compute or a larger team?
- Was it reported only after leaderboard feedback or public notebooks?
- Does it survive ablation or independent replication?
- Is silence in a write-up true absence or merely unreported?

Use `unknown`, not `no`, when a source is silent.

## 3. Task-grounded explanation

For every common or differentiating factor, fill this mechanism chain:

| link | required question |
|---|---|
| Task/data/metric property | What is structurally unusual or difficult? |
| Failure mode or incentive | What error does it create or reward? |
| Solution element | What did teams change? |
| Expected effect | Why should that change the measured error? |
| Observed evidence | Which write-up, ablation, discussion, or result supports it? |
| Uncertainty | What confounder or missing experiment remains? |

Research non-solution context covering:

- target definition and label generation
- train/test provenance and distribution shift
- duplicates, groups, temporal/geographic/patient/entity structure
- annotation noise and ambiguous cases
- public/private allocation and leaderboard shake-up
- exact metric formula, averaging, clipping, thresholds, ties, and edge cases
- organizer clarification and evaluation bugs
- validation failure, leakage, and negative results

Derive metric incentives with equations or controlled examples rather than stopping at the metric name.

## 4. Strategy retrospective

Reconstruct a discoverable path instead of a hindsight-only list:

1. Which property could have been noticed from rules, schema, EDA, metric, OOF errors, logs, or runtime?
2. Which concrete failure hypothesis follows?
3. What is the cheapest discriminating validation experiment?
4. What result would justify adopting, rejecting, or deferring the idea?
5. Which leaderboard behavior should have been distrusted?
6. Which ideas were unavailable without privileged hindsight?

Produce an ordered playbook: baseline, trustworthy validation, metric-aligned error analysis, targeted representation or model changes, inference and postprocessing, and finally diversity-aware ensembling.

Before drafting report or slides, close every `publication-evidence.csv` disposition. Gold core items cannot be excluded from slides. Factor-only placement is appropriate when a supporting item is clearer in a cross-team comparison, but the location must still name the item's actual mechanism or evidence rather than merely listing the team.

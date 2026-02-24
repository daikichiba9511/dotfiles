# Layer Format Specifications

## Table of Contents

- [Full Log (docs/logs.md)](#full-log)
- [Evidence Ledger (docs/evidence.md)](#evidence-ledger)
- [Compact Document (README.md)](#compact-document)

---

## Full Log

File: `src/exp/{exp_dir}/docs/logs.md`

Append-only history. Never delete entries. Every thought, decision, result goes here.

### Entry Format

Use the tag-specific templates below. All entries share a common header.

#### Common Header

```markdown
## YYYY-MM-DD HH:MM - [TAG]
```

#### [EXPERIMENT] - Experiment Design Entry (REQUIRED before running any experiment)

```markdown
## YYYY-MM-DD HH:MM - [EXPERIMENT]

### Baseline
[Current best approach / what we are comparing against]

### Changes
[Exactly what is different from baseline. Be specific: parameters, architecture, features, preprocessing, etc.]

### Hypothesis
[What we expect to happen and why]

### Considerations
[Potential issues, edge cases, interactions with other components, things to watch for]

### Result Scenarios
[Pre-register interpretation for each possible outcome BEFORE seeing results]
- **If metric improves significantly**: [What this would tell us, what to try next]
- **If metric improves marginally**: [What this would tell us, what to try next]
- **If no change**: [What this would tell us, what to try next]
- **If metric degrades**: [What this would tell us, what to try next]
```

#### [RESULT] - Raw Results Entry

```markdown
## YYYY-MM-DD HH:MM - [RESULT]

### Metrics
[Raw numbers: CV score, LB score, per-fold breakdown, etc.]

### Observations
[Unexpected behaviors, training dynamics, error patterns, etc.]

### Matched Scenario
[Which pre-registered scenario from the EXPERIMENT entry matches, and whether the pre-registered interpretation still holds]
```

#### [ANALYSIS] - Interpretation Entry

```markdown
## YYYY-MM-DD HH:MM - [ANALYSIS]

### Summary
[What happened in one sentence]

### Interpretation
[Why we think this happened. Cite evidence IDs where possible]

### Implications
[What this means for our overall approach]

### Next Hypotheses
[New hypotheses generated from this result]
```

#### [EDA] / [DECISION] / [HYPOTHESIS] / [DISCUSSION] / [BUGFIX] / [IDEA] - General Entry

```markdown
## YYYY-MM-DD HH:MM - [TAG]

### Context
[Why this entry exists, what triggered it]

### Content
[Observations, thoughts, raw results, code snippets, error logs]

### Decisions
[What was decided and why]

### Open Questions
- [Unresolved items]
```

### Tags

- `EXPERIMENT` - Experiment design (baseline, changes, hypothesis, considerations, result scenarios)
- `RESULT` - Raw results and metrics with scenario matching
- `ANALYSIS` - Interpretation, implications, next hypotheses
- `HYPOTHESIS` - New hypothesis formation
- `EDA` - Exploratory data analysis
- `DECISION` - Strategy or approach decision
- `DISCUSSION` - Broader implications, connections
- `BUGFIX` - Bug discovery and fix
- `IDEA` - Unstructured ideas for later evaluation

### Rules

- Append only, never edit past entries
- **Every experiment MUST have an [EXPERIMENT] entry BEFORE execution** with baseline, changes, hypothesis, considerations, and pre-registered result scenarios
- **Every [RESULT] entry MUST reference which scenario matched** from the corresponding [EXPERIMENT] entry
- Include raw numbers, not just interpretations
- Record failed attempts and dead ends
- Link to related entries by date/tag when relevant

---

## Evidence Ledger

File: `src/exp/{exp_dir}/docs/evidence.md`

Normalized, reusable observations. Evidence format, not narrative.

### Structure

```markdown
# Evidence Ledger

## Data Characteristics
| ID | Observation | Source | Confidence | Date |
|----|-------------|--------|------------|------|
| D-001 | [Fact about data] | [EDA/exp/reference] | [H/M/L] | YYYY-MM-DD |

## Model Behaviors
| ID | Observation | Source | Confidence | Date |
|----|-------------|--------|------------|------|
| M-001 | [Fact about model behavior] | [experiment ID] | [H/M/L] | YYYY-MM-DD |

## Feature Insights
| ID | Observation | Source | Confidence | Date |
|----|-------------|--------|------------|------|
| F-001 | [Fact about features] | [experiment ID] | [H/M/L] | YYYY-MM-DD |

## Known Constraints
| ID | Constraint | Impact | Source | Date |
|----|-----------|--------|--------|------|
| C-001 | [Limitation or constraint] | [How it affects approach] | [source] | YYYY-MM-DD |

## Validated Hypotheses
| ID | Hypothesis | Verdict | Evidence | Date |
|----|-----------|---------|----------|------|
| H-001 | [Statement] | [Confirmed/Rejected/Partial] | [Summary of evidence] | YYYY-MM-DD |

## Landmines
| ID | Issue | Trigger | Workaround | Date |
|----|-------|---------|------------|------|
| L-001 | [Known pitfall] | [When it occurs] | [How to avoid] | YYYY-MM-DD |
```

### Confidence Levels

- **H (High)**: Reproduced in multiple experiments, statistically significant
- **M (Medium)**: Observed once with clear signal, or logical inference from high-confidence evidence
- **L (Low)**: Single observation, weak signal, or inferred from limited data

### Rules

- One fact per row. No narratives or multi-paragraph explanations
- Always cite source (experiment ID, EDA notebook, external reference)
- Update confidence when new evidence arrives (append note, don't overwrite)
- Prefix IDs by category (D=Data, M=Model, F=Feature, C=Constraint, H=Hypothesis, L=Landmine)

---

## Compact Document

File: `src/exp/{exp_dir}/README.md`

Agent-ready summary. Minimal context needed to resume work.

### Structure

```markdown
# {exp_dir}: [Title]

## Current State
[1-3 sentences: where we are right now]

## Active Hypotheses
| Priority | Hypothesis | Rationale | Status |
|----------|-----------|-----------|--------|
| P1 | [Statement] | [Why we believe this] | [Testing/Queued/Blocked] |

## Key Constraints
- [Critical constraint 1]
- [Critical constraint 2]

## Unresolved Questions
- [Question that affects next steps]

## Next Actions
1. [Most important next step]
2. [Second priority]

## Experiment History (summary)
| Exp | What | Result | Key Learning |
|-----|------|--------|-------------|
| exp000 | [Brief] | [Brief] | [One line] |

## References
- Full log: [docs/logs.md](docs/logs.md)
- Evidence: [docs/evidence.md](docs/evidence.md)
```

### Rules

- Keep under 100 lines. If longer, compress
- No raw data or lengthy analysis (that belongs in logs/evidence)
- Update only with diffs from new evidence, not full rewrites
- Prioritize actionability: a new agent should know what to do next from this alone

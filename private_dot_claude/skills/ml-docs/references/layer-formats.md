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

- `HYPOTHESIS` - New hypothesis formation
- `EXPERIMENT` - Experiment design or execution
- `RESULT` - Raw results and metrics
- `ANALYSIS` - Interpretation of results
- `DISCUSSION` - Broader implications, connections
- `DECISION` - Strategy or approach decision
- `EDA` - Exploratory data analysis
- `BUGFIX` - Bug discovery and fix
- `IDEA` - Unstructured ideas for later evaluation

### Rules

- Append only, never edit past entries
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

---
name: ml-docs
description: "Manage 3-layer experiment documentation (Full Log, Evidence Ledger, Compact Document) for Kaggle ML competitions. Use when: (1) initializing documentation for a new experiment, (2) forming experiment strategy with bias-resistant multi-proposal generation, (3) logging experiment results and updating evidence/compact layers, (4) reviewing or maintaining experiment documentation state."
allowed-tools: Read, Edit, Write, Glob, Grep
---

# ML Experiment Documentation Manager

Manage a 3-layer document structure that separates history, evidence, and operational context for Kaggle competitions.

## Usage

`/ml-docs <command> [exp_dir]`

- `/ml-docs init exp003` - Initialize 3-layer docs for experiment
- `/ml-docs strategy exp003` - Run strategy formation flow
- `/ml-docs log exp003` - Log results and update layers
- `/ml-docs status exp003` - Review current state of all layers

If no command, ask which operation to perform.

## 3-Layer Architecture

| Layer | File | Role | Update Rule |
|-------|------|------|-------------|
| Full Log | `docs/logs.md` | Complete history | Append only |
| Evidence Ledger | `docs/evidence.md` | Normalized facts | Update from log |
| Compact Document | `README.md` | Agent-ready summary | Diff updates |

**Design principles driving this separation:**

- **Separation**: Logs, evidence, and operational docs serve different consumers
- **Compression**: Never carry raw history where a normalized fact suffices
- **JIT selection**: Load only the layer needed for the current operation
- **Normalization**: Evidence in table format, not narrative
- **Diversification**: Generate multiple proposals before consulting history to dilute anchoring

For detailed format specifications of each layer, see [references/layer-formats.md](references/layer-formats.md).

## Command: init

Create 3-layer document structure for an experiment directory.

1. Confirm experiment directory path (`src/exp/{exp_dir}/`)
2. Create `docs/` subdirectory
3. Create `docs/logs.md` with header and first entry
4. Create `docs/evidence.md` with empty table structure
5. Create or update `README.md` with compact document template

If the experiment directory already has documentation, warn and ask before overwriting.

## Command: strategy

Bias-resistant strategy formation. Follow these phases strictly in order.

### Phase 1: Task Information Gathering

Read and organize task-specific materials:
- Competition description, evaluation metric, data dictionary
- Summarize into a structured task brief

**Output**: Task brief appended to `docs/logs.md` with tag `[EDA]` or `[DECISION]`.

### Phase 2: Multi-Proposal Generation (from task materials ONLY)

Generate 3+ distinct strategy proposals using ONLY the task brief from Phase 1.

**Critical**: Do NOT read `docs/evidence.md` or `README.md` yet. This prevents anchoring to prior results.

For each proposal, state:
- Core idea (1 sentence)
- Expected mechanism (why it should work)
- Key risk

### Phase 3: Constraint Brushup

NOW read `README.md` (compact document) to retrieve:
- Known constraints
- Landmines
- Unresolved questions

Revise each proposal against these constraints. Drop or modify proposals that conflict with known issues. Add constraint-aware notes.

### Phase 4: Evidence-Based Confidence Assignment

NOW read `docs/evidence.md` (evidence ledger).

For each surviving proposal:
- Check against validated hypotheses and known model behaviors
- Assign confidence: H/M/L with cited evidence IDs
- Flag proposals that contradict high-confidence evidence

### Phase 5: Prioritization and Recording

Produce a ranked hypothesis list:

```
| Priority | Hypothesis | Confidence | Supporting Evidence | Risk |
|----------|-----------|------------|-------------------|------|
| P1 | ... | H | M-003, F-001 | ... |
```

- Append full reasoning to `docs/logs.md` with tag `[HYPOTHESIS]`
- Update `README.md` Active Hypotheses table
- Ask user to confirm priority order before proceeding

## Command: log

Post-experiment documentation update. Three sequential steps.

### Step 1: Append to Full Log

Append experiment results to `docs/logs.md`:
- Tag: `[RESULT]` for raw results, `[ANALYSIS]` for interpretation
- Include: metrics, observations, unexpected behaviors, failed attempts
- Include raw numbers, not just summary

### Step 2: Update Evidence Ledger

Extract normalized facts from the new log entries into `docs/evidence.md`:
- One fact per row
- Assign confidence level
- Cite source (experiment ID, log date)
- Update confidence of existing entries if new evidence changes them
- Move confirmed/rejected hypotheses to Validated Hypotheses table

### Step 3: Update Compact Document

Update `README.md` with minimal diffs:
- Update Current State
- Move completed hypotheses, promote queued ones
- Update Experiment History summary table
- Update Next Actions
- Keep under 100 lines

## Command: status

Read and summarize all 3 layers for the given experiment:

1. Read `README.md` - report current state and active hypotheses
2. Read `docs/evidence.md` - count entries per category, flag low-confidence items
3. Read `docs/logs.md` (last 5 entries) - report recent activity
4. Identify inconsistencies between layers (e.g., evidence not reflected in compact doc)

## Context Management Guidelines

When operating on documents, follow these principles:

- **Memory**: Full Log retains everything; other layers are derived views
- **Dependency**: Track which decisions depend on which evidence IDs
- **Bias**: Phase 2 of strategy MUST NOT access prior results. This is non-negotiable
- **Input design over reasoning**: The quality of output depends more on what context is loaded than on reasoning instructions

$ARGUMENTS

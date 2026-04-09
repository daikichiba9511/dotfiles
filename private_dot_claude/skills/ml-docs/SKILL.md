---
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
6. **Exploration Map setup**: Ask user to fill in sub-areas for each exploration area in the README Exploration Map. Pre-populate with common sub-areas for the competition domain (e.g., CV: backbone/head/neck for architecture, geometric/color/mixup for augmentation). Priority is pre-set (Data > Feature > Augmentation > Architecture > Loss > Ensemble > PostProcess) based on upstream-first principle. User confirms or edits.

If the experiment directory already has documentation, warn and ask before overwriting.

## Command: strategy

Bias-resistant strategy formation. Follow these phases strictly in order.

### Phase 0: Exploration Coverage Check

Before forming new strategy, aggregate exploration state from logs and README:

1. Read `README.md` Exploration Map
2. Scan `docs/logs.md` for all `[EXPERIMENT]` entries, count per Exploration Area tag
3. Present coverage summary:

```
⚠ Exploration Coverage:
  feature: 6 experiments (exp001,002,004,005,007,008)
  architecture: 1 experiment (exp003)
  augmentation: 0 — UNEXPLORED
  loss: 0 — UNEXPLORED
  postprocess: 0 — UNEXPLORED

→ feature に偏っています。未探索の上流領域 (data) からの提案を優先してください。
```

4. Also check if explored areas have error analysis backing in the Motivation column. Flag areas explored without evidence-based motivation.

This summary MUST be visible to the user before Phase 2 starts. It informs proposal diversity but does NOT constrain it (user may choose to continue deepening an area with stated reason).

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

Post-experiment documentation update. Covers both pre-experiment design and post-experiment results.

### Step 0: Pre-Experiment Design (if not already logged)

Before running an experiment, ensure `docs/logs.md` has an `[EXPERIMENT]` entry containing:
- **Baseline**: What we are comparing against
- **Changes**: Exactly what differs from baseline
- **Hypothesis**: What we expect and why
- **Exploration Area**: Tag (data/feature/augmentation/architecture/loss/ensemble/postprocess/other) + motivation (error analysis evidence ID or rationale)
- **Considerations**: Potential issues, edge cases, interactions
- **Result Scenarios**: Pre-registered interpretations for each outcome (improve / marginal / no change / degrade)

If this entry is missing, create it FIRST by asking the user.

**⚠ Exploration Concentration Warning**: Before recording the `[EXPERIMENT]` entry, count consecutive experiments in the same Exploration Area from `docs/logs.md`. If **3 or more consecutive experiments share the same area**, display a warning:

```
⚠ 同一領域 (feature) が3実験連続です。
  現在のExploration Map:
    feature: 5 experiments / architecture: 1 / augmentation: 0 / ...
  → 続行する場合、理由を記載してください。別の領域に切り替えますか？
```

User may continue with a stated reason (logged as part of the `[EXPERIMENT]` entry under Considerations) or switch areas. Either is acceptable — the goal is to create a conscious decision point, not to block.

### Step 1: Append to Full Log

Append experiment results to `docs/logs.md`:
- `[RESULT]` entry: raw metrics, observations, and **which pre-registered scenario matched**
- `[ANALYSIS]` entry: interpretation, implications, next hypotheses, transferable learning
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
- Update Experiment History summary table (include Area column)
- **Update Exploration Map**: Change status of explored areas, add experiment IDs
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

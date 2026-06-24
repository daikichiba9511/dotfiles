---
name: ml-docs
description: "Manage and explain 3-layer experiment documentation (Full Log, Evidence Ledger, Compact Document) for Kaggle ML competitions. Use when: (1) explaining how the ML docs system works or which command to use, (2) initializing documentation for a new experiment, (3) forming experiment strategy with bias-resistant multi-proposal generation, (4) logging experiment results and updating evidence/compact layers, (5) reviewing or maintaining experiment documentation state."
allowed-tools: Read, Edit, Write, Glob, Grep
---

# ML Experiment Documentation Manager

Manage a 3-layer document structure that separates history, evidence, and operational context for Kaggle competitions.

## Usage

`$ml-docs <command> [exp_dir]`

- `$ml-docs guide exp003` - Explain the documentation system and next operation
- `$ml-docs init exp003` - Initialize 3-layer docs for experiment
- `$ml-docs strategy exp003` - Run strategy formation flow
- `$ml-docs log exp003` - Log results and update layers
- `$ml-docs status exp003` - Review current state of all layers

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

## Command: guide

Explain the documentation system without modifying files.

Adapt the explanation:

- If docs exist, focus on operations and show current stats from `README.md`, `docs/evidence.md`, and recent `docs/logs.md` entries.
- If docs do not exist, explain the 3-layer concept and suggest `$ml-docs init`.

Cover:

- **Core idea**: separate raw experiment history, normalized evidence, and compact operational context so Codex loads only the layer needed for the current operation.
- **Why it matters**: monolithic chat history or experiment notes create anchoring, stale context, and expensive rereads; the 3-layer structure keeps memory complete while keeping working context small.
- **Available commands**: `guide`, `init`, `strategy`, `log`, and `status`.
- **Typical workflow**:

```text
1. $ml-docs init exp003
2. $ml-docs strategy exp003
3. $ml-docs log exp003     # pre-register design before running
4. Run the experiment
5. $ml-docs log exp003     # record results and update evidence/README
6. $ml-docs status exp003
```

When explaining relation to LLM Wiki: this skill applies the same compounding-docs idea to ML experiments, but adds experiment-specific guardrails such as pre-registration, evidence confidence, and bias-resistant strategy phases.

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

Post-experiment documentation update. Covers both pre-experiment design and post-experiment results.

### Step 0: Pre-Experiment Design (if not already logged)

Before running an experiment, ensure `docs/logs.md` has an `[EXPERIMENT]` entry containing:
- **Date**: Experiment date
- **Baseline**: What we are comparing against
- **Changes**: Exactly what differs from baseline
- **Hypothesis**: What we expect and why
- **Considerations**: Potential issues, edge cases, interactions
- **Code Evidence**: Files, functions, commands, commits, or config paths that implement the change
- **Result Scenarios**: Pre-registered interpretations for each outcome (improve / marginal / no change / degrade)

If this entry is missing, create it FIRST by asking the user.

### Step 1: Append to Full Log

Append experiment results to `docs/logs.md`:
- `[RESULT]` entry: raw metrics, observations, and **which pre-registered scenario matched**
- `[ANALYSIS]` entry: interpretation, implications, next hypotheses, and why the change worked or did not work
- Include raw numbers, not just summary
- Write experiment notes in Japanese unless the user requests otherwise
- Include enough implementation evidence that the experiment can be understood and explained from the notes

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
- **Learning over polish**: For exploratory code, preserve what was tried, what worked, what failed, and why; do not rewrite history into a clean story

$ARGUMENTS

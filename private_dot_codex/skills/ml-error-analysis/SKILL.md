---
name: ml-error-analysis
description: "Analyze ML failures from validation outputs, bad predictions, confusion matrices, per-slice metrics, error tables, or qualitative examples, then convert them into ranked hypotheses and next experiments. Use when the user wants to understand what the model is getting wrong, find systematic failure modes, decide what to try next, or says 'エラー分析して', '失敗例を見て', 'どこで落ちてるか整理して', '次の仮説を出して'."
allowed-tools: Read, Write, Glob, Grep, Bash(python:*)
---

# ML Error Analysis

Turn observed failures into concrete next actions.
Use `references/analysis-format.md` for failure buckets, hypothesis structure, and reporting.

## Workflow

### Step 1: Inventory artifacts

Find what is available:

- prediction tables
- confusion matrices
- per-class or per-slice metrics
- qualitative failure examples
- training logs and recent experiment notes

### Step 2: Group failures

Bucket errors by the most useful dimension available:

- class
- slice
- threshold regime
- input quality
- annotation ambiguity
- temporal or domain shift

### Step 3: Explain plausible causes

For each bucket, distinguish:

- evidence-backed observations
- plausible but unverified causes
- hypotheses worth testing next

Use `references/analysis-format.md` for the bucket template.

### Step 4: Convert to experiments

Generate a ranked list of next experiments or checks.
Prefer proposals that cleanly discriminate between hypotheses instead of vague "improve the model" advice.

## Rules

- do not confuse noisy anecdotes with systemic patterns
- separate data problems, labeling problems, model capacity problems, and decision-threshold problems
- explicitly note when more slices or more examples are needed before acting
- each recommendation should map back to a failure bucket

$ARGUMENTS

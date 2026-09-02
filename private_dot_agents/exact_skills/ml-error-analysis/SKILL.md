---
name: ml-error-analysis
description: "Use when validation predictions or failure artifacts exist and the user wants systematic error slices, ranked failure hypotheses, and next experiments. Do not use to audit raw datasets, check train/inference parity, or implement the experiment loop."
allowed-tools: Read, Write, Glob, Grep, Bash(python:*)
---

# ML Error Analysis

Turn observed failures into concrete next actions.

## Workflow

### Step 1: Inventory artifacts

Find what is available:

- prediction tables
- confusion matrices
- per-class or per-slice metrics
- qualitative failure examples
- training logs and recent experiment notes

### Step 2: Group failures

Bucket errors by the dimension most likely to expose a shared mechanism:

- class
- slice
- threshold regime
- input quality
- annotation ambiguity
- temporal or domain shift

For each bucket, quantify its frequency or severity and retain representative examples.

### Step 3: Test candidate explanations

For each plausible mechanism, record:

- why it fits the observed bucket
- evidence that contradicts it
- the smallest check that would discriminate it from alternatives

### Step 4: Convert to experiments

Rank the next checks or experiments by failure impact and their ability to change the next decision.

## Rules

- do not confuse noisy anecdotes with systemic patterns
- separate data problems, labeling problems, model capacity problems, and decision-threshold problems
- explicitly note when more slices or more examples are needed before acting
- each recommendation should map back to a failure bucket

$ARGUMENTS

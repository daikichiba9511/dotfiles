---
name: ml-paper-to-exp
description: "Use when the user provides or names an ML paper, solution write-up, benchmark, or technical article and wants reproducible ideas converted into ranked experiments for the current project. Do not use for general literature summaries without an experiment decision."
allowed-tools: Read, Write, Glob, Grep, WebFetch, WebSearch
---

# ML Paper To Experiment

Translate external ideas into experiment-ready proposals.
Use `references/experiment-format.md` for extraction structure and experiment cards.

## Workflow

### Step 1: Read the source

Extract only what matters for transfer:

- task and data regime
- model or pipeline change
- training setup that the claim depends on
- evaluation method
- ablations or evidence quality

### Step 2: Separate signal from baggage

Split findings into:

- transferable ideas likely to survive domain shift
- context-specific choices tied to the original dataset or stack
- unclear claims that need verification

### Step 3: Map to the current project

Compare the source against the user's setup:

- what already exists
- what is missing
- what would be expensive to reproduce
- what can be tested with a cheap proxy

### Step 4: Propose experiments

Write 2-5 experiment cards using `references/experiment-format.md`.
Prefer a mix of:

- one low-cost validation
- one medium-confidence adaptation
- one higher-risk upside bet

### Step 5: Rank and recommend

Rank by expected signal, implementation cost, and dependency risk.
If the idea is not worth trying, say that explicitly.

## Rules

- do not treat paper metrics as portable by default
- do not recommend reproduction-heavy work unless the upside justifies it
- call out hidden dependencies such as extra data, pretraining, or search budget
- convert ideas into experiments, not just summaries

$ARGUMENTS

---
name: ml-dataset-audit
description: "Audit an ML dataset, feature table, split, or labeling pipeline for leakage, duplicates, schema drift, imbalance, missingness, target contamination, and train/validation/test skew. Use when the user wants to check data quality before training, investigate suspicious validation scores, validate split integrity, or says 'データ監査して', 'リークがないか見て', 'split大丈夫か確認して', 'ラベル品質を点検して'."
allowed-tools: Read, Write, Glob, Grep, Bash(python:*)
---

# ML Dataset Audit

Inspect dataset integrity before the model work gets blamed for data problems.
Use `references/audit-checklist.md` for the audit dimensions and output format.

## Workflow

### Step 1: Identify the dataset surface

Determine:

- file formats and locations
- unit of prediction
- split files or split logic
- label source
- key identifiers and timestamps

### Step 2: Run the audit

Use the checklist in `references/audit-checklist.md` to inspect:

- split integrity
- duplicate and near-duplicate risk
- target leakage
- schema and missingness issues
- label balance and suspicious distributions
- temporal or domain skew

### Step 3: Classify findings

Label each finding as:

- blocker
- high-risk
- medium-risk
- informational

### Step 4: Recommend fixes

For each important issue, propose the cheapest trustworthy fix or verification step.

## Rules

- prioritize leakage and split integrity over cosmetic cleanup
- do not assume random split is valid if time, entity, or group leakage is possible
- when evidence is incomplete, recommend a verification query instead of overclaiming
- tie each recommendation to the specific failure mode it addresses

$ARGUMENTS

---
name: coding-rules
description: "Use whenever creating or editing source code that should follow this repository's personal conventions, especially Python and ML/Kaggle experiment scripts or notebooks such as train.py, feature, model, and evaluation changes. Apply the ML experiment override when relevant. Do not use for read-only investigation, review-only tasks, documentation, generated artifacts, or config-only edits."
---

# Coding Rules

Apply these rules before writing or editing source code.

## General

- Express what code does through naming and structure. Comments explain why.
- Add comments only for non-obvious invariants, assumptions, constraints, or intentional deviations.
- Update or remove nearby comments when changing code.
- Prefer named arguments over unclear positional arguments.
- Return structured objects instead of positional tuples when values have distinct meanings.
- Prefer immutable values and minimize side effects.

## Security

- Never commit secrets, credentials, private keys, or `.env` files.
- Reference secrets through environment variables or a secret manager.

## Language Rules

- For Python changes, read and follow `references/python.md` completely before editing.

## ML Experiment Override

After loading any language rules, read and follow `references/ml-experiment.md` completely when the target is exploratory ML or Kaggle experiment code. This applies even when the request is phrased as a small training, feature, model, inference, or evaluation code change rather than as an experiment cycle. The ML experiment rules override the general and Python rules where they conflict.

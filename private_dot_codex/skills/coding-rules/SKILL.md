---
name: coding-rules
description: Apply personal coding conventions when writing or editing source code. Use whenever a task creates or modifies code, especially Python. Do not use for read-only reviews, investigation, or documentation-only changes.
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

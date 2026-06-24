---
paths:
  - "exp/**"
  - "experiments/**"
  - "src/exp/**"
---

# ML Experiments

## Iteration
EDA > hypothesis > experiment > logging > analysis > next hypothesis. Read related experiment READMEs before starting new ones.

## Structure
- Each experiment in `src/exp/exp000/`, `src/exp/exp001/`, etc. with its own README
- Shared utilities in `src/exp/common/` or `src/lib/`
- Prioritize iteration speed and traceable experiment lineage over robustness.
- During exploration, prefer a readable vertical main path over early horizontal module splitting.
- Extract only stable, testable pure logic or repeated calculations. Clean up stale branches and fallbacks before splitting files.

## Error Handling
- Crash immediately on invalid state (Fail Fast). Let errors propagate naturally.
- Do not add silent fallbacks, compatibility layers, aliases, or alternate execution paths unless explicitly requested.
- Required config, dict keys, env vars, modes, and workflow inputs must fail loudly when missing.
- Avoid default-value fallbacks for required values: `dict.get(key, default)`, nested old/new key fallback, `os.getenv(name, default)`, `kwargs.pop(name, default)`, and `value or default`.
- If a default is a real domain constant, define it explicitly as a constant instead of hiding it inside lookup code.
- Do not use raw `dict` for experiment config, feature definitions, model parameters, dataset schema, or metric settings.
- Load YAML/JSON/TOML into typed dataclasses immediately at the boundary.
- Missing or unknown config fields should raise during construction or validation.

## Train/Inference Consistency
- Extract preprocessing to a shared module. Use the same function for train and inference.
- Allowed to differ: batch size, dropout, augmentation
- Must be identical: feature extraction, normalization params, tokenization

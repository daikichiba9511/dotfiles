---
paths:
  - "src/exp/**"
---

# ML Experiments

## Iteration
EDA > hypothesis > experiment > logging > analysis > next hypothesis. Read related experiment READMEs before starting new ones.

## Structure
- Each experiment in `src/exp/exp000/`, `src/exp/exp001/`, etc. with its own README
- Shared utilities in `src/exp/common/` or `src/lib/`
- Prioritize iteration speed over robustness. Extract shared logic early.

## Error Handling
- Crash immediately on invalid state (Fail Fast). Let errors propagate naturally.

## Config
- Centralize in a `Config` dataclass. Map to per-module dataclasses for arguments.

## Train/Inference Consistency
- Extract preprocessing to a shared module. Use the same function for train and inference.
- Allowed to differ: batch size, dropout, augmentation
- Must be identical: feature extraction, normalization params, tokenization

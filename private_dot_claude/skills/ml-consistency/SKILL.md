---
description: Check train/inference consistency in ML experiments
allowed-tools: Read, Glob, Grep
---

You are an ML consistency checker. Verify that training and inference code use consistent preprocessing, feature extraction, and data handling.

## Usage

`/ml-consistency <exp_dir>` - e.g., `/ml-consistency exp003`

## Workflow

### 1. Identify Train/Inference Code

- Find training scripts (train.py, main.py, etc.)
- Find inference scripts (inference.py, predict.py, eval.py, etc.)
- Identify shared modules

### 2. Check Preprocessing Consistency

**Must be identical:**
- Normalization parameters (mean, std, min, max)
- Tokenization/encoding logic
- Feature extraction pipelines
- Data type conversions
- Missing value handling

**Allowed to differ:**
- Batch size
- Shuffle (train: True, inference: False)
- Data augmentation (train only)
- Dropout (disabled at inference)
- Gradient computation (disabled at inference)

### 3. Check Config Consistency

- Model architecture parameters
- Input dimensions
- Output format
- Device placement

### 4. Report Findings

## Output Format

```markdown
## Consistency Check: {exp_dir}

## Files Analyzed
- Train: [files]
- Inference: [files]
- Shared: [files]

## Preprocessing

### ✅ Consistent
| Operation | Location |
|-----------|----------|
| normalize() | src/exp/common/preprocess.py |

### ⚠️ Potentially Inconsistent
| Operation | Train | Inference | Risk |
|-----------|-------|-----------|------|
| ... | file:line | file:line | High/Medium/Low |

### ❌ Inconsistent (Bug)
| Issue | Train | Inference | Impact |
|-------|-------|-----------|--------|
| Different std value | std=0.2 | std=0.25 | Wrong predictions |

## Allowed Differences
| Difference | Train | Inference | OK? |
|------------|-------|-----------|-----|
| Augmentation | True | False | ✅ |
| Dropout | 0.1 | 0.0 | ✅ |

## Recommendations
1. ...
2. ...
```

## Common Issues to Check

1. **Hardcoded values** - Same magic numbers in both places?
2. **Import paths** - Using same preprocessing module?
3. **Config loading** - Same config file/defaults?
4. **Data loading** - Same transforms applied?
5. **Model loading** - Correct checkpoint loading?

## Guidelines

- Flag potential issues, don't assume all differences are bugs
- Consider that some differences are intentional (augmentation, dropout)
- Check if shared modules are actually used by both
- Verify normalization stats match training data

## Target Directory

$ARGUMENTS

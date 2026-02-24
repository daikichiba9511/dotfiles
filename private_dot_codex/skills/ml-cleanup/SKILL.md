---
description: Clean up ML experiment code, reduce bloat, extract shared logic
allowed-tools: Read, Edit, Write, Glob, Grep, Bash(run tests:*)
---

You are an ML experiment code cleaner. Analyze and clean up experiment code to reduce bloat while preserving functionality.

## Usage

`/ml-cleanup <exp_dir>` - e.g., `/ml-cleanup exp003` or `/ml-cleanup src/exp/exp003`

## Workflow

### 1. Analyze Target Experiment

- Identify the experiment directory (default: `src/exp/$ARGUMENTS`)
- List all Python files in the experiment
- Understand the experiment structure

### 2. Detect Issues

**Dead code:**
- Unused imports
- Unused functions/classes
- Commented-out code blocks
- Unreachable code

**Copy-paste remnants:**
- Code copied from previous experiments but not used
- Hardcoded values from other experiments
- Outdated comments referencing other experiments

**Duplication:**
- Logic duplicated within the experiment
- Logic that should be in `src/exp/common/` or `src/lib/`

### 3. Suggest Improvements

For each issue:
- Location (file:line)
- Problem description
- Suggested fix
- Impact (safe to remove / needs verification)

### 4. Execute Cleanup (with confirmation)

- Remove dead code
- Extract shared logic to common modules
- Update imports

## Output Format

```markdown
## Experiment: {exp_dir}

## Analysis Summary
- Files analyzed: N
- Issues found: N

## Issues

### Dead Code
| File | Line | Type | Safe to Remove |
|------|------|------|----------------|
| ... | ... | ... | Yes/Verify |

### Duplication Candidates
| Code | Occurrences | Suggested Location |
|------|-------------|-------------------|
| ... | ... | src/exp/common/... |

### Copy-paste Remnants
- ...

## Recommended Actions
1. ...
2. ...

## Cleanup Commands
[Specific edits to make]
```

## Guidelines

- Always verify tests pass after cleanup
- Don't remove code that might be used dynamically
- Preserve experiment reproducibility
- Ask before making large changes

## Target Directory

$ARGUMENTS

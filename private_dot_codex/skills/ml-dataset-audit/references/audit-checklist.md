# ML Dataset Audit Checklist

## Audit Dimensions

### Split Integrity

- train/valid/test overlap by ID, group, filename, or entity
- temporal leakage
- fold construction bugs

### Duplicate Risk

- exact duplicates
- near-duplicates
- same label repeated across splits through alternate IDs

### Leakage

- target-derived features
- post-event columns
- aggregates that cross split boundaries
- preprocessing fit on the full dataset

### Data Quality

- schema drift
- unexpected null patterns
- impossible values
- unit inconsistencies

### Label Quality

- severe imbalance
- contradictory labels for same entity
- suspiciously easy labels or degenerate classes

### Distribution Shift

- class balance mismatch across splits
- domain or source skew
- timestamp or geography skew

## Output Format

```markdown
## Audit Summary
- Blockers:
- High-risk:
- Medium-risk:
- Informational:

## Findings
### [Severity] Finding
- Evidence:
- Why it matters:
- Recommended fix:

## Suggested Next Checks
- ...
```

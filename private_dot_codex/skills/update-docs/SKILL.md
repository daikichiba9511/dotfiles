---
description: Sync and update documentation based on code changes
allowed-tools: Read, Edit, Write, Glob, Grep, Bash(git diff:*), Bash(git log:*)
---

You are a technical writer. Understand code changes and sync/update related documentation.

## Workflow

### 1. Understand Code Changes

- Review git diff or specified changes
- Classify change type (new feature/fix/deletion/refactoring)
- Identify impact scope

### 2. Identify Documentation Requiring Updates

Target documentation:
- README.md
- API documentation
- Configuration/installation guides
- CHANGELOG.md
- Architecture documentation
- Comments/docstrings

### 3. Update Documentation

- Reflect changes
- Remove/fix outdated information
- Update examples and screenshots as needed
- Verify consistency

## Guidelines

- Write concisely and clearly
- Consider target audience (developers/users)
- Include concrete examples
- Maintain consistency between code and documentation

## Output Format

```markdown
## Change Summary
[Brief description of code changes]

## Documentation to Update
- [Filename]: [Reason for update]

## Updates
[Actual updates or proposed changes]
```

## Additional Instructions

$ARGUMENTS

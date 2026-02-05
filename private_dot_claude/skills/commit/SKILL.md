---
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git add:*), Bash(git commit:*), Bash(git log:*)
description: Create a git commit following conventional commits
---

Analyze the following git diff --cached or git diff and then generate a commit message in Conventional Commits format.

When it is better to split the commits, please split them and create only the first commit.

Look at the most recent five commits, and generate the commit message in Japanese if any of them use Japanese commit messages; otherwise, generate it in English.

Split commits by semantic unit or functional unit, and first explain to the user at what level of granularity the commits will be divided.

Finally, unless otherwise instructed, complete the commit and report the work to the user.

## Rules

- Line 1: `<type>(<scope>): <subject>` (50 characters or less, imperative mood)
- Line 2: blank line
- Line 3+: detailed explanation (what changed and why)
- type: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
- Output as plain text (no code blocks), ready to use as commit message

## Example

```
feat(nvim): add auto commit message generation
```

## Current State

!git status --short
!git diff --cached --stat
!git diff --stat
!git log --oneline -5

## Additional Instructions

$ARGUMENTS

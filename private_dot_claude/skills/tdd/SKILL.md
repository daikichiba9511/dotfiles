---
description: TDD workflow (RED→GREEN→REFACTOR)
allowed-tools: Bash(run tests:*), Read, Edit, Write, Glob, Grep
---

Facilitate TDD with the Red-Green-Refactor cycle: write one failing test for the target behavior, make it pass with the simplest code (hardcoding is fine), then refactor while keeping tests green. Keep cycles small. Tests describe behavior, not implementation — Arrange-Act-Assert, named "when X then Y".

## Design Feedback

Test pain is a design signal — raise it during the refactor phase:

- Tests are hard to write → possibly high coupling
- Complex setup required → possibly too many responsibilities
- Many mocks needed → possibly too many dependencies

## Additional Instructions

$ARGUMENTS

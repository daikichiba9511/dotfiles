---
name: tdd
description: "Use only when the user explicitly requests test-driven development, RED-GREEN-REFACTOR, or test-first implementation. Do not trigger merely because tests should be added or run."
allowed-tools: Bash(run tests:*), Read, Edit, Write, Glob, Grep
---

You are a TDD (Test-Driven Development) facilitator. Guide development following the Red-Green-Refactor cycle.

## Workflow

### 1. RED - Write a Failing Test

- Clarify the behavior you want to implement
- Write one test that verifies that behavior
- Run the test and confirm it fails
- Verify the failure is due to "not implemented"

### 2. GREEN - Write Minimal Code to Pass

- Focus only on making the test pass
- Choose the simplest implementation
- Hardcoding is acceptable
- Confirm the test passes

### 3. REFACTOR - Improve Code While Keeping Tests Green

- Eliminate duplication
- Improve naming
- Organize function/class responsibilities
- Confirm tests continue to pass

## Guidelines

- Keep each cycle small (a few minutes)
- Tests describe behavior (not implementation details)
- Use Arrange-Act-Assert pattern
- Recommended test naming: "when X then Y" format

## Bug Fixes: Regression Test First

When the TDD request is about a bug, make the broken behavior executable before touching production code.

- Pick the narrowest check already used for that code path (unit, component, integration).
- Write the smallest test that would have caught the bug; it encodes intended behavior, not the current implementation.
- Run it before the fix and confirm it fails for the intended reason. If it passes or fails for an unrelated reason, fix the test or the reproduction first.
- Make the smallest production change, then rerun.

If a failing test is impractical (broad harness setup, brittle mocks, slow end-to-end infrastructure, production-only state, vague repro), say so and use the closest executable check instead: a targeted script, repro command, log assertion, or focused integration check. Prefer no new test over a bad test — one that mostly tests mocks, encodes internals, depends on timing or global state, or would be deleted right after proving the fix.

## Guardrails

- Never change a test to match a wrong implementation, and never weaken an existing assertion unless the expected behavior genuinely changed and the reason is stated.
- Keep the regression test focused; no unrelated fixture churn or coverage expansion.
- For a flaky bug, make the test deterministic where possible and name the signal it locks down.

## Design Feedback

When design issues are discovered during TDD cycles:
- Tests are hard to write → Possibly high coupling
- Complex setup required → Possibly too many responsibilities
- Many mocks needed → Possibly too many dependencies

When problems are found, suggest improvements during the refactor phase.

## Final Report

Report evidence, not just the outcome: the test (or executable check) that failed before and the failure it produced, the passing run after, and any nearby validation. If failing-before evidence could not be shown, say why and name the check used instead.

Parts adapted from pstack (MIT, Lauren Tan); see LICENSE.pstack.

## Additional Instructions

$ARGUMENTS

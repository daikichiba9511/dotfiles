---
name: code-review
description: "Code review of the working diff — verified, evidence-backed findings across correctness, coupling/connascence (Khononov integration strength), blast radius, and tests. Use when the user asks to review local changes, a branch diff, or specific files ('review my changes', 'レビューして', 'この差分を見て'). For security-focused audits use the security-review skill."
allowed-tools: Read, Glob, Grep, Bash(git diff:*), Bash(git log:*), Bash(git show:*)
---

Review reports defects; it never edits code. Findings must be evidence-backed and verified — a plausible-sounding finding you did not re-check against the code is noise with confident wording. "Clean" is a valid outcome: do not invent nitpicks to fill a report.

## Scope

- Default target: the working diff against main (or the branch/files the user names).
- Read the intent first — commit messages, PR description, linked issue — and review the diff against it: does the change do what it claims, completely, and nothing beyond it? Incomplete implementations and scope creep are findings.
- Skip generated files and lockfiles. Don't report style a formatter or linter already enforces.
- `git log` on touched files is cheap risk context: a file with many recent fixes is a hotspot that deserves deeper reading, and recent related fixes may interact with this change.

## Running the review

Work through the lenses below in turn, collecting findings per lens before judging any of them. Report coverage-first while finding: note every issue, including ones you are uncertain about — filtering happens at the verification step, not at finding time; a finding silently dropped early is unrecoverable.

Lenses:

1. **Correctness** — trace the failure paths: wrong logic, unhandled states, broken invariants, off-by-one, error paths asymmetric with success paths.
2. **Coupling & design** — the framework below.
3. **Blast radius** — the bug is usually outside the diff: find the callers and usages of every changed symbol (Grep) and check whether their assumptions still hold — signatures, semantics, error behavior, invariants.
4. **Tests** — for each behavioral change in the diff, name the test that would fail if the change were wrong. A behavior change that no test pins is a finding.
5. **ML consistency** (only when the diff touches experiment/training code) — train/inference divergence per the ml-consistency skill: feature extraction, normalization params, and tokenization must be shared between train and inference.

Then verify before reporting: for each finding that would be costly if wrong, re-check it adversarially against the actual code — try to refute it. Drop refuted findings, dedup across lenses, rank by severity.

## Coupling & design lens

Evaluate integration strength (Vlad Khononov, "Balancing Coupling in Software Design") and connascence.

### Three Dimensions of Coupling

| Dimension | Description | Goal |
|-----------|-------------|------|
| **Strength** | Amount of knowledge shared between modules | Minimize |
| **Distance** | Physical, organizational, ownership boundaries | Consider context |
| **Volatility** | How frequently modules change | Isolate volatile parts |

Higher strength + longer distance + higher volatility = higher risk of cascading changes.

### Four Levels of Integration Strength

From strongest (worst) to weakest (best):

1. **Intrusive Coupling (Avoid)** — Accessing private interfaces or implementation details
2. **Functional Coupling (Minimize)** — Sharing knowledge about functionalities across modules (duplicated logic)
3. **Model Coupling (Caution)** — Components share a domain model directly
4. **Contract Coupling (Preferred)** — Integration through dedicated contracts that abstract internal models

### Connascence

Static (compile-time, easier to manage):
- **Name** / **Type** / **Meaning** / **Position** / **Algorithm**

Dynamic (runtime, harder to manage):
- **Execution** / **Timing** / **Values** / **Identity** (most problematic)

**Rule**: Prefer static over dynamic. Lower connascence is better.

### What to look for

- Intrusive coupling: accessing private members or implementation details
- Functional duplication: same logic implemented in multiple places
- Model leakage: internal models exposed at boundaries; direct model sharing where a contract/DTO would be better
- High connascence: position-dependent code, shared mutable state
- Volatility isolation: are stable parts protected from volatile parts?

### Key Questions

1. "If the upstream module changes internally, will this code break?"
2. "How much does this module need to know about its dependencies?"
3. "Is this coupling at the appropriate boundary?"
4. "Could we reduce shared knowledge with a contract?"

## Findings format

Each finding carries: `file:line` — a one-sentence statement of the defect — a concrete failure scenario (specific input or state → wrong outcome) — severity (Critical/High/Medium/Low) — confidence — a verbatim evidence quote. Coupling findings also name the coupling type. A finding without a failure scenario and evidence doesn't ship.

Report outcome first (clean, or N findings with worst severity), then the ranked findings, then strengths worth keeping.

## Additional Instructions

$ARGUMENTS

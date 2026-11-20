---
name: engineering-principles
description: "Use when the user names an engineering principle (e.g. attack the premise, prove it works, subtract before you add) or asks which principle applies, or when making a non-trivial design, debugging-strategy, verification, migration, concurrency, or delegation decision that needs a principled check. Do not use for routine edits, style rules already covered by coding-rules, exploratory ML experiment code policy, or as a generic checklist on every task."
---

# Engineering Principles

A compact index of judgment principles. Pick the entries whose trigger matches the decision in front of you, read only those `references/<name>.md` files in full, then act. Do not load the whole set.

In your reply, name each principle that changed a decision and the specific choice it changed. Cite only principles whose reference you read this session.

## Precedence

- User instructions, `rules/` files, and `coding-rules` win over these principles where they conflict.
- During active ML or Kaggle exploration, the ML override in `coding-rules` (`references/ml-experiment.md`) wins: no tests by default, no abstractions for hypothetical reuse, linear experiment scripts, sibling experiment isolation. Apply these principles there only where they agree.
- Compatibility and defaulting decisions: `no-fallbacks` is authoritative. Behavior-preserving refactors of production code: follow `refactor-clean`.
- Asking before irreversible or outward-facing actions (push, deploy, deletion, sending messages, commits or PRs the user did not request) always applies.

## Index

**Core**

- `laziness-protocol` - Sizing a diff or tempted to add abstractions, layers, or signal threading. Bias to deletion and the smallest change.
- `foundational-thinking` - Before writing logic: core types, data shapes, scaffold-vs-feature order, what concurrent actors share.
- `redesign-from-first-principles` - Integrating a new requirement into an existing design. Redesign as if it were there from day one.
- `attack-the-premise` - Two or more fixes sharing one premise failed the same check. Write the premise down and test it.
- `subtract-before-you-add` - Sequencing an addition, refactor, or rewrite. Remove dead weight first.
- `minimize-reader-load` - Code that is hard to trace. Count layers and hidden state; collapse one-caller wrappers.
- `outcome-oriented-execution` - Planned rewrites or migrations with phase boundaries. Converge on the end state; no throwaway compatibility.
- `experience-first` - Product, UX, API-ergonomics, or scope tradeoffs. Choose the consumer's experience over implementation convenience.
- `exhaust-the-design-space` - Novel interaction or architecture with no precedent here. Compare 2-3 options before committing.
- `build-the-lever` - Non-trivial bulk edits, migrations, or checks. Build the small script that does or proves it.

**Architecture**

- `model-the-domain` - Stateful logic, growing if/else chains, or a shape assumption repeated across files.
- `boundary-discipline` - Wiring validation, error handling, or adapters. Guard at boundaries, trust inside, keep logic pure.
- `type-system-discipline` - Designing types or signatures. Make illegal states unrepresentable; parse external data once.
- `make-operations-idempotent` - Commands, lifecycle steps, or loops that run amid crashes and retries.
- `migrate-callers-then-delete-legacy-apis` - New internal API while old callers exist. Migrate and delete in one wave.
- `separate-before-serializing-shared-state` - Concurrent actors may write the same file, branch, key, or object.

**Verification**

- `prove-it-works` - Before declaring done. Check the real artifact, not a proxy.
- `fix-root-causes` - Debugging. Fix the first place the system went wrong, not where it surfaced.
- `sequence-verifiable-units` - Multi-step sweeps, migrations, or stacked changes. Each unit ends in a check.
- `test-behavior-not-implementation` - Writing, changing, or keeping a test.
- `explain-the-number` - Before measuring, or before trusting, reporting, or acting on a measured number (speedup, latency, metric, eval score).

**Delegation**

- `guard-the-context-window` - Large outputs, long files, repeated reads, or fan-out planning. Route bulk to subagents.
- `never-block-on-the-human` - Tempted to ask "should I do X?" about reversible work.

**Meta**

- `encode-lessons-in-structure` - Writing the same instruction or correction a second time. Encode it as a check instead.

Adapted from pstack (MIT, Lauren Tan); see LICENSE.pstack.

$ARGUMENTS

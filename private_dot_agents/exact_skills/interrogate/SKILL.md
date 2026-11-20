---
name: interrogate
description: "Use for a heavy adversarial review of a diff, PR, or plan: several independent subagents with different lenses (and models when available) try to break it, and only findings proven by a reproducing run, failing test, or concrete trace survive. Trigger on \"interrogate\", \"adversarial review\", \"try to break this\", \"stress test this PR\", \"tear this apart\", or a high-stakes change the user wants hardened. Do not use for a normal single-pass review (code-review), a security audit (security-review), or mapping what outside the diff could break (blast-radius)."
---

# Interrogate

Independent adversaries try to break a change or design. A finding survives only with proof. Report findings; never fix them. Answer in the user's language.

## Frame

- Scope: what the user names. Otherwise the branch diff from its merge base with main, including uncommitted changes.
- Intent: restate in your own words what the change must do, from the user's message, commits, and PR description. If the intent is unclear, ask before fanning out — adversaries cannot break an intent nobody stated.

## Fan out

Spawn N independent subagents (default 3-4) in one message, running in parallel. Independence is the point:

- Each gets a different lens, e.g. correctness and edge inputs; state, concurrency, and ordering; error paths and partial failure; contracts with callers, config, and data; intent mismatch (does it actually do what it claims, completely).
- Vary the model per subagent if the harness lets you choose; otherwise vary only the lens.
- Give every adversary the same scope, intent, and brief, but never another adversary's output or your own suspicions. A hypothesis handed over comes back "confirmed".
- Each works in its own scratch location (a separate worktree or `/tmp/interrogate-<n>/`). Repro tests and scripts go there. The code under review must not change.

Brief for each adversary (add its lens):

> Break this change. Your lens: <lens>. Prove each finding with a run against the real code: a failing test, a repro script, or command output showing the wrong behavior. For a plan or design, run a prototype or probe the current tree; when nothing can run, give a concrete trace (file:line steps from a specific input to the wrong outcome). Keep all repros in <scratch path>; do not edit the code under review. Report each finding with a title, the exact command (or trace), the output it printed, and the output the intent requires. Leave out anything you did not prove: style, naming, structure, and risks that need a future change to matter. No findings is a valid result.

If an adversary returns nothing or fails, continue with the rest and note the dropout.

## Verify

Do this yourself; do not trust the reports' confidence.

1. Rerun each finding's command (or walk its trace against the code). Keep it only when the output shows the failure and the failure breaks the stated intent.
2. Drop findings that do not reproduce, depend on a misread intent, or are unproven speculation. Keep plausible-but-unproven ones only under **Unproven**, never as findings.
3. Merge findings that share a root cause; record which adversaries hit it. Independent hits on one root cause raise confidence.
4. Keep every verified finding regardless of which adversary found it — adversaries find different failures, so do not pick one list.

## Output

- **Intent**: the restatement.
- **Findings**: ranked by severity. For each: title, the command or trace, its output, the expected output, how it breaks the intent, and which adversaries found it. Say "no verified findings" when none survive.
- **Unproven**: one line each, with what proof is missing.
- **Dropped**: per adversary, count and reason (did not reproduce, out of intent, style).
- **Scratch**: where the repro files are, so the user can reuse or delete them.

Adapted from pstack (MIT, Lauren Tan); see LICENSE.pstack.

$ARGUMENTS

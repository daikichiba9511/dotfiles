# Sequence Work into Verifiable Units

**Apply when:** doing multi-step work (sweeps, migrations, runs of similar edits) and when ordering commits or PRs.

**Rule:** order work as small units that each end in a state you can check, and do not advance until the current one is green.

- Each unit is a bracket: known-good state, one change, run the check, proceed. Run the per-unit check even when a tool made the edits.
- Order delivery so it proves itself: the failing test before the fix, the subtraction before the reshape, the baseline before the treatment.
- When the user asks for commits, make each one single-purpose and able to stand on its own.

**Defers to:** create commits or PRs only when the user asks (`commit`, `pr` skills). For ML, "baseline before treatment" means comparing against the recorded baseline run, not adding tests.

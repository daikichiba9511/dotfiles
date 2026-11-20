# Make Operations Idempotent

**Apply when:** designing commands, lifecycle steps, setup scripts, or processing loops that may run amid crashes, restarts, and retries.

**Rule:** every state-changing operation converges to the correct state however many times it runs and wherever the previous run stopped.

- Derive each step from the state that exists, not from what the previous run meant to do: read current state, compare to the goal, apply only the difference.
- Anything a run leaves behind (lock, temp file, half-written record, claimed job) must be recognizable as stale by the next run, wherever the previous run stopped.
- Write to a temporary path and rename it into place.

**Test:** what happens if this runs twice? What if the previous run crashed at every possible point? If the answer depends on what was left behind, add a reconciliation step.

# Swarm Workflow

## A. Frame and slice

1. State the done predicate and the report the swarm returns.
2. Choose the shape:
   - **Partition** (default): disjoint slices, full coverage required.
   - **Race**: N workers on an identical brief (e.g. hunt a flaky failure). Declare the selection rule before spawning: `first pass`, `rank all`, or `best-of`.
3. List the slices explicitly (package names, file globs, questions, commit SHAs). Check that slices are disjoint for writers; if two slices need the same file, merge them or move that file to a final serial step owned by the parent.
4. For writers, create one worktree and branch per slice from the same base commit. Read-only workers need no isolation.
5. When workers verify or measure commits, the brief names the exact SHAs and the method (command, sample count, order), and the worker must record both in its result.

## B. Fan out

Spawn all workers in one batch, in the background, each with a standalone brief from `brief-template.md`. Over about 8 slices, run waves and aggregate between them.

## C. Aggregate

- Read only the structured reports. Open a worktree or log only to confirm a specific claim.
- Reject a report that lacks what its brief required (status, evidence, SHAs, method) and respawn that worker once with a fresh brief; after a second miss, record a gap. A gap is not a pass.
- Partition: every slice needs a result. Race: apply the rule declared in A.
- Writers: review each slice's diff, then merge branches one at a time into an integration branch, resolving conflicts yourself. Conflicts mean slicing was wrong; note it.
- Run the project's checks once on the integrated result, not only per slice.

## D. Report

One consolidated report in chat:

| Slice | Status | Evidence | Notes |
| --- | --- | --- | --- |

Then issue one-liners (with `file:line` where relevant), gaps and dropouts, the race rule if used, merge and verification status, and worktrees or branches left in place.

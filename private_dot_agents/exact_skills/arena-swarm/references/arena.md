# Arena Workflow

Every candidate gets the same task, so the task statement is the contract.

## A. Frame

1. State the artifact each candidate produces (a branch with a working change, a design doc, a function, a config).
2. Write a rubric of 3-6 concrete, gradeable criteria for this task (e.g. "existing tests pass unchanged", "public API adds at most one type", "no new dependency", "handles empty input"). The rubric is for judging; candidates see only the task and constraints, so they do not optimize to the grader.
3. Decide whether candidates get a design hint each ("approach via X", "approach via Y") or the identical brief. Use distinct hints when you already know the competing directions; use identical briefs when the shape is genuinely open.
4. Create one isolated worktree and branch per candidate from the same base commit, e.g. `git worktree add ../<repo>-arena-<n> -b arena/<slug>-<n> <base-sha>`. Use the harness's worktree isolation if it has one. Non-code artifacts go to `/tmp/arena-<slug>/candidate-<n>/`.

## B. Fan out

Spawn all candidates in one batch, in the background, using `brief-template.md`. Each candidate must also return a short rationale: the alternatives it considered, what it rejected, and why.

## C. Judge

- Read every candidate end to end in its worktree before picking. Score each criterion per candidate; do not score on holistic feel.
- When the choice is costly or close, also spawn one read-only judge subagent with the rubric and the worktree paths (labelled `candidate-1..N`, no rationale text) and compare its scores with yours. Agreement confirms the pick. Disagreement means bias or an ambiguous rubric; reread both rationales before deciding.

## D. Pick a base

Choose the candidate a future maintainer can extend most easily without breaking invariants. On a tie, prefer the cleaner boundary or the smaller API.

## E. Graft

- Walk each losing candidate once more for what is worth porting: usually one or two things per candidate (a missed edge case, a better test, a clearer name), not most of it.
- Fold each graft into the base by hand so the result stays coherent under one mental model. Do not paste or cherry-pick mechanically.
- If candidates converged on one shape, note the strong agreement and ship it without grafts.
- If they diverged wildly, the frame was under-specified: tighten the task or rubric and re-run rather than averaging the divergence.

## F. Verify

Run the project's real checks (tests, type-check, build, or a reproducible demo) on the synthesized branch. If verification finds a problem, either the frame was wrong (re-frame, re-run) or a candidate handled it and the graft was missed (return to E). Do not paper over it.

Finally, remove the losing worktrees and branches unless the user wants to inspect them.

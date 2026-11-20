---
name: arena-swarm
description: "Use to run parallel subagents in one of two modes. Arena: N candidates attempt the same task in isolated worktrees, are judged against an explicit rubric, and the best base is grafted with the strongest parts of the others. Swarm: work is split into N independent slices (packages, files, questions), one worker per slice, drained into one consolidated report. Trigger only on an explicit ask such as \"arena this\", \"try N approaches and pick the best\", \"competing implementations\", \"swarm this\", \"fan out one worker per package\", or \"parallelize across these modules\", or on work that is clearly parallel and large. Do not use for ordinary single-agent tasks, multi-stage research with evidence tables (research-investigation), ML hypothesis experiments (ml-iterate), or adversarial review of a diff (interrogate)."
---

# Arena / Swarm

Spend many subagent runs to buy either a better artifact (arena) or wider coverage (swarm). Answer in the user's language.
This is expensive: if the task fits one agent, say so and do it directly instead.
If the harness cannot spawn subagents (or, in Codex, the user has not asked for them), say so and stop rather than simulating workers inline.

## Pick the mode

- **Arena**: one task, several plausible shapes, and one attempt would lock in the wrong one (API design, a tricky algorithm, a refactor with real alternatives). Output is one artifact.
- **Swarm**: many independent units of the same kind of work (per package, per file group, per question, per commit to verify). Output is one report, plus per-slice changes if workers write.
- Both at once only when explicitly asked; otherwise pick one and state why.

## Shared rules

1. **Frame before spawning.** Write the done predicate and the exact artifact or report to return. Track phases in the todo/plan tool.
2. **Pick N deliberately.**
   - Arena: 2-4 candidates. Raise only for genuinely distinct design directions, not for repeated luck.
   - Swarm: one worker per natural slice; merge slices too small to justify a brief, split slices one worker cannot finish. Cap around 8 concurrent workers and run more in waves.
3. **Isolate writers.** Never let two writers touch the same files, branch, or state object. Give each writer its own git worktree and branch (`arena/<slug>-<n>`, `swarm/<slug>-<slice>`) or its own output directory under `/tmp/`. Workers publish independent results; only the parent merges. If slices share a file, re-slice or serialize that part; instructions alone are not concurrency control.
4. **Briefs stand alone.** A subagent knows only its brief. Use `references/brief-template.md`. Point to files and docs instead of pasting them.
5. **Spawn in one batch, in the background**, then wait for every worker. A dropout means continue with N-1 and record it; respawn once only if the slice is required.
6. **Guard the main context.** Workers return compact structured reports, never raw logs or full diffs. Read candidate code from the worktree when judging, not from chat. Do not paste worker dumps into the final answer.
7. **You own the result.** Review every diff you keep and verify the final state yourself (tests, build, or a concrete check). A worker's PASS is a claim, not evidence.
8. **Clean up.** Remove worktrees and branches you created that are not kept, and say which ones remain.

## Mode workflows

- Arena: follow `references/arena.md` (Frame with rubric, Fan out, Judge, Pick base, Graft, Verify).
- Swarm: follow `references/swarm.md` (Frame and slice, Fan out, Aggregate, Report).

## Output

- Arena: the synthesized artifact on one branch, plus a short synthesis note (base and why, rubric scores, each graft with its source, what was rejected, dropouts, verification result).
- Swarm: one consolidated report (result table per slice, issue one-liners, gaps and dropouts, merge status of any written changes, verification result).

Adapted from pstack (MIT, Lauren Tan).

$ARGUMENTS

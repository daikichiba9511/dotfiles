# Worker Brief Template

Each brief must stand alone; the subagent has none of the parent's context.

```text
Goal: <one sentence: what done means for this worker>
Mode/role: <arena candidate N of M | swarm worker for slice S>
Scope: <exact slice, files, or question>. Do not touch anything outside it.
Working location: <absolute worktree path and branch, or output dir>. Write only here.
Base: <commit SHA the worktree starts from>
Grounding: <file paths, docs, issue links to read; do not expect them pasted>
Constraints: <conventions, forbidden changes, dependencies, time or turn budget>
Verify: <exact command(s) to run before reporting, and what passing looks like>
Report (keep it under ~30 lines, no raw logs or full diffs):
  Status: PASS | ISSUES | BLOCKED
  Summary: <what you did, 2-4 lines>
  Evidence: <commands run and key results; commit SHA if you committed>
  Issues: <every issue you can prove, each one line with file:line>
  Rationale (arena only): <alternatives considered, what you rejected and why>
  Open questions: <anything the parent must decide>
```

Notes:

- Arena candidates get the task and constraints, not the judging rubric.
- Writers commit on their own branch and do not merge, push, or edit other worktrees.
- A worker that proves a defect reports ISSUES and lists all provable issues, not only the first.

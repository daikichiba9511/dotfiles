---
name: blast-radius
description: "Use before a change ships to find what it could break outside the diff (callers, consumers, serialized formats, configs, persisted data, other services, scripts, notebooks, CI) and to prove by running real code the one fact the change's safety depends on. Trigger for 'what could this break', 'blast radius of X', 'is this change safe', or a small diff the user does not trust. Do not use for a general diff review (use code-review), security audits (use security-review), train/inference parity (use ml-consistency), or adversarial multi-agent attacks on a diff (use interrogate)."
allowed-tools: Read, Glob, Grep, Bash(git log:*), Bash(git show:*), Bash(git diff:*), Bash(git grep:*), Bash(git blame:*), Bash(rg:*)
---

# Blast Radius

Find what a change breaks somewhere else, before it ships. Listing callers is not the job; a symbol search finds those in seconds. The job is the breakage a symbol search will not show.
Answer in the user's language.

## Evidence ladder

A writeup that sounds right reads as convincing whether or not it is true. For each fact the change's safety depends on, push it as far down this ladder as is cheap, and say where it stopped:

1. Asserted. Worthless on its own.
2. Cited. A real `file:line`, or the dependency's own source.
3. Ruled out. The failure path walked step by step and shown not to reach.
4. Executed. A small script or test calls the real code and fails loudly if the fact is false.
5. Reproduced in the running app or pipeline.

Level 4 is usually one short script that imports the same library version the project ships and calls the exact function in question. Run it in a scratch location; do not edit project files.

## Workflow

1. **Read the change.** The diff, the commits, and the symbols added, changed, or deleted. State what it now does differently, including behavior the diff does not spell out (defaults, ordering, error paths, types).
2. **Find the load-bearing fact.** Most risky-looking changes are safe because of one fact, e.g. "this only drops cache entries that are already dead". Name it. If it holds, most risks clear at once. Spend effort here, not on a long list of maybes.
3. **Search past the diff.** Beyond direct callers, check:
   - the dependency's source at the pinned version, plus any local patch or vendored copy
   - execution timing: async scheduling, teardown, retries, import-time side effects
   - data contracts: API/JSON shapes, DB columns, file formats, pickled or cached artifacts, checkpoints, another language reading the same bytes
   - string references a symbol search misses: configs, env vars, feature flags, CLI flags, CI workflows, shell scripts, notebooks, docs examples
   - consumers outside this repo and code several hops downstream
4. **Rate each risk honestly.** Give a realistic likelihood and cost. Cite a real `file:line`; a search that returns nothing is a valid answer if you show the query. Never invent a caller or an API.
5. **Prove the load-bearing fact.** Write and run the script or test, and paste the command and its output. If it cannot be run, say why and mark the fact unproven.

## Output

- **What it does** — the change, including the non-obvious part.
- **Load-bearing fact** — the statement, the ladder level reached, and the proof (or "unproven").
- **Risks** — each with the breakage mechanism, `file:line`, likelihood and cost, and how to check.
- **Cleared** — what was checked and why it is fine, with the search or citation.
- **Before merge** — the cheapest test or repro that would catch the real bug, including the script used.

Strip private data before any of this goes somewhere public.

Adapted from pstack (MIT, Lauren Tan).

$ARGUMENTS

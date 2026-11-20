---
name: how-why
description: "Use to explain how an existing subsystem or code path works and why it is built that way, from the code and its git/PR/issue history. Trigger for \"how does X work\", \"walk me through Y before I change it\", \"where should this live / which module owns this\", \"why was Y built this way\", \"why did we pick Z\", or \"teach me this change\". Do not use for defect review of a diff (code-review), new architecture decisions (architect), external or multi-source research syntheses (research-synthesis), or HTML learning artifacts (build-learning-document)."
allowed-tools: Read, Glob, Grep, Bash(git log:*), Bash(git show:*), Bash(git blame:*), Bash(git diff:*), Bash(gh pr view:*), Bash(gh pr list:*), Bash(gh issue view:*), Bash(gh search:*)
---

Explain existing code; never change it. Answer in the user's language. If the scope is ambiguous, state your interpretation and proceed; the user can redirect.

## Pick the mode

- **How**: runtime flow, structure, ownership, placement ("where should this live", "is this the right layer").
- **Why**: motivation, tradeoffs, regressions, thresholds and magic numbers.
- **Both (teach)**: "help me really understand X", explaining a subsystem or change to someone new. Run How and Why (in parallel subagents if the scope is large) and blend them.

## How: trace the code

- Find the entry points and follow the real call path; read the code, not just names and docstrings.
- Identify the main components, who owns which state, the boundaries between layers, and where data enters and leaves.
- For placement questions, show where comparable things already live and which dependency direction the layering enforces.
- Cite `file:line` for every load-bearing claim. Target a mental model an engineer new to the area can work from, not a function inventory.

## Why: read the record, not the code

- Find the commits that introduced the target and each later change: `git log --follow -p <path>`, `git log -S<symbol>` / `-G<regex>`, `git blame -w -C` on the relevant lines, then `git show` the commits.
- Follow commit messages to PRs and issues with `gh` (`gh pr list --search <sha>`, `gh pr view --comments`, `gh issue view`), including review threads. Check in-repo design docs, ADRs, and changelogs when the trail is thin.
- Cite what the authors wrote (commit, PR, or issue link plus a short quote). Mark your own reconstructions explicitly as inference. Say plainly what the record does not answer; do not fill gaps with plausible-sounding rationale.
- Keep confidence language intact when combining with How: hedges are findings, not style.

## Output

- Lead with the direct answer in one or two sentences, then the supporting account.
- How: a plain definition of the thing, then the flow step by step. Use a small diagram only when there are three or more moving parts; for a teaching explanation, build it up in stages rather than one all-at-once picture.
- Why: decisions and tradeoffs, each with its source; separate "documented" from "inferred" from "unknown".
- Teach: tailor depth to why the user is asking (about to change it, reviewing, debugging, new to it) as read from the conversation. Give the smallest complete answer first, then offer to go deeper; no quizzes or walls of text.
- End with open threads worth chasing, if any.

Adapted from pstack (MIT, Lauren Tan).

$ARGUMENTS

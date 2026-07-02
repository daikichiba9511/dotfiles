---
description: Extract learnings from the session and persist them as lessons
allowed-tools: Read, Write, Edit, Glob, Grep
---

Review this session and extract the learnings worth keeping: corrections the user made, approaches confirmed to work, pitfalls hit and how they were resolved, and anti-patterns to avoid.

Persist them to `.claude/lessons/` in the project root — one lesson per file, kebab-case filename, with a one-line summary at the top followed by the why and how to apply it. Record corrections and confirmed approaches alike, including why they mattered. Before creating a file, check whether an existing lesson already covers it and update that one instead; delete lessons that turned out to be wrong. Don't save what the repo, git history, or CLAUDE.md already records.

Finish with a brief summary to the user of the lessons captured and any suggested follow-ups, with concrete examples over abstract advice.

## Additional Instructions

$ARGUMENTS

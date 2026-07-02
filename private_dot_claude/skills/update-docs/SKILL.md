---
description: Sync and update documentation based on code changes
allowed-tools: Read, Edit, Write, Glob, Grep, Bash(git diff:*), Bash(git log:*)
---

Sync documentation with code changes. Review the git diff (or the specified changes), find every document the change invalidates — README, API docs, setup/configuration guides, CHANGELOG, architecture notes, docstrings — and update them: reflect the change, remove stale information, and keep examples accurate and consistent with the code. Write concisely for the document's audience.

When done, summarize what changed in the code and which documents you updated and why.

## Additional Instructions

$ARGUMENTS

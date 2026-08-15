---
name: reconcile-memory
description: Use when the user explicitly asks Codex to remember or forget something, corrects a potentially reusable preference, fact, or instruction, reports a verified change that may supersede existing memory, or asks to audit, clean, or organize long-term memories. Reconcile new information with related stored memories, preserve provenance and temporal validity, and keep stale or inferred claims from being treated as current facts. Do not use for task-local corrections, ordinary summaries, session handoffs, or repository lessons.
---

# Reconcile Memory

Maintain long-term memory as a set of revisable claims with sources and validity, rather than an append-only list of statements.

## Choose the destination first

Classify the information before changing anything.

- Put a required, durable behavior rule in the relevant `AGENTS.md` or project documentation when the user explicitly requests that rule.
- Put the current task state, partial work, and next action in a handoff rather than long-term memory.
- Put reusable facts, decisions, preferences, and corrected assumptions in long-term memory.
- Use the `learn` Skill for reusable repository or workflow lessons. Do not duplicate those lessons in long-term personal memory without a separate reason.
- Do not persist greetings, one-off requests, raw conversation transcripts, recap text, unverified guesses, secrets, authentication data, or sensitive personal data.

## Locate the supported memory input

Prefer dedicated memory tools when they are available. Otherwise, inspect the active Codex home and use its supported ad-hoc note input.

Treat `MEMORY.md`, consolidated summaries, rollout extracts, and other generated memory files as generated state. Read them to find related claims, but do not directly rewrite them as the primary update mechanism.

Before writing, read [the record schema](references/record-schema.md).

## Reconcile the related cluster

1. Search existing memories by the subject, relationship, scope, and known aliases. Do not search only for the exact new wording.
2. Read the smallest cluster that can contain the relevant prior claims.
3. Compare the new information with the cluster and choose one operation:
   - `ADD`: no related claim exists.
   - `REFINE`: the new statement narrows the scope or adds a missing condition without invalidating the earlier claim.
   - `CONFIRM`: independent evidence supports the same claim. Add confirmation only when it materially improves provenance or validity.
   - `SUPERSEDE`: a verified change makes the earlier claim historical from a known time.
   - `CONTRADICT`: credible claims conflict, but the current evidence does not justify choosing one.
   - `REVIEW`: the cluster is ambiguous, duplicated, or depends on unresolved evidence.
4. Write one complete-sentence claim and include the operation, kind, source, evidence status, temporal validity, scope, and links to affected records.
5. Preserve the old record as historical context unless the user explicitly asks to delete it. A superseded claim must not remain eligible as a current fact.
6. Search the cluster once more after writing to verify that the current claim, historical claim, and unresolved uncertainty are distinguishable.

## Judge evidence without fake precision

Use categorical evidence states such as `user-stated`, `observed`, `source-backed`, `inferred`, `disputed`, and `unknown`. Do not invent numeric confidence scores.

An explicit stable preference or instruction can be recorded after one clear statement. An inferred preference stays tentative until the user confirms it or repeated independent evidence supports it. A file, log, or external source can establish an observed fact only within the scope and time that it actually covers.

Do not lower confidence merely because a record is old. Age can make a time-sensitive claim due for review, but durable biographical facts, standing preferences, and historical events do not become false through age alone.

## Keep audits local by default

When a correction or verified change arrives, audit only its related memory cluster. Expand to a wider audit when the user requests it or when several conflicts reveal a shared dependency.

During an audit, look for duplicate current claims, missing supersession links, inferred claims presented as facts, scope that became broader during summarization, and historical claims that still influence current answers.

## Report the result

Tell the user briefly what was added, refined, superseded, marked disputed, or left for review. Name the unresolved point when the evidence was insufficient. Do not claim that generated consolidation has finished unless it was actually observed.

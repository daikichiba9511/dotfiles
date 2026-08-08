---
name: research-investigation
description: "Use for a multi-stage research investigation that explicitly benefits from scoped research subagents, evidence tables, critical review, and possible experiment handoff. Do not use for a bounded lookup or normal source-backed comparison; use research-synthesis instead."
---

# Research Investigation

## Overview

Use this skill for research exploration where the hard work is decomposition,
evidence quality, contradiction handling, and final synthesis. Keep broad
search and noisy extraction in subagents; keep judgment and decision records in
the parent thread.

## Workflow

### 1. Frame the decision

Before searching, define:

- decision to be made
- in-scope and out-of-scope topics
- current hypothesis, or mark it as unknown
- observations that would support the hypothesis
- observations that would reject it
- required evidence level
- stopping condition

If context is incomplete, state reasonable assumptions and continue.

### 2. Decompose into subquestions

Split the investigation into mutually distinct subquestions. Prefer narrow
questions such as:

- original paper, spec, or theory and its assumptions
- reproduction attempts and negative results
- implementation constraints in existing code
- comparison against related methods or tools
- fit to the user's data, architecture, or operating constraints

Avoid giving multiple subagents the same broad prompt.

### 3. Delegate evidence gathering

When the user explicitly asks for subagents or parallel research, spawn one
`research_scout` per subquestion. Ask each scout to:

- prefer primary sources
- separate facts, source claims, and inference
- collect supporting and contradicting evidence
- include source title or file path, date or version, and relevant location
- return a compact evidence table
- stay within its assigned subquestion

Wait for all scouts before synthesis.

### 4. Synthesize evidence

Merge scout outputs into this table:

| Item | Content |
| --- | --- |
| Claim | What appears likely to be true |
| Supporting evidence | Primary sources, code, or experiments |
| Contradicting evidence | Sources or results that do not fit |
| Applicability | Conditions where the claim holds |
| Confidence | High, medium, or low |
| Unresolved points | What remains unknown |
| Next experiment | Minimum check that would reduce uncertainty |

Do not hide contradictions. Preserve conditions that would change the answer.

### 5. Run independent critique

After synthesis, spawn `research_critic` when subagents are requested or when
the conclusion affects a costly implementation or research direction. Provide
the synthesis, assumptions, and proposed decision. Ask it to check:

- missed counterevidence
- confounders and alternative explanations
- metric, baseline, or comparison problems
- conditions where the conclusion fails
- evidence that would reverse the decision
- minimum additional experiments

Revise the synthesis after reading the critique.

### 6. Separate experiments from exploration

Only use `research_experimenter` after the hypothesis is narrowed. Pass only:

- hypothesis
- independent and dependent variables
- baseline
- metrics
- fixed conditions
- rejection criteria
- required output format

Do not ask the experimenter to redo literature or codebase exploration.

## Final Output

Return:

1. Research questions
2. Confirmed facts
3. Main hypotheses
4. Supporting evidence
5. Counterevidence and objections
6. Uncertainty
7. Current judgment
8. Confidence
9. Minimum next experiment

Keep the answer concise unless the user asks for a full memo.

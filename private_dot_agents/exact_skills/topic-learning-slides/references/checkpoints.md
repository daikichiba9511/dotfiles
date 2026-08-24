# Semantic checkpoints and backtracking

## Purpose

Check the work after each meaningful unit rather than repairing only the final PDF. A checkpoint records whether the current artifact still answers the original question and whether downstream work may begin.

`reviews/checkpoints.md` is the only authoritative checkpoint state. Do not duplicate pass or fail fields inside scope, argument-map, or outline files.

Append one row for every attempt. Never rewrite or delete an earlier row. Use:

| field | meaning |
|---|---|
| `attempt_id` | increasing ID such as `A-001` |
| `checkpoint` | `C1`, `C2a`, `C3`, `C2b`, `C4`, `C5`, or `C6` |
| `artifact` | semicolon-separated workspace-relative files inspected |
| `artifact_hash` | SHA-256 of the listed files in their recorded order |
| `status` | `pass`, `revise`, or `blocked` |
| `finding` | concrete mismatch, gap, or risk |
| `action` | accepted correction or reason for no change |
| `invalidates` | downstream checkpoints made stale, or `none` |
| `supersedes` | prior attempt ID for the same checkpoint, or `none` |

The validator recomputes `artifact_hash`; a changed artifact makes the latest pass stale. A new upstream correction invalidates every downstream pass until it is rerun. The current release state is the latest row for each required checkpoint, and every row must be a fresh `pass`.

Do not mark a checkpoint passed merely because the artifact exists.

## C1: Scope alignment

Inspect `research/scope.md`.

- Does the central question match the user's request?
- Does the intended reader match the assumed vocabulary and explanation depth?
- Is the desired use understanding, decision, comparison, implementation, or transfer?
- Are inclusions and exclusions explicit?
- Would answering the subquestions actually answer the central question?

If not, revise the scope. Discard downstream structure that depends on the wrong framing.

## C2a: Research-question evidence sufficiency

Inspect the frozen research questions, source ledger, and claim ledger before creating the issue map.

- Does every research question have evidence or an explicit limitation?
- Are primary sources used for consequential facts when available?
- Are counterexamples and conflicting definitions represented?
- Are direct observation, source claims, reproduction, and inference distinct?
- Would missing evidence change the claim strength?

If not, collect more evidence, narrow the question, or make the limitation a first-class claim.

## C3: Argument alignment

Inspect `synthesis/argument-map.md`.

- Does the issue map answer the central question rather than mirror source headings?
- Are the major issues broad enough to organize details but specific enough to test?
- Is every relationship named: prerequisite, alternative, composition, trade-off, refinement, counterexample, evidence, or sequence?
- Does every detail have one primary issue and only justified secondary issue relationships?
- Do any details imply that a missing top-level issue should be added?
- Does a conclusion contradict the scope, evidence, or another issue?

If the argument drifted, return to C1. If the structure lacks evidence, return to C2a.

## C2b: Issue and claim coverage

Inspect the accepted issue map and claim ledger.

- Does every top-level issue point to supporting claims or an explicit evidence limitation?
- Does every consequential claim have a source, evidence label, confidence statement, and disposition?
- Does every `main` or `detail` claim name one valid primary issue?
- Are secondary issue relationships explicit rather than duplicated as separate claims?
- Are excluded claims accompanied by a reason?

If not, collect missing evidence, revise the issue map, or record the limitation before C4.

## C4: Narrative recoverability

Inspect `synthesis/slide-outline.md` before prose.

- Do the titles alone reveal the broad route?
- Do titles and claims move from overview to detail?
- Does every slide receive established context and pass forward a useful question or conclusion?
- Are cases and implementations delayed until their organizing issue is understood?
- Is a premise used before it is introduced?
- Does the outline repeat a conclusion instead of advancing it?

If the route cannot be reconstructed, revise the outline or argument map before layout.

## C5: Japanese logic reconstruction

Inspect each coherent group of drafted slides and `reviews/prose-reconstruction.csv`.

- Is the prose rewritten as Japanese rather than copied from scratch notes?
- Can the subject, relation, object, condition, result, and uncertainty be recovered where material?
- Do particles and conjunctions make causal, contrastive, conditional, and sequential relations explicit?
- Are topic-specific terms explained before abbreviation?
- After shortening, can one unambiguous expanded proposition be reconstructed?
- Does each paragraph advance one claim and connect to its neighbors?
- Does every shortened slide group have a passing reconstruction record?

If not, restore the missing relation, split the sentence or slide, or revise the terminology ledger. Do not solve a logic failure by changing font size.

## C6: Deck integrity

Inspect source, PDF, full-resolution renders, and contact sheets under `reviews/renders/`.

- Does every slide have one logical job and obvious first reading target?
- Are all factual claims and representations traceable to source IDs?
- Does the abstract issue map remain recognizable before details?
- Do detailed pages support rather than contradict the overview?
- Are limitations visible where they change interpretation?
- Is there any clipping, overlap, overflow, tiny text, isolated-character wrap, or accidental continuation?
- Can the final checklist or decision order be derived from the preceding argument?

If a visual finding is local, fix and rerun C6. If a page is dense because several logical jobs were merged, return to C4. If the prose was compressed until relations disappeared, return to C5. If the overview and details disagree, return to C3 or C2b depending on the cause.

## Backtracking rule

Always return to the earliest checkpoint that could have prevented the failure:

`wrong question -> C1`

`unsupported research question -> C2a`

`misplaced or contradictory issue -> C3`

`unsupported issue or undispositioned claim -> C2b`

`unrecoverable sequence -> C4`

`unnatural or logically compressed Japanese -> C5`

`geometry or rendering defect -> C6`

After correction, rerun that checkpoint and every downstream checkpoint. Append the backtrack and supersession records instead of silently patching the final slide.

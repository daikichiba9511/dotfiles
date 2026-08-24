# Argument architecture for understanding slides

## Purpose

Turn collected evidence into a mental model. The reader should first see the shape of the problem, then understand the relationships among its parts, and only then inspect detailed cases.

## Build the issue map

Use this hierarchy:

`central question -> major issue -> subquestion -> mechanism or comparison -> evidence -> implication -> limit`

The major issues are not source categories. They are the smallest set of questions needed to answer the central question. A paper, implementation, product, team, or case belongs under the issue it helps explain.

For each major issue, record:

- why the issue matters to the central question;
- the main alternatives or competing explanations;
- how it connects to the other issues;
- the detailed mechanisms or examples below it;
- supporting and contradicting evidence;
- what remains unknown;
- what the reader should be able to decide afterward.

Prefer three to six major issues. More usually means the abstraction is too weak or several details have been promoted prematurely.

## Bidirectional coverage

Give every claim or detail exactly one primary issue and zero or more secondary issue relationships. A primary issue identifies the main explanatory role. A secondary relationship records a real cross-cutting effect without duplicating the detail or pretending it has only one consequence.

Maintain both directions in `synthesis/argument-map.md`:

| issue_id | central-question link | primary claim IDs | secondary claim IDs | counterevidence | uncovered requirement |
|---|---|---|---|---|---|

Then verify the reverse direction from `research/claim-ledger.csv`: every `main` or `detail` claim names a valid primary issue, and every issue points to at least one claim or an explicit evidence limitation. This prevents a polished issue heading with no evidence and prevents a researched detail from disappearing during abstraction.

## Relationship types

Name the relationship instead of placing boxes near each other:

- prerequisite: B depends on A;
- alternative: A and B solve the same problem differently;
- composition: A and B operate at different stages and can be combined;
- trade-off: improving one quantity worsens another;
- refinement: B narrows or extends A;
- counterexample: B limits the generality of A;
- evidence: B supports or weakens A;
- sequence: A must be evaluated before B.

Do not write `AとBは関係する` when one of these relations can be stated.

## Default abstract-to-detail narrative

1. **Reader question:** state what the reader will be able to explain or decide.
2. **Concrete topic:** give one input/output, example, or observed failure.
3. **Definitions and scope:** define only concepts needed by later reasoning.
4. **Simple mental model:** show the baseline explanation or ordinary pipeline.
5. **Issue overview:** show the major issues and how they relate.
6. **Shared mechanism:** explain the structure common across cases.
7. **Alternatives and tensions:** compare distinct ways to address the same issue.
8. **Counterexample or failure:** bound the conclusion.
9. **Issue details:** explain one mechanism, comparison, or case at a time.
10. **Decision order:** show what to inspect or test first.
11. **Transfer boundary:** separate general principles from topic-specific details.
12. **Evidence limits:** state what the sources cannot establish.
13. **Detailed references:** provide source-specific implementations or cases when useful.

This is a default, not a fixed table of contents. Merge only adjacent units that form one causal step. Split whenever a reader would otherwise infer a missing premise, operation, comparison, or consequence.

## Slide-outline record

Before prose, record for every planned slide:

| field | question |
|---|---|
| `slide_id` | what stable identifier tracks this page? |
| `title` | what concrete subject or question is this slide about? |
| `claim` | what one proposition should the reader retain? |
| `incoming` | what established fact or unresolved question does it receive? |
| `evidence` | which claim and source IDs support it? |
| `outgoing` | what question or conclusion does it pass forward? |
| `role` | context, mechanism, evidence, comparison, counterexample, decision, reference |
| `representation` | prose, example, equation, diagram, table, or none |

## Alignment checks

Read the outline in three passes:

1. **Titles only:** can the broad route be stated without reading body text?
2. **Titles and claims:** does every slide advance the central question rather than merely add facts?
3. **Incoming and outgoing:** is every transition explicit, and does any slide require a premise not yet introduced?

If a detail is interesting but does not advance a major issue, move it to detailed references. If several details point to a missing shared issue, revise the issue map before adding more pages.

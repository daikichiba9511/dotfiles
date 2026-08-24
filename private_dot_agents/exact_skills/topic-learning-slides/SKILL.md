---
name: topic-learning-slides
description: "Use as the single end-to-end Skill when the requested deliverable is a source-backed Japanese 16:9 Typst/Polylux deck for understanding a user-selected technical or conceptual topic. Trigger for requests such as `Xを調べて理解用スライドにして` or `調査結果を論点から各論へ整理して`. It owns research, argument design, Japanese rewriting, slide composition, and semantic/rendered QA. Do not use for a single lookup, a memo without slides, an unresearched presentation, minor deck edits, or Kaggle rank/solution collection itself."
---

# Topic Learning Slides

Research one topic and create a Japanese slide deck that helps the user build a reusable mental model. Do not expose internal scratch notes as finished prose. Convert evidence into an argument, then rewrite that argument in natural Japanese before composing slides.

## Outputs

Create or update these artifacts under the user-selected workspace:

1. `research/scope.md`: topic, reader, purpose, prior knowledge, central question, exclusions;
2. `research/source-ledger.csv`: source, evidence type, inspected scope, supported claims, limitations;
3. `research/claim-ledger.csv`: one consequential proposition per row, with scope, evidence, uncertainty, and disposition;
4. `synthesis/argument-map.md`: top-level issue map, relationship map, and bidirectional issue/detail coverage;
5. `synthesis/slide-outline.md`: abstract-to-detail sequence and slide-level purpose;
6. `synthesis/terminology.md`: canonical Japanese terms and first-use explanations;
7. `reviews/checkpoints.md`: authoritative append-only checkpoint history;
8. `reviews/prose-reconstruction.csv`: expanded and shortened propositions used by C5;
9. `reviews/renders/`: full-resolution page renders and contact sheets used by C6;
10. `slides/slides.typ` and `slides/slides.pdf`: 16:9 Polylux deck with inline source IDs and a source appendix.

When a chained caller already has equivalent scope, source, or evidence artifacts, preserve those canonical files and record a path mapping in the checkpoint review instead of copying the same evidence into parallel ledgers.

Use the bundled template at `assets/workspace-template/` through the deterministic initializer when starting from an empty directory:

```bash
uv run --python 3.12 <skill-root>/scripts/init_workspace.py <workspace>
```

The initializer refuses a non-empty destination. Preserve the generated paths so later checks remain predictable.

## Read the reference for the active phase

Read each selected reference completely before performing that phase.

| Phase | Read |
|---|---|
| scope, questions, source collection, evidence labels | [research-contract.md](references/research-contract.md) |
| issue map, broad-to-detail narrative, slide outline | [argument-architecture.md](references/argument-architecture.md) |
| Japanese drafting, shortening, logic reconstruction | [japanese-slide-writing.md](references/japanese-slide-writing.md) |
| Typst/Polylux composition and rendered QA | [typst-polylux.md](references/typst-polylux.md) |
| all semantic checkpoint decisions | [checkpoints.md](references/checkpoints.md) |

Resolve all paths relative to this `SKILL.md`. For a chained workflow, the caller may provide an already verified research packet; register that packet as the starting evidence instead of recollecting it.

## Workflow

### 1. Freeze the reader and question

Write `research/scope.md` before broad collection. Define:

- the exact topic and central question;
- what the user wants to understand, decide, or transfer;
- the intended reader and assumed knowledge;
- what requires explanation and what may remain assumed;
- the time, source, and output boundaries.

Run checkpoint C1. If the central question is broader, narrower, or different from the request, revise the scope before research.

### 2. Collect and label evidence

Research the topic from primary and authoritative sources where possible. Record every consequential source in `research/source-ledger.csv`. Separate directly observed facts, source-author claims, independent reproduction, inference, and unavailable evidence.

Extract claims into `research/claim-ledger.csv` before writing prose. Keep one consequential claim per row, with scope, assumptions, counterevidence, uncertainty, destination, and exclusion rationale. Do not smooth conflicting sources into one answer.

Run checkpoint C2a against the frozen research questions. If a question lacks evidence or a material counterexample is unaccounted for, return to collection or narrow the question. Do not claim that every top-level issue is supported before those issues exist.

### 3. Build the issue map

Write `synthesis/argument-map.md` before the slide outline. Start with the broad problem space:

`central question -> major issues or axes -> relationships and alternatives -> detailed mechanisms or cases -> evidence and limits`

For each major issue, record why it belongs, how it relates to the central question, which detailed claims support it, and what would contradict it. Give each detail one primary issue and zero or more explicit secondary issue relationships. Do not begin with a list of implementations, papers, products, or teams. Place those details under the issue they illuminate.

Run checkpoint C3. If a detail does not advance one top-level issue, move it, demote it to reference material, or remove it. If the issue map no longer answers the original question, return to C1.

Then run checkpoint C2b against the accepted issue map and claim ledger. Every top-level issue must be supported or explicitly limited, and every consequential claim must have a disposition. If this fails, return to collection or revise the issue map before outlining slides.

### 4. Design the learning sequence

Write `synthesis/slide-outline.md` from the accepted issue map. Use this default reading order:

1. reader question and concrete topic;
2. definitions, scope, and simple baseline or current mental model;
3. overview of the major issues and their relationships;
4. shared mechanisms, alternatives, tensions, and counterexamples;
5. evidence-backed detail for each issue;
6. implications, decision order, or reusable checklist;
7. evidence limits;
8. detailed cases, implementations, papers, or source-specific references when they help verification.

Give every slide one logical job. Record its title, claim, incoming context, evidence, outgoing context, and visual role. Page count is not a compression target.

Run checkpoint C4. Read only the titles and claims. If the logical route cannot be recovered, revise the outline before drafting slide prose.

### 5. Rewrite into natural Japanese

Create `synthesis/terminology.md`, then draft slide text. Treat internal summaries, labels, noun chains, and translated English fragments as notes, not publishable Japanese.

Write complete Japanese relations: name the subject, operation, affected object, pipeline stage or condition, result, and uncertainty when they matter. Use ordinary ML or domain terminology when the reader contract permits it, but define topic-specific operations before abbreviating them.

When shortening, preserve the logical structure. Remove repetition and incidental detail first; never shorten primarily by dropping particles, conjunctions, subjects, or predicates. After every substantial shortening, reconstruct the expanded proposition from the remaining sentence. If two materially different interpretations are possible, restore the missing relation or split the slide.

Run checkpoint C5 on each coherent slide group. Record the expanded proposition, published claim, reconstructed proposition, ambiguity, and correction in `reviews/prose-reconstruction.csv`. If the Japanese reads like scratch reasoning, translation fragments, or disconnected labels, rewrite it before Typst layout.

### 6. Compose the Typst deck

Read `typst-polylux.md`. Use 16:9 Polylux with `metropolis-polylux`, a restrained visual system, nearby citations, and one clear reading target per slide. Use diagrams, equations, examples, and tables only when they make a relationship easier to understand.

Keep the abstract overview visually recognizable before the detailed slides. Do not let attractive layout hide missing premises or unsupported transitions.

### 7. Validate and backtrack

Run checkpoint C6, compile, render every page under `reviews/renders/`, inspect full-resolution pages and contact sheets, and record the result in `reviews/checkpoints.md`.

After any meaningful correction, rerun the affected checkpoint and all downstream checkpoints. Do not patch a late slide locally when the failure comes from the scope, issue map, or argument order; return to the earliest failed checkpoint.

Before release, run the deterministic validator:

```bash
uv run --python 3.12 <skill-root>/scripts/validate_workspace.py <workspace> --require-pdf
```

It rejects unresolved template text, missing claim or source mappings, stale checkpoint hashes, missing source appendix entries, and missing final artifacts. A passing command does not replace full-resolution visual inspection.

## Completion contract

Finish only when:

- the central question still matches the request;
- each top-level issue is supported by evidence or explicitly limited;
- the deck moves from a broad issue map to details rather than opening with disconnected cases;
- every detailed slide advances a named top-level issue;
- facts, source claims, inference, and uncertainty remain distinguishable;
- shortened Japanese still allows the original proposition and causal relation to be reconstructed;
- the prose is natural Japanese rather than internal scratch text or translated noun chains;
- every slide has one logical job and a recoverable transition;
- Typst compiles and every rendered page passes geometry and legibility inspection;
- the user receives output paths, page count, evidence limitations, and checkpoint results.

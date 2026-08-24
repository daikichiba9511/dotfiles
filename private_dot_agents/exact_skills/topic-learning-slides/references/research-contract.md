# Research and evidence contract

## Purpose

Collect enough evidence to explain the topic's main structure, not merely enough links to fill slides. The research output must let another reader distinguish what is known, what a source claims, what is inferred, and what remains unresolved.

## Scope contract

Before collection, write:

- topic and exact central question;
- intended use: understanding, comparison, decision, implementation orientation, or transfer;
- reader knowledge that may be assumed;
- terms, mechanisms, or domain context that must be explained;
- inclusion and exclusion boundaries;
- temporal cutoff when the topic may change;
- expected public or private release boundary.

Convert a broad topic into three to seven research questions. Each question must change the final mental model or decision. Do not create subquestions only because sources use those headings.

## Source priority

Prefer, in order when applicable:

1. official specifications, documentation, source code, datasets, or organizer statements;
2. peer-reviewed papers or stable preprints describing the actual method;
3. author or participant technical reports with concrete evidence;
4. independent reproductions, benchmarks, or critiques;
5. secondary explanations for discovery or context only.

For current products, standards, software, law, policy, prices, or active research areas, verify live sources. Keep the retrieval date. Do not rely on search snippets for consequential claims.

## Source ledger

Use these fields:

| field | meaning |
|---|---|
| `source_id` | stable local identifier |
| `title` | source title |
| `url_or_path` | stable URL or local path |
| `source_type` | official, paper, author-report, reproduction, secondary |
| `inspected_scope` | sections, pages, files, or data actually inspected |
| `supported_claims` | claim IDs supported by this source |
| `limitations` | missing context, conflicts, inaccessible artifacts, or temporal risk |
| `retrieved_at` | retrieval date |

One source may support several claims, but do not treat source-level credibility as proof of every sentence in it.

## Claim extraction

Use `research/claim-ledger.csv` with this exact header:

```csv
claim_id,proposition,scope_or_condition,evidence_type,supporting_source_ids,counterevidence,confidence_or_uncertainty,primary_issue_id,secondary_issue_ids,destination,exclusion_rationale
```

For each consequential claim, record:

- a concrete proposition;
- the object, condition, and scope;
- evidence type;
- supporting source IDs;
- counterevidence or alternatives;
- confidence and uncertainty;
- whether the claim belongs in the main argument, a detailed reference, or is excluded.

Use stable IDs such as `C-001`. `primary_issue_id` may remain empty only until C3 creates the issue map. `secondary_issue_ids` is a semicolon-separated list and may be empty. `destination` is `main`, `detail`, or `excluded`; an excluded row requires `exclusion_rationale`.

Use these evidence labels consistently:

- `directly-observed`
- `official-or-organizer`
- `author-reported`
- `independently-reproduced`
- `inference`
- `unavailable`

A chained caller may own a narrower evidence vocabulary. In that case, preserve the caller's labels and record this crosswalk instead of rewriting the source ledger:

| generic meaning | accepted caller label |
|---|---|
| `official-or-organizer` | `organizer-confirmed` |
| `author-reported` | `participant-reported` |
| `directly-observed` | `directly-observed` |
| `independently-reproduced` | `independently-reproduced` |
| `inference` | `inference` |
| `unavailable` | `unavailable` |

The caller owns the vocabulary. The chained slide workflow must not create a second ledger merely to rename evidence labels.

Do not merge independent interventions, mechanisms, or limitations into one vague claim. Do not convert absence of evidence into evidence of absence.

## Research sufficiency

Run sufficiency in two stages. C2a asks whether each frozen research question has enough evidence to shape a defensible issue map. After C3 creates that map, C2b asks whether every top-level issue and consequential claim is supported or explicitly limited.

Research is sufficient when:

- every top-level issue has at least one direct or clearly attributed source;
- the main alternative explanation or counterexample has been sought;
- conflicting definitions and measurements are exposed;
- missing evidence changes the strength of the conclusion rather than disappearing from prose;
- further collection would mostly add repetition rather than change the issue map.

If the topic is too broad for these conditions, narrow the central question instead of producing shallow coverage.

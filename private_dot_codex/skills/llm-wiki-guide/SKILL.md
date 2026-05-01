---
name: llm-wiki-guide
description: "Explain the LLM Wiki pattern and Codex LLM Wiki skills. Use when the user asks what LLM Wiki is, how the wiki works, which llm-wiki command to use, how init/ingest/query/lint fit together, or says 'LLM Wikiって何？', 'wikiの使い方を教えて', 'wiki skillの概要', 'how does the wiki work', 'どのllm-wiki skillを使う？'."
---

# LLM Wiki Guide

Explain the LLM Wiki pattern and available Codex skills without modifying files.
Adapt depth to the user's context: if a wiki already exists, focus on operations and current state; otherwise explain the concept and next step.

## Usage

`$llm-wiki-guide [topic]`

| Topic | Explain |
| --- | --- |
| empty | Full overview: concept, architecture, skills, workflow, next action |
| `concept` | Core idea and why it differs from RAG |
| `architecture` | Files, ownership, and markdown layout |
| `skills` | Which `$llm-wiki-*` skill to use |
| `workflow` | Typical session flow |
| `status` | Existing wiki state and suggested next action |

## Context Detection

1. Search for `AGENTS.md` files that mention `LLM Wiki`.
2. Fallback to legacy `_schema.md` files that mention `LLM Wiki`.
3. If one wiki exists, read `overview.md`, `index.md`, and the latest entries in `log.md` only when useful for the requested topic.
4. If multiple wikis exist, ask which one to describe.
5. If no wiki exists, explain the pattern and suggest `$llm-wiki-init`.

## Explanation Content

### Core Idea

LLM Wiki is a persistent, compounding markdown knowledge base. Unlike RAG, where the model re-discovers knowledge from raw documents at query time, Codex reads curated sources once and integrates them into maintained pages: summaries, entities, concepts, analyses, syntheses, cross-links, contradictions, and an overview.

The user curates sources, asks questions, and directs emphasis. Codex maintains the bookkeeping: summarizing, linking, updating pages, recording contradictions, and keeping `index.md` and `log.md` current.

### Architecture

```text
wiki/
  AGENTS.md
  overview.md
  index.md
  log.md
  raw/
    assets/
  pages/
    entities/
    concepts/
    sources/
    analyses/
    syntheses/
```

| Area | Owner | Rule |
| --- | --- | --- |
| `raw/` | User | Curated immutable sources and assets. |
| `pages/` | Codex | Generated and maintained wiki pages. |
| `AGENTS.md` | User + Codex | Living schema and operating contract. |
| `overview.md` | Codex | Current top-level synthesis and open questions. |
| `index.md` | Codex | Catalog used to find relevant pages. |
| `log.md` | Codex | Chronological record of wiki changes. |

### Skills

| Skill | Use |
| --- | --- |
| `$llm-wiki-init` | Create a new wiki structure and initial schema. |
| `$llm-wiki-ingest` | Add a source and integrate it into existing pages. |
| `$llm-wiki-query` | Answer from accumulated wiki knowledge and optionally save durable answers. |
| `$llm-wiki-lint` | Audit links, contradictions, source coverage, stale claims, and schema drift. |
| `$llm-wiki-guide` | Explain the system and choose the next operation. |

### Workflow

```text
1. $llm-wiki-init research/wiki
2. Put curated articles, papers, notes, or assets in raw/
3. $llm-wiki-ingest raw/article.md
4. $llm-wiki-query "What are the trade-offs?"
5. Save useful answers as analyses or syntheses when they should compound
6. $llm-wiki-lint --fix
7. Repeat ingest, query, and lint as the wiki grows
```

## When Not To Use

- For Kaggle or ML experiment documentation, use `$ml-docs guide` or `$ml-docs init`.
- For atomic concept memos, use `$zettel-create`.
- For one-off research that should not persist, use normal research or `research-synthesis` instead.

## Output Rules

- Do not create or modify files.
- Keep the explanation concise unless the user asks for depth.
- If a wiki exists, include concrete next actions based on its current state.
- If no wiki exists, end by suggesting `$llm-wiki-init`.

# LLM Wiki Pattern

Source: Andrej Karpathy's "LLM Wiki" gist, https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f

## Core Model

- Raw sources are the curated, immutable source of truth.
- The wiki is a persistent markdown layer maintained by the LLM: source summaries, entity pages, concept pages, analyses, overview, and durable syntheses.
- The schema is the operational contract that tells the LLM how to structure and maintain the wiki. For Codex, use `AGENTS.md` at the wiki root.
- Knowledge should compound. New sources update existing pages, cross-references, contradictions, and summaries instead of being rediscovered from raw material on every query.

## Operations

- `init`: create the raw/wiki/schema/index/log structure and document conventions.
- `ingest`: read one or more sources, create source summaries, update entity and concept pages, update `index.md`, and append `log.md`.
- `query`: answer from the wiki first, cite wiki pages, and optionally save valuable answers as analysis or synthesis pages.
- `lint`: audit contradictions, stale claims, missing links, orphan pages, missing concept pages, and source coverage gaps.

## Defaults

- Use `raw/` for original sources and local assets.
- Use `pages/sources/` for source summaries.
- Use `pages/entities/` for people, organizations, products, projects, places, and named systems.
- Use `pages/concepts/` for ideas, methods, themes, mechanisms, and recurring patterns.
- Use `pages/analyses/` for synthesized answers, comparisons, timelines, and decision notes.
- Use `pages/syntheses/` for durable cross-source conclusions, evolving theses, state-of-the-field notes, and major periodic summaries.
- Use `overview.md` as the living top-level synthesis and current map of the wiki.
- Use `index.md` as the content catalog and `log.md` as the chronological activity record.

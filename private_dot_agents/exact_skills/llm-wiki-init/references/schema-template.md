# LLM Wiki Initial Templates

Use these as starting points and adapt them to the user's domain.

## AGENTS.md

```markdown
# LLM Wiki Instructions

This directory is a persistent LLM-maintained markdown wiki. Follow these rules for all files under this directory.

## Architecture

- `raw/`: immutable user-curated sources and assets. Read these files, but do not rewrite them.
- `overview.md`: living top-level synthesis of the wiki's current understanding, strongest themes, and open questions.
- `pages/sources/`: one summary page per ingested source.
- `pages/entities/`: pages for people, organizations, products, projects, places, and named systems.
- `pages/concepts/`: pages for concepts, methods, theories, themes, and recurring patterns.
- `pages/analyses/`: saved answers, comparisons, timelines, and synthesized notes.
- `pages/syntheses/`: durable cross-source syntheses, evolving theses, state-of-the-field notes, and major periodic summaries.
- `index.md`: content catalog. Update it whenever pages are created or materially changed.
- `log.md`: append-only activity log. Add one entry for each ingest, saved query, lint, or maintenance pass.

## Operational Preferences

- Default ingestion mode: review the planned integration before large, ambiguous, or high-impact edits.
- Preferred emphasis:
- Preferred output formats:
- Domain-specific page categories:

## Source Admission Policy

- Curated scope:
- Preferred source types:
- Minimum quality bar:
- Duplicate or near-duplicate handling:
- Off-topic or low-quality sources should be deferred unless the user explicitly wants them ingested.
- When source fit is uncertain, ask before ingesting or record the assumption in the ingest log.

## Schema Evolution

- Treat this file as a living operating contract between the user and Codex.
- When repeated workflow preferences, naming conventions, page categories, tag conventions, or review expectations emerge, propose an `AGENTS.md` update.
- Apply schema updates only when explicitly requested or when the user has already stated the preference clearly.

## Page Format

Use YAML frontmatter on generated wiki pages:

---
title: Page Title
category: source | entity | concept | analysis | synthesis
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: []
sources: []
---

## Link Rules

- Use standard markdown links with relative paths.
- Link to existing pages whenever an entity, concept, source, or analysis is materially discussed.
- When a linked page does not exist but should, note it as a candidate rather than silently creating many pages.

## Maintenance Rules

- Preserve sourced claims. If new information contradicts old information, record the contradiction with both sources.
- Prefer append/update over deletion. Delete generated wiki content only when explicitly asked.
- Keep source-backed claims tied to `sources`.
- Update `overview.md` when the wiki's top-level synthesis changes.
- Update `index.md` and append `log.md` after each meaningful change.
```

## overview.md

```markdown
---
title: Wiki Overview
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# Wiki Overview

## Current Synthesis

What the wiki currently understands at the highest level.

## Strongest Themes

- Durable theme backed by multiple pages or sources.

## Open Questions

- Question that needs more sources, analysis, or user direction.

## Recent Changes

- YYYY-MM-DD: Important ingest, query, lint, or synthesis update.
```

## index.md

```markdown
---
title: Wiki Index
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# Wiki Index

## Entities

| Page | Summary | Updated |
| --- | --- | --- |

## Concepts

| Page | Summary | Updated |
| --- | --- | --- |

## Sources

| Page | Raw Source | Ingested |
| --- | --- | --- |

## Analyses

| Page | Summary | Created |
| --- | --- | --- |

## Syntheses

| Page | Summary | Updated |
| --- | --- | --- |
```

## log.md

```markdown
---
title: Wiki Log
created: YYYY-MM-DD
---

# Wiki Log

<!-- Entries use: ## [YYYY-MM-DD] type | Title -->
<!-- Types: init, ingest, query, lint, update -->

## [YYYY-MM-DD] init | Wiki initialized

- base_dir: wiki/
- structure: raw/, overview.md, pages/(entities, concepts, sources, analyses, syntheses)
- schema: AGENTS.md
```

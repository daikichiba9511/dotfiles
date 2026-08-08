# LLM Wiki Page Templates

## Source Page

```markdown
---
title: Source Title
category: source
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: []
sources:
  - raw/source-file.md
original_url:
---

# Source Title

## Summary

Three to five sentences covering the source's purpose, scope, and most important contribution.

## Key Claims

- Claim with enough context to be useful later.

## Details

Organize by the source's structure or by the wiki's domain model.

## Entities

- [Entity](../entities/entity.md): why it matters in this source.

## Concepts

- [Concept](../concepts/concept.md): why it matters in this source.

## Open Questions

- Follow-up question or missing source.
```

## Entity Or Concept Page

```markdown
---
title: Page Title
category: entity
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: []
sources:
  - pages/sources/source-page.md
---

# Page Title

## Summary

Current synthesized understanding across sources.

## Notes

- Source-backed fact or interpretation with a link to the source page.

## Contradictions

- If applicable, describe conflicting claims and link both source pages.

## Related

- [Related Page](../concepts/related.md)
```

Use `category: concept` and `pages/concepts/` for concept pages.

## Synthesis Page

Use this under `pages/syntheses/` when a source materially changes an evolving thesis, state-of-the-field note, or durable cross-source conclusion.

```markdown
---
title: Synthesis Title
category: synthesis
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: []
sources:
  - pages/sources/source-page.md
---

# Synthesis Title

## Current Thesis

The best current synthesis across sources.

## Supporting Evidence

- [Source Page](../sources/source-page.md): relevant support.

## Tensions Or Contradictions

- Conflicting evidence, unresolved disagreements, or scope limits.

## What Changed

- How the latest source changed the prior synthesis.

## Related

- [Related Page](../concepts/related.md)
```

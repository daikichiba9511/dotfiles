# LLM Wiki Analysis Template

Use this when saving a query result under `pages/analyses/`. For durable cross-source conclusions or evolving theses, save the same structure under `pages/syntheses/` with `category: synthesis`.

```markdown
---
title: Analysis Title
category: analysis
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: []
sources:
  - pages/sources/source-page.md
query: Original user question
---

# Analysis Title

## Question

Original user question.

## Answer

Source-backed synthesis.

## Evidence

- [Page](../sources/source-page.md): relevant evidence.

## Uncertainty

- Missing source, weak evidence, or unresolved contradiction.

## Impact On Overview

- Whether this answer should update `overview.md` and why.

## Related

- [Related Page](../concepts/related.md)
```

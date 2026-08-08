# LLM Wiki Pattern

Source: Andrej Karpathy's "LLM Wiki" gist, https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f

## Core Model

- Raw sources are curated, immutable source material.
- The wiki is a persistent markdown layer maintained by the LLM.
- New sources are compiled into existing knowledge: source summaries, entity pages, concept pages, contradictions, and cross-links.
- `index.md` is the content catalog. `log.md` is the chronological activity record.

## Ingest Principle

The goal is not only to summarize the new source. The goal is to integrate it into the existing wiki so future queries read accumulated synthesis instead of re-deriving it from raw sources.

## Source Admission Principle

The user owns source curation. Before ingesting noisy, duplicate, low-quality, or off-topic sources, either confirm fit with the user or record why the source belongs in this wiki.

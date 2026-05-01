---
name: wiki-guide
description: "Explain the LLM Wiki pattern — architecture, concepts, and how to use wiki-init/ingest/query/lint skills. Use when the user asks 'LLM Wikiって何？', 'wikiの使い方を教えて', 'wiki skillの概要', 'how does the wiki work', or wants an overview before starting."
allowed-tools: Read, Glob
---

You are a guide. Explain the LLM Wiki pattern and the available skills clearly and concisely. Adapt the depth of explanation based on user context: if they seem new, cover the full concept; if they already have a wiki, focus on operations.

## Input

`/wiki-guide [topic]`

| Topic | What to explain |
|-------|----------------|
| (empty) | Full overview: pattern → architecture → skills → getting started |
| `concept` | The core idea and why it works |
| `architecture` | 3-layer structure and file layout |
| `skills` | Available skills and when to use each |
| `workflow` | Typical session flow with examples |

Parse `$ARGUMENTS` to determine topic. Default: full overview.

## Explanation Content

### Core Idea

The LLM Wiki is a pattern for building personal knowledge bases. Unlike RAG, where the LLM re-discovers knowledge from raw documents on every query, the wiki is a **persistent, compounding artifact**. The LLM reads sources, extracts knowledge, and integrates it into interlinked markdown pages. Cross-references are pre-built, contradictions are flagged, and synthesis reflects everything ingested so far.

Key insight: **you never write the wiki yourself**. The LLM writes and maintains all of it. You curate sources, ask questions, and direct the analysis. The LLM does the summarizing, cross-referencing, and bookkeeping.

Based on the LLM Wiki pattern by Andrej Karpathy.

### Architecture (3 Layers)

```
wiki/
  ├── _schema.md         # Conventions and workflows (user + LLM co-evolve)
  ├── index.md           # Page catalog — the LLM reads this first to find relevant pages
  ├── log.md             # Chronological operation log (grep-friendly)
  ├── raw/               # Immutable source documents (user places files here)
  └── pages/             # LLM-generated and maintained pages
      ├── entities/      # People, organizations, products, tools
      ├── concepts/      # Ideas, methods, theories, patterns
      ├── sources/       # One summary page per ingested source
      └── analyses/      # Comparisons, syntheses, query answers
```

| Layer | Owner | Rule |
|-------|-------|------|
| `raw/` | User | Immutable. LLM reads only. |
| `pages/` | LLM | LLM creates, updates, cross-references. User reads. |
| `_schema.md` | Both | Co-evolved. Defines page formats, link conventions, workflows. |

**Navigation**: The LLM reads `index.md` to discover pages, then reads only the ones it needs (JIT loading). No embedding DB or RAG infrastructure required.

**Links**: Standard markdown `[Title](./path.md)` — works with Neovim `gf`, GitHub rendering, and any markdown tool.

### Available Skills

| Skill | Command | When to use |
|-------|---------|-------------|
| `/wiki-init` | `/wiki-init [base_dir]` | Start a new wiki. Creates the full directory structure and templates. |
| `/wiki-ingest` | `/wiki-ingest <source>` | Add a source (file or URL). Creates summary page, updates entity/concept pages, maintains index/log. |
| `/wiki-query` | `/wiki-query <question>` | Ask questions. Searches index, reads relevant pages, synthesizes an answer with citations. `save:` prefix to keep the answer as a page. |
| `/wiki-lint` | `/wiki-lint [--fix]` | Health check. Detects broken links, orphan pages, contradictions, gaps. `--fix` repairs structural issues. |

### Typical Workflow

```
1. /wiki-init                              # Scaffold the wiki
2. (place articles/papers in raw/)         # Curate sources
3. /wiki-ingest raw/article.md             # LLM processes and integrates
4. /wiki-ingest raw/paper.md               # Each ingest compounds knowledge
5. /wiki-query What are the trade-offs?    # Ask questions against accumulated knowledge
6. /wiki-query save: Comparison of X vs Y  # Save valuable answers as pages
7. /wiki-lint                              # Periodic health check
8. (repeat 2-7)                            # Knowledge compounds over time
```

### When NOT to use this

- For ML experiment documentation → use `/ml-docs` instead (shares the same page-split architecture but adds experiment-specific workflows like bias-resistant strategy formation)
- For atomic concept memos → use `/zettel-create` instead (1 concept = 1 memo, different organizational model)

## Procedure

1. Detect if a wiki already exists in the project (Glob for `**/_schema.md`)
2. Adapt the explanation:
   - IF wiki exists → focus on operations (ingest/query/lint) and show the current wiki stats (page count, last ingest from log.md)
   - IF no wiki → cover the full concept and suggest `/wiki-init` to get started
3. Present the explanation matching the requested topic
4. End with a concrete next action the user can take

## Constraints

- MUST NOT create or modify any files. This skill is read-only and explanatory.
- MUST adapt depth to user context (new user vs. experienced user with existing wiki)

$ARGUMENTS

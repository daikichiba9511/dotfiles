---
name: wiki-init
description: "Initialize LLM Wiki directory structure for building a persistent, compounding knowledge base. Use when the user wants to start a new wiki, set up a knowledge base, begin research accumulation, or says things like 'wikiを始めたい', 'ナレッジベースを作りたい', 'LLM Wikiを初期化して'. Based on the LLM Wiki pattern by Karpathy."
allowed-tools: Read, Write, Bash(ls:*), Bash(mkdir:*), Glob
---

You are a wiki architect. Your job is to scaffold a 3-layer LLM Wiki directory structure that the user and LLM will co-maintain over time.

## Input

`/wiki-init [base_dir]`

Parse `$ARGUMENTS` to determine the base directory. Default: `wiki/`.

Examples:
- `/wiki-init` → base_dir = `wiki/`
- `/wiki-init research/kb` → base_dir = `research/kb/`

## 3-Layer Architecture

| Layer | Purpose | Owner |
|-------|---------|-------|
| `raw/` | Immutable source documents (articles, papers, data). LLM reads only. | User |
| `pages/` | LLM-generated and LLM-maintained markdown pages | LLM |
| `_schema.md` | Conventions, page formats, workflow definitions | User + LLM |

## Procedure

Execute these steps in order. Stop and ask the user if a decision point is reached.

### Step 1: Validate target directory

- IF base_dir already exists AND contains files → warn the user and ask for confirmation before proceeding
- IF base_dir already contains `_schema.md` → abort with message: "Wiki already initialized at {base_dir}"

### Step 2: Create directory structure

Create exactly this tree:

```
{base_dir}/
  ├── _schema.md
  ├── index.md
  ├── log.md
  ├── raw/
  └── pages/
      ├── entities/
      ├── concepts/
      ├── sources/
      └── analyses/
```

### Step 3: Write management files

Create `_schema.md`, `index.md`, and `log.md` using the templates below. Replace `{today}` with the current date in YYYY-MM-DD format.

### Step 4: Report

Print the created directory tree using `ls -R` and confirm completion.

## Templates

### _schema.md

```markdown
# Wiki Schema

## Overview

A persistent knowledge base following the LLM Wiki pattern.
The LLM reads sources, extracts knowledge, and integrates it into interlinked pages.

## Directory Structure

- `raw/` — Immutable source documents. LLM reads only, never modifies.
- `pages/entities/` — Entity pages (people, organizations, products, tools)
- `pages/concepts/` — Concept pages (ideas, methods, theories, patterns)
- `pages/sources/` — Source summary pages (one per ingested source)
- `pages/analyses/` — Analysis pages (comparisons, syntheses, query answers)
- `index.md` — Page catalog organized by category
- `log.md` — Chronological operation log

## Page Format

Every page MUST have this frontmatter:

---
title: Page Title
category: entity | concept | source | analysis
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [tag1, tag2]
sources: [paths to referenced source files in raw/]
---

## Link Conventions

- MUST use standard markdown links: [Title](./relative/path.md)
- Relative paths are resolved from the page's own directory
- MUST link to other pages when mentioning them by name
- MUST NOT use wiki-style [[links]]

## Workflows

### Ingest
1. User places source in raw/
2. `/wiki-ingest` processes it
3. Creates source summary → updates entity/concept pages → updates index and log

### Query
1. `/wiki-query` to ask questions
2. Finds relevant pages via index.md → reads them → synthesizes answer
3. Valuable answers can be saved as analysis pages

### Lint
1. `/wiki-lint` for periodic health checks
2. Detects contradictions, orphan pages, stale info, gaps → reports or fixes

## Customization

This file evolves over time. Add domain-specific conventions, new page categories, or output format preferences here.
```

### index.md

```markdown
---
title: Wiki Index
created: {today}
updated: {today}
---

# Wiki Index

## Entities

| Page | Summary | Updated |
|------|---------|---------|

## Concepts

| Page | Summary | Updated |
|------|---------|---------|

## Sources

| Page | Raw Source | Ingested |
|------|-----------|----------|

## Analyses

| Page | Summary | Created |
|------|---------|---------|
```

### log.md

```markdown
---
title: Wiki Log
created: {today}
---

# Wiki Log

<!-- Entry format: ## [YYYY-MM-DD] type | Title -->
<!-- Types: init, ingest, query, lint, update -->
<!-- Quick view: grep "^## \[" log.md | tail -5 -->

## [{today}] init | Wiki initialized

- base_dir: {base_dir}
- structure: raw/, pages/(entities, concepts, sources, analyses)
```

## Constraints

- MUST NOT overwrite existing files without user confirmation
- MUST use the current date for all date fields
- MUST print the final directory tree so the user can verify
- MAY adjust `_schema.md` content to fit the user's domain if context is available from the conversation

$ARGUMENTS

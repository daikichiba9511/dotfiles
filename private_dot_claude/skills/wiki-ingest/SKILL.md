---
name: wiki-ingest
description: "Ingest a source into the LLM Wiki — read it, create a summary page, update entity/concept pages, and maintain index and log. Use when the user adds a new source to the wiki, wants to process an article/paper/document, or says things like 'この記事を取り込んで', 'ソースを追加して', 'これをwikiに入れて', 'ingestして'. Trigger when files are added to raw/ and need processing."
allowed-tools: Read, Write, Edit, Glob, Grep, WebFetch, Agent
---

You are a wiki maintainer. Your job is to read a source document, extract its knowledge, and integrate it into the existing wiki — creating new pages, updating existing ones, and keeping the index and log current. A single source may touch 10-15 wiki pages.

## Input

`/wiki-ingest [source_path_or_url]`

Parse `$ARGUMENTS` to determine the source. Three input modes:

| Input | Action |
|-------|--------|
| File path (e.g. `raw/article.md`) | Read that file directly |
| URL (starts with `http`) | Fetch via WebFetch, save to `raw/` as markdown, then process |
| Empty | Scan `raw/` for unprocessed sources (cross-reference with `log.md` ingest entries) and present candidates to user |

## Wiki Detection

1. Glob for `**/_schema.md`
2. Exactly 1 match → use its parent as wiki root
3. Multiple matches → ask user to choose
4. No match → suggest running `/wiki-init`

## Procedure

Execute steps in order. Each step has a defined output that feeds the next.

### Step 1: Acquire source

- **File path**: Read the file. If it does not exist, abort with error.
- **URL**: Fetch with WebFetch. Save the markdown content to `raw/{YYYYMMDD}_{slug}.md`. Then read the saved file.
- **Empty**: List files in `raw/`. Parse `log.md` for lines matching `^## \[.*\] ingest` to find already-ingested sources. Present unprocessed files to user. Wait for selection.

Output: The full text of one source document, plus its file path in `raw/`.

### Step 2: Analyze source

Read the source and extract:

1. **Key claims** — the main arguments, findings, or conclusions
2. **Entities** — people, organizations, products, tools mentioned
3. **Concepts** — ideas, methods, theories, patterns discussed
4. **Data points** — numbers, benchmarks, quotes, concrete examples

Present the extraction to the user as a structured summary. Ask:
- "Are there specific aspects you want me to emphasize?"
- "Anything to skip or de-prioritize?"

Wait for user input before proceeding. If the user says nothing specific, proceed with defaults.

Output: A validated extraction list that guides page creation.

### Step 3: Create source summary page

Write to `pages/sources/{YYYYMMDD}_{slug}.md`:

```markdown
---
title: {Source Title}
category: source
created: {today}
updated: {today}
tags: [{extracted tags}]
sources: [{raw/file_path}]
original_url: {URL if applicable, omit field if none}
---

## Summary

{3-5 sentence overview of the entire source}

## Key Findings

- {Bulleted list of main claims/findings}

## Details

{Section-by-section summary, using ### subheadings matching the source structure}

## Related Pages

- [Page Name](../entities/page.md) — {one-line relationship note}
```

Output: Path to the created source page.

### Step 4: Update existing pages

1. Read `index.md` to get the current page catalog
2. For each entity and concept extracted in Step 2, determine:

| Condition | Action |
|-----------|--------|
| Page exists in `pages/entities/` or `pages/concepts/` | Read page → append new information under existing sections → update `updated` date and `sources` list |
| Page does not exist | Add to "new page candidates" list |

3. When updating an existing page and the new source **contradicts** existing content:
   - MUST NOT delete the existing claim
   - MUST add the new claim with its source citation
   - MUST flag the contradiction explicitly: `> **Note:** {source A} states X, while {source B} states Y.`

4. Present the new page candidates list to the user. Wait for approval before creating.

Output: List of updated pages and approved new pages to create.

### Step 5: Create new entity/concept pages

For each approved candidate, write to the appropriate directory:

```markdown
---
title: {Name}
category: {entity | concept}
created: {today}
updated: {today}
tags: [{tags}]
sources: [{paths to sources mentioning this entity/concept}]
---

## Overview

{2-3 sentence description}

## Details

{Information gathered from sources}

## Related Pages

- [Page Name](./relative/path.md) — {relationship}
```

### Step 6: Update index.md

For each page created or updated:
1. Add new pages to the appropriate category table in `index.md`
2. Update the `Updated` column for modified pages
3. Update the `updated` field in `index.md` frontmatter

Table row format:
```
| [{title}](./pages/{category}/{filename}) | {one-line summary} | {date} |
```

### Step 7: Append to log.md

```markdown
## [{today}] ingest | {Source Title}

- source: {raw/file_path}
- pages created: {comma-separated list of new page paths}
- pages updated: {comma-separated list of updated page paths}
- summary: {one-line description of what was ingested}
```

### Step 8: Report to user

Present a structured summary:

1. **Source**: title and path
2. **Pages created**: list with paths
3. **Pages updated**: list with what was added to each
4. **Contradictions found**: if any, with page links and details
5. **Suggested follow-ups**: related topics worth ingesting next (if obvious)

## Constraints

- MUST NOT modify any file in `raw/` (read-only)
- MUST NOT delete existing content from wiki pages. Only append.
- MUST flag contradictions rather than silently overwriting
- MUST reuse existing tags from other pages to prevent tag fragmentation (read a few existing pages to check current tag vocabulary)
- MUST follow link conventions in `_schema.md` (standard markdown links, relative paths)
- MUST ask user before creating more than 5 new pages in a single ingest

$ARGUMENTS

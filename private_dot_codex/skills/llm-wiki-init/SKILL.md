---
name: llm-wiki-init
description: "Initialize a persistent markdown LLM Wiki based on Karpathy's LLM Wiki pattern. Use when the user wants to start a new wiki, knowledge base, research notebook, or source-backed project memory; set up raw sources, generated pages, AGENTS.md schema, overview.md, index.md, and log.md; or says 'LLM Wikiを初期化して', 'wikiを始めたい', 'ナレッジベースを作りたい', 'research wikiを作って'."
---

# LLM Wiki Init

Create a persistent markdown wiki where raw sources stay immutable and Codex maintains synthesized pages over time.
Read `references/pattern.md` when the user asks about the design rationale. Read `references/schema-template.md` before writing the initial `AGENTS.md`, `overview.md`, `index.md`, and `log.md`.

## Usage

`$llm-wiki-init [base_dir] [theme_or_domain]`

- Default `base_dir`: `wiki/`
- Default schema file: `AGENTS.md` at the wiki root
- Default page root: `pages/`

## Workflow

1. Resolve the target base directory from the user's request, defaulting to `wiki/`.
2. If the target already contains files, do not overwrite existing files. Ask before adding missing wiki files into a non-empty directory.
3. Create this structure:

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

4. Write `AGENTS.md` from `references/schema-template.md`, adapting the domain, page categories, tags, and review style to the user's stated goal.
5. Write `overview.md` as the living top-level synthesis of the wiki's current state, open questions, and strongest themes.
6. Write `index.md` with empty category tables for entities, concepts, sources, analyses, and syntheses.
7. Write `log.md` as an append-only chronological log with an initial `init` entry and headings formatted as `## [YYYY-MM-DD] type | Title`.
8. Report the created files and the next likely command, usually `$llm-wiki-ingest <source>`.

## Rules

- Do not modify files in `raw/` after creation except to add new source files or assets at the user's request.
- Prefer standard markdown links with relative paths. Avoid Obsidian-only wikilinks unless the user explicitly wants them.
- Keep `AGENTS.md` short enough to act as operational instructions, not a full knowledge dump.
- Include a schema evolution section in `AGENTS.md`; later operations should propose updates when repeated patterns, domain conventions, or workflow preferences emerge.
- Use the current local date for generated metadata.
- If the user asks for a different layout, accept it and record the convention in `AGENTS.md`.

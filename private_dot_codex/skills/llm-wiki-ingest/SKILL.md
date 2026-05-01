---
name: llm-wiki-ingest
description: "Ingest sources into a persistent markdown LLM Wiki based on Karpathy's LLM Wiki pattern. Use when the user adds an article, paper, note, transcript, URL, image-backed markdown file, or raw source to a wiki; wants Codex to process files under raw/; or says 'この記事を取り込んで', 'ソースを追加して', 'wikiに入れて', 'ingestして'."
---

# LLM Wiki Ingest

Integrate a source into an existing LLM Wiki: create a source summary, update related pages, maintain cross-links, update `index.md`, and append `log.md`.
Read `references/pattern.md` for the underlying model. Read `references/integration-brief.md` before presenting an ingest plan. Read `references/page-templates.md` before creating pages.

## Usage

`$llm-wiki-ingest [source_path_or_url] [wiki_dir]`

- With a local path: read the file and ingest it.
- With a URL: fetch the content, save a raw copy under `raw/`, then ingest it.
- With no source: detect unprocessed files in `raw/` by comparing `raw/` with `log.md`.

## Wiki Detection

1. Prefer an explicit `wiki_dir` from the user's request.
2. Otherwise search for `AGENTS.md` files that mention `LLM Wiki`.
3. Fallback: search for legacy `_schema.md` files that mention `LLM Wiki`.
4. If multiple candidates exist, ask which wiki to use.
5. If none exists, suggest `$llm-wiki-init`.

## Workflow

1. Read the wiki `AGENTS.md`, `index.md`, and recent `log.md` entries.
2. Load the source. For markdown with local images, read the text first and inspect only images that matter to the source's claims.
3. Check source fit against the wiki's `Source Admission Policy` in `AGENTS.md`. If the source is noisy, duplicate, low-quality, off-topic, or outside an unclear scope, ask before ingesting unless the user explicitly requested it.
4. Extract the source title, date, author or publisher when available, main claims, entities, concepts, concrete examples, numbers, and possible contradictions.
5. Present a short integration brief before editing when the source is large, ambiguous, high-impact, uncertain-fit, or likely to update more than five pages. Use `references/integration-brief.md` for the format. If the user requested unattended ingestion, proceed with stated assumptions instead of stopping.
6. Create one page in `pages/sources/` using `references/page-templates.md`.
7. For each important entity or concept, update an existing page or create a focused new page. Ask before creating many pages at once.
8. Update `overview.md` or `pages/syntheses/` when the source materially changes the wiki's top-level understanding or an evolving thesis.
9. Add cross-links between the source page and every materially related entity, concept, analysis, or synthesis page.
10. If the ingest reveals a repeated workflow preference, naming convention, page category, tag convention, or source admission rule, propose an `AGENTS.md` schema update.
11. Update `index.md` rows for created or materially updated pages.
12. Append one `ingest` entry to `log.md`.
13. Report pages created, pages updated, contradictions found, schema updates proposed, and follow-up sources or questions.

## Rules

- Treat `raw/` as immutable after a source is stored there.
- Treat `raw/` as curated, not a dumping ground. Do not ingest uncertain-fit sources without user confirmation or an explicit assumption.
- Preserve existing sourced claims. If new evidence conflicts, add a contradiction note with both sources.
- Do not fabricate citation details. Mark missing title, date, or author as unknown.
- Prefer small focused pages over large omnibus pages.
- Reuse existing tags from nearby pages before inventing new tags.
- Do not save copyrighted source text beyond a reasonable raw copy requested by the user; generated wiki pages should summarize and cite.
- Keep the user in the loop on emphasis and scope for sources where multiple valid interpretations would lead to different wiki updates.

---
name: llm-wiki-query
description: "Answer questions from an existing persistent markdown LLM Wiki. Use when the user wants to query or search the wiki, synthesize what is known, compare entities or concepts, generate a source-backed answer, save a useful answer back into pages/analyses or pages/syntheses, or update overview.md; trigger on phrases like 'wikiで調べて', 'ナレッジベースに聞きたい', 'wikiから答えて', '何がわかっている？'."
allowed-tools: Read, Write, Edit, Glob, Grep, WebFetch, WebSearch
---

# LLM Wiki Query

Answer from the accumulated wiki first, cite wiki pages, and optionally save valuable answers as analysis or synthesis pages.
Read `references/pattern.md` for the model. Read `references/query-decision-tables.md` when search scope or answer format is ambiguous. Read `references/analysis-template.md` before saving an answer.

## Usage

`$llm-wiki-query <question> [wiki_dir] [save: optional_title]`

## Wiki Detection

1. Prefer an explicit `wiki_dir`.
2. Otherwise search for `AGENTS.md` files that mention `LLM Wiki`.
3. Fallback to legacy `_schema.md` files that mention `LLM Wiki`.
4. Ask if multiple wiki directories match.
5. If none exists, suggest `$llm-wiki-init`.

## Workflow

1. Read the wiki `AGENTS.md` and `index.md`.
2. Use `index.md` to identify likely relevant pages.
3. Use `references/query-decision-tables.md` to choose search depth and answer format when the route is not obvious.
4. Use `Grep` over the wiki when the index is insufficient.
5. Read the smallest set of pages needed to answer, including source pages behind important claims.
6. Synthesize an answer with links to the supporting wiki pages.
7. Clearly mark information gaps, uncertainty, and contradictions.
8. If the answer changes the wiki's top-level understanding, update or propose an update to `overview.md` or a page under `pages/syntheses/`.
9. If the query reveals a repeated workflow preference, output format preference, or schema gap, propose an `AGENTS.md` update.
10. If the user asked to save the answer, create an analysis or synthesis page and update `index.md`.
11. Append one `query` or `update` entry to `log.md` whenever query-driven edits are made, including overview-only, synthesis, analysis, or schema updates.
12. If saving would be useful but was not requested, propose it instead of silently writing.

## Answer Rules

- Ground the answer in wiki pages. Do not pretend the wiki contains facts it does not contain.
- Use outside web search only when the user asks for fresh information or explicitly wants a gap filled. Clearly label outside information as not yet part of the wiki, and offer to ingest the source before treating it as wiki knowledge.
- Distinguish sourced wiki facts from your inference.
- Prefer concise answers unless the user asks for a full memo.
- When pages conflict, present both claims with links and note what evidence would resolve the conflict.

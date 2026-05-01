---
name: llm-wiki-lint
description: "Audit and maintain a persistent markdown LLM Wiki. Use when the user wants a wiki health check, consistency pass, link audit, stale-claim review, contradiction scan, orphan-page detection, missing concept/entity suggestions, or says 'wikiをlintして', 'ヘルスチェックして', '矛盾を探して', 'リンクを整理して'."
---

# LLM Wiki Lint

Health-check an LLM Wiki and either report findings or apply safe maintenance edits when requested.
Read `references/pattern.md` for the design model and `references/lint-checklist.md` for the audit surface.

## Usage

`$llm-wiki-lint [wiki_dir] [scope] [--fix]`

- `scope`: optional subdirectory or page glob such as `pages/concepts/`; default is the whole wiki.
- `--fix`: apply safe structural fixes only after showing the intended change.

## Wiki Detection

1. Prefer an explicit `wiki_dir`.
2. Otherwise search for `AGENTS.md` files that mention `LLM Wiki`.
3. Fallback to legacy `_schema.md` files that mention `LLM Wiki`.
4. Ask if multiple wiki directories match.
5. If none exists, suggest `$llm-wiki-init`.

## Workflow

1. Resolve the lint scope, defaulting to the whole wiki.
2. Read `AGENTS.md`, `index.md`, and recent `log.md` entries.
3. Run the audit in `references/lint-checklist.md`.
4. Classify findings as `error`, `warning`, or `info`.
5. Check whether `overview.md` and `pages/syntheses/` reflect the current state of the wiki, especially after recent ingests or saved queries.
6. Check whether repeated workflow patterns imply an `AGENTS.md` schema update.
7. If the user requested fixes, apply only the safe fixes listed in `references/lint-checklist.md`, and show each intended change before editing.
8. Do not rewrite substantive claims without user approval.
9. Append a `lint` entry to `log.md` if files were changed or the user wants an audit record.
10. Report findings first, stats, changes made, schema or overview updates proposed, then recommended follow-up ingests or queries.

## Rules

- Preserve raw sources.
- Treat contradiction resolution as an editorial decision unless one source clearly supersedes another.
- Prefer adding explicit uncertainty over deleting older claims.
- Keep the report concise. Include file paths and exact pages for actionable findings.

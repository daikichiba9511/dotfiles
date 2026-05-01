# LLM Wiki Lint Checklist

## Structural Checks

- `AGENTS.md`, `overview.md`, `index.md`, `log.md`, `raw/`, and `pages/` exist.
- Expected page categories exist or the schema explains alternatives.
- Every generated page has frontmatter with `title`, `category`, `created`, `updated`, `tags`, and `sources`.
- `index.md` contains every generated page exactly once.
- `log.md` has parseable headings: `## [YYYY-MM-DD] type | Title`.
- `AGENTS.md` records current workflow conventions and domain-specific preferences.

## Link Checks

- Markdown links point to existing files.
- Important entity, concept, source, and analysis mentions link to pages when pages exist.
- Orphan pages are intentional or get new incoming links.
- Source pages link to related entity/concept pages and those pages link back when useful.

## Knowledge Checks

- Newer sources that supersede older claims are reflected in entity and concept pages.
- Contradictions are called out with links to both claims.
- Frequently mentioned entities or concepts have candidate pages.
- Analysis pages cite the pages they synthesize.
- `overview.md` reflects major changes from recent ingests, queries, and syntheses.
- Durable cross-source conclusions have pages under `pages/syntheses/` or are intentionally represented elsewhere.
- Tags are reused consistently.

## Source Coverage Checks

- Files in `raw/` are either logged as ingested or listed as pending.
- Pages do not cite missing raw files or missing source summary pages.
- Important claims are not left without a source link.

## Schema Evolution Checks

- Repeated user preferences are reflected in `AGENTS.md`.
- Repeated page types have either a documented category or a documented reason to stay under an existing category.
- Query output formats that recur, such as tables, slides, charts, or decision notes, are documented in `AGENTS.md`.

## Report Format

```markdown
## Lint Report - YYYY-MM-DD

### Errors (N)

- error: actionable structural break with file path.

### Warnings (N)

- warning: consistency or coverage problem that may affect answers.

### Info (N)

- info: improvement opportunity.

### Stats

- scope:
- total pages:
- sources ingested:
- last ingest:
- orphan pages:
- broken links:
- index gaps:
- ghost index entries:

### Safe Fixes Applied

- File changed and reason.

### Follow-Up

- Suggested ingest, query, or manual review.
- Suggested `AGENTS.md`, `overview.md`, or synthesis updates.
```

## Safe Fix Table

| Finding | Safe fix |
| --- | --- |
| Index gap | Add the missing page to the correct `index.md` category table. |
| Ghost index entry | Remove the dead `index.md` row. |
| Broken link where the file was moved | Update the link path. |
| Broken link where the target is unknown | Leave the claim intact and add a clear broken-link note for user review. |
| Missing backlink | Add a related-page link when both pages already exist and the relationship is explicit. |
| Missing log entry for current lint run | Append a `lint` entry to `log.md`. |

Do not auto-fix contradictions, stale substantive claims, duplicate content, missing concept/entity pages, or thin coverage. Report them for human judgment.

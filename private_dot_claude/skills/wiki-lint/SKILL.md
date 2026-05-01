---
name: wiki-lint
description: "Health-check the LLM Wiki — detect contradictions, stale claims, orphan pages, missing cross-references, and knowledge gaps. Use when the user wants to maintain wiki quality, run a periodic check, or says things like 'wikiをチェックして', 'ヘルスチェック', '整合性を確認して', 'lintして', 'wikiの状態は？'. Run periodically as the wiki grows."
allowed-tools: Read, Write, Edit, Glob, Grep
---

You are a wiki quality auditor. Your job is to systematically inspect the wiki for structural issues, broken links, contradictions, and knowledge gaps, then produce a clear severity-ranked report. You fix structural problems on request but never silently alter page content.

## Input

`/wiki-lint [scope] [--fix]`

Parse `$ARGUMENTS`:

| Argument | Meaning | Default |
|----------|---------|---------|
| scope | Directory to check (e.g. `pages/concepts/`) | Entire wiki |
| `--fix` | Auto-fix structural issues (with user confirmation per fix) | Report only |

## Wiki Detection

1. Glob for `**/_schema.md`
2. Exactly 1 match → use its parent as wiki root
3. Multiple matches → ask user to choose
4. No match → suggest running `/wiki-init`

## Procedure

### Step 1: Collect all pages

1. Glob `pages/**/*.md` to get every wiki page
2. For each page, extract:
   - Frontmatter fields (title, category, created, updated, tags, sources)
   - All markdown links (regex: `\[([^\]]+)\]\(([^)]+)\)`)
   - All entity/concept names mentioned in prose
3. Read `index.md` to get the registered page catalog

Output: A structured inventory of pages, their metadata, links, and mentions.

### Step 2: Run checks

Execute each check category. Collect findings into a list with severity levels.

#### 2a. Structure checks

| Check | Severity | Condition |
|-------|----------|-----------|
| Missing required files | critical | `_schema.md`, `index.md`, or `log.md` absent |
| Missing required dirs | critical | `raw/` or `pages/` absent |
| Missing frontmatter | warning | Page lacks any of: title, category, created, updated |
| Invalid category | warning | Category not in {entity, concept, source, analysis} |

#### 2b. Link checks

| Check | Severity | Condition |
|-------|----------|-----------|
| Broken link | critical | Link target file does not exist on disk |
| Orphan page | warning | Page has zero inbound links from other pages |
| Index gap | critical | Page exists on disk but has no row in `index.md` |
| Ghost index entry | critical | Row in `index.md` points to a file that does not exist |

#### 2c. Content checks

| Check | Severity | Condition |
|-------|----------|-----------|
| Contradiction | warning | Two pages make opposing claims about the same subject (detect by finding pages with overlapping tags/topics and comparing key statements) |
| Stale page | info | Page's `updated` date is older than a newer source that covers the same topic |
| Duplicate content | info | Two pages have >70% overlapping content (estimate by shared key phrases) |

#### 2d. Gap checks

| Check | Severity | Condition |
|-------|----------|-----------|
| Mentioned but no page | info | An entity/concept name appears in 2+ pages but has no dedicated page |
| Thin coverage | info | A topic has only 1 source backing it |
| Tag orphan | info | A tag is used by only 1 page (potential tag fragmentation) |

### Step 3: Generate report

Output findings in this exact format:

```
## Lint Report — {today}

### Critical ({count})
- {description}: [{page}]({path}) → {detail}

### Warning ({count})
- {description}: [{page}]({path}) — {detail}

### Info ({count})
- {description}: {detail}

### Stats
- Total pages: {N}
- Sources ingested: {N}
- Last ingest: {date from log.md}
- Orphan pages: {N}
- Broken links: {N}
```

If there are zero findings in a severity level, print `(none)` under that heading.

### Step 4: Apply fixes (only when `--fix` is present)

If `--fix` was specified, fix ONLY structural issues. For each fix, show the user what will change and wait for approval.

| Fixable | Action |
|---------|--------|
| Index gap | Add missing page to `index.md` in the correct category table |
| Ghost index entry | Remove the dead row from `index.md` |
| Broken link (file was moved) | Update the link path |
| Broken link (file deleted) | Remove the link and add a `<!-- broken link removed -->` comment |

**MUST NOT auto-fix:** contradictions, stale content, duplicate content, or gaps. These require human judgment — report only.

### Step 5: Log the lint run

Append to `log.md`:

```markdown
## [{today}] lint | Health Check

- scope: {checked scope or "full"}
- critical: {N}
- warning: {N}
- info: {N}
- fixed: {N} (only if --fix was used)
```

## Constraints

- MUST NOT delete or rewrite page content
- MUST NOT resolve contradictions (report both sides with citations)
- MUST NOT create new pages (only report gaps)
- MUST present the report in the structured format above — no free-form prose
- MUST confirm each fix individually when `--fix` is used
- MUST follow link conventions in `_schema.md`

$ARGUMENTS

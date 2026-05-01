---
name: wiki-query
description: "Query the LLM Wiki — search for relevant pages via index, synthesize an answer with citations, and optionally save the answer as a new wiki page. Use when the user asks questions against their wiki, wants to search the knowledge base, or says things like 'wikiで調べて', 'ナレッジベースに聞きたい', '何がわかっている？', 'wikiから答えて'. Trigger when the user asks a question in the context of an existing wiki."
allowed-tools: Read, Write, Edit, Glob, Grep
---

You are a wiki researcher. Your job is to answer the user's question using only the knowledge accumulated in the wiki. You search, read, synthesize, and cite. Valuable answers compound back into the wiki as new pages.

## Input

`/wiki-query <question>`

Parse `$ARGUMENTS` to get the question. Detect the `save:` prefix to determine save intent.

Examples:
- `/wiki-query What factors affect Transformer inference speed?`
- `/wiki-query Compare method A vs method B`
- `/wiki-query save: Summary of optimization techniques` → answer AND save as page

## Wiki Detection

1. Glob for `**/_schema.md`
2. Exactly 1 match → use its parent as wiki root
3. Multiple matches → ask user to choose
4. No match → suggest running `/wiki-init`

## Procedure

### Step 1: Find relevant pages

1. Read `index.md` to scan the full page catalog
2. Identify candidate pages by matching the question's keywords and intent against page titles and summaries in the index
3. If index alone is insufficient, use Grep to search page contents for key terms
4. Read the top candidate pages (aim for the minimal set that covers the question)

Decision tree for search depth:

| Situation | Action |
|-----------|--------|
| Index clearly points to 1-3 pages | Read those pages |
| Index is ambiguous | Grep for question keywords across `pages/` |
| Grep returns too many hits (>10) | Narrow with more specific terms or ask user to refine |
| No relevant pages found | Skip to "no information" response |

Output: A set of page contents relevant to the question.

### Step 2: Synthesize answer

Compose an answer following these rules:

1. **Ground every claim in a wiki page.** After each key statement, cite the source: `([Page Title](./relative/path.md))`
2. **Choose the format that best fits the question:**

| Question type | Preferred format |
|---------------|-----------------|
| "What is X?" / factual | Prose paragraphs with citations |
| "Compare X vs Y" | Comparison table |
| "List all..." | Bulleted list |
| "What happened when..." | Timeline |
| Open-ended / exploratory | Prose with a summary section |

3. **If the wiki lacks information**, state explicitly: "The wiki does not contain information about {X}." Then suggest one of:
   - A source to ingest (`/wiki-ingest`)
   - A web search to conduct
   - A related topic the wiki does cover

4. **If pages contradict each other**, present both positions with their source citations. Do not pick a winner unless one source is clearly more authoritative (e.g., a primary source vs. a blog post).

Output: The answer text with citations.

### Step 3: Save as analysis page (conditional)

Determine whether to save:

| Condition | Action |
|-----------|--------|
| `$ARGUMENTS` starts with `save:` | Save the answer as a page |
| User explicitly says "save" / "keep" / "page" | Save the answer as a page |
| Neither of the above | Do NOT save. Do NOT ask. Just answer. |

If saving, write to `pages/analyses/{YYYYMMDD}_{slug}.md`:

```markdown
---
title: {Answer Title}
category: analysis
created: {today}
updated: {today}
tags: [{tags}]
sources: [{paths to pages cited in the answer}]
query: "{original question}"
---

## Answer

{answer body with citations}

## Source Pages

- [Page Name](./relative/path.md) — {what was drawn from this page}
```

Then update `index.md` (add to Analyses table) and `log.md`:

```markdown
## [{today}] query | {short question summary}

- question: {full question}
- pages referenced: {list of cited pages}
- page created: {path to saved analysis, or "none"}
```

## Constraints

- MUST answer from wiki content only. MUST NOT inject external knowledge or hallucinate facts not in the pages.
- MUST cite sources for every substantive claim using markdown links
- MUST present both sides of contradictions with source attributions
- MUST NOT save answers unless explicitly requested (via `save:` prefix or user instruction)
- MUST follow link conventions in `_schema.md`

$ARGUMENTS

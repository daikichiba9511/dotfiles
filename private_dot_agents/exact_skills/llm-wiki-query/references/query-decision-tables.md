# LLM Wiki Query Decision Tables

## Search Depth

| Situation | Action |
| --- | --- |
| `index.md` clearly points to 1-3 pages | Read those pages and the source pages behind important claims. |
| `index.md` is ambiguous | Use `Grep` for question keywords across `pages/`. |
| `Grep` returns more than 10 plausible hits | Narrow with more specific terms or ask the user to refine the question. |
| No relevant wiki pages are found | Say the wiki does not contain the information, then suggest a source to ingest, a focused web search, or a related covered topic. |

## Answer Format

| Question type | Preferred format |
| --- | --- |
| "What is X?" or factual lookup | Short prose with citations. |
| "Compare X vs Y" | Comparison table plus concise synthesis. |
| "List all..." | Bulleted list grouped by concept or entity. |
| "What happened when..." | Timeline. |
| Open-ended or exploratory | Summary first, then evidence and uncertainty. |
| Decision or recommendation | Recommendation, why alternatives lose, and what would change the answer. |

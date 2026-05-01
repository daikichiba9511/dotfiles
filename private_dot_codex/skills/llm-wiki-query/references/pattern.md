# LLM Wiki Pattern

Source: Andrej Karpathy's "LLM Wiki" gist, https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f

## Query Principle

The wiki is a compiled knowledge layer between the user and raw sources. Query the compiled layer first, then drill into source summaries and raw sources only when needed.

## Compounding Rule

If a query produces a durable comparison, timeline, or decision note, ask whether to save it under `pages/analyses/`. If it produces an evolving thesis or durable cross-source conclusion, save or propose saving it under `pages/syntheses/`. If it changes the wiki's top-level understanding, update or propose updating `overview.md`.

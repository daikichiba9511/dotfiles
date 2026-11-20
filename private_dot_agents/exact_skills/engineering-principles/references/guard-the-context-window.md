# Guard the Context Window

**Apply when:** context is filling up: large outputs, long files, repeated reads, logs, or planning a fan-out.

**Why:** context overflow degrades reasoning, introduces compression artifacts, and stalls progress.

**Rule:** route bulk to subagents or tools; keep summaries and decisions in the main thread, not raw payloads.

- Size phases and cap scope: limit files per phase, and account for what each mechanism costs in context.
- Read only the part of a file you need; filter command output (grep, head, counts) before it lands in context.
- Ask subagents for structured facts (paths, line numbers, verdicts), not file dumps.
- Do not re-read what you already have.

**Defers to:** `rules/subagent-strategy.md` for model choice and query shape (inherit the session model; narrow parallel queries; Explore for pure retrieval).

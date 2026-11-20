# Foundational Thinking

**Apply when:** before writing logic: choosing core types and data structures, deciding what to build first, or letting several actors share state.

**Rule:** get the data shape right first, so the downstream code becomes obvious.

- Define core types early. Trace every access pattern and pick structures that fit the dominant paths.
- Deduplicate the structure (shared types, one schema), not every repeated line.
- Before sharing state between actors, ask what happens if another actor modifies it concurrently. If the answer is not "nothing", isolate it (see [separate-before-serializing-shared-state](separate-before-serializing-shared-state.md)).
- Scaffold first: remove dead code, then add what every later phase needs (shared types, checks, CI), then features.

**Test:** can you write down the core types and their access patterns before the first function body? If not, you are not ready to write logic.

**Defers to:** in active ML exploration, scaffolding means only what the experiment needs; `coding-rules` ML override forbids up-front schemas, shared modules, and tests for hypothetical reuse.

# Minimize Reader Load

**Apply when:** reviewing or shaping code that is hard to trace.

**Rule:** reader load has two axes, layers to trace between a question and its answer, and hidden or mutable state the reader must hold. Reduce both.

- Collapse layers that only forward: one-caller wrappers, adapters with no second implementation, pass-through methods.
- Shrink state scope: returns over mutation, locals over fields, fields over module state, module state over globals. Derive values instead of keeping copies in sync.
- Name an invariant once at the boundary, not in every consumer.

**Test:** can a new reader answer "where does X come from?" and "what can change X?" in under 30 seconds? If not, cut layers or cut state.

Consistent with `rules/coding-style.md` (immutability, generating new values over mutation).

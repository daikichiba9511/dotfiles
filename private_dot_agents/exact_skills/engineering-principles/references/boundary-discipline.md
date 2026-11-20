# Boundary Discipline

**Apply when:** wiring validation, error handling, or framework adapters.

**Rule:** validate, narrow types, and handle errors where data crosses a system boundary (CLI args, config files, env vars, network, external APIs). Inside, trust the types: no re-validation and no redundant `None` checks.

- Parse raw data into domain types at the boundary; keep transport and framework types out of the internal surface.
- Business logic lives in pure functions with no framework dependencies; the shell that calls them stays thin.

**Two tests:** is this data crossing a boundary right now? If not, the validation is redundant. Can this be a pure function the shell just calls? If yes, extract it.

**Defers to:** `rules/python.md` (pydantic `frozen=True` at the boundary, convert via `to_<domain_model>()`), and `no-fallbacks` (fail loudly; no default values for required data).

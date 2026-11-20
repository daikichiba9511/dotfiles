# Model the Domain

**Apply when:** writing stateful logic, or when code branches a lot or repeats a shape assumption across files.

**Rule:** encode the domain in a data structure instead of scattering it across conditionals. The right structure makes invalid states unrepresentable and deletes branches.

- State machine instead of scattered booleans or phase checks.
- Typed model instead of loose parameters or raw dicts.
- Map, registry, or tagged union instead of branching spread across files.
- Reducer instead of ad hoc mutations; index, queue, or normalized collection where the access pattern calls for it.

Do not force it. Keep boring code when the shape is clear, local, and unlikely to grow. Distrust an abstraction that adds indirection without removing branches or invalid states.

**Smell that you skipped this:** a feature that grows an if/else chain by one more branch, or a second boolean that must stay in sync with the first.

**Defers to:** Python model choices follow `rules/python.md` (frozen dataclasses for domain, frozen pydantic at boundaries). In exploratory ML code, no registries or schemas unless they remove demonstrated ambiguity (`coding-rules` ML override).

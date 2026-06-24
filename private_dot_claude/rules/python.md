---
paths:
  - "**/*.py"
---

# Python

## Type Hints
- Argument types: use minimal abstract types (`collections.abc.Sequence` > `list`, `collections.abc.Mapping` > `dict`)
- Return types: use concrete types (exception: constraining callers for loose coupling)

## Validation / Domain Models
- Boundary validation: pydantic with `frozen=True`
- Domain models: `dataclasses.dataclass(frozen=True)`
- Convert via `to_<domain_model>()` after validation
- Prefer dataclasses or pydantic models over raw `dict` for structured data.
- Use `Mapping` only for generic read-only inputs or external boundaries, then convert to typed models.
- Avoid fallback defaults for invalid or missing data; raise explicit errors instead.

## CLI (tyro)
- List args use space separation: `--items a b c`
- Use `tuple` for mutable default values

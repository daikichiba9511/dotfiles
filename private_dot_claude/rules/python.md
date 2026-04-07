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

## CLI (tyro)
- List args use space separation: `--items a b c`
- Use `tuple` for mutable default values

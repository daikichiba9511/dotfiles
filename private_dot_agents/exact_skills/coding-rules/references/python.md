# Python

## Baseline

- Target Python 3.12 or later as the minimum supported version.
- Use Python 3.12 syntax and standard-library features directly.
- Do not add compatibility constructs that Python 3.12 does not require.
- Do not use `from __future__ import annotations`.

## Type Hints

- Use minimal abstract argument types such as `collections.abc.Sequence` and `collections.abc.Mapping` when callers do not require a concrete container.
- Use concrete return types unless an abstraction intentionally constrains callers.
- Use PEP 585 built-in generics and union syntax, such as `list[str]`, `dict[str, int]`, and `T | None`.
- Do not use `typing.List`, `typing.Dict`, or `typing.Optional`.

## Validation and Domain Models

- Use Pydantic with `frozen=True` for boundary validation.
- Use `dataclasses.dataclass(frozen=True)` for domain models.
- Convert validated boundary models with a `to_<domain_model>()` method.
- Prefer dataclasses or Pydantic models over raw dictionaries for structured data.
- Use `Mapping` only for generic read-only inputs or external boundaries, then convert it to a typed model.
- Raise explicit errors for invalid or missing data instead of using fallback defaults.

## CLI

- With tyro, pass list arguments as space-separated values: `--items a b c`.
- Use tuples for defaults that must not be mutable.

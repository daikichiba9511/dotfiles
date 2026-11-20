# Type System Discipline

**Apply when:** designing types, reviewing a function signature, or writing code in a statically typed or type-hinted language.

**Rule:** make the type checker reject impossible states, mismatched primitives, and unhandled variants.

- Make illegal states unrepresentable: tagged unions or separate types instead of optional fields that must agree.
- Brand semantic primitives. If two arguments share a primitive type but mean different things (user ID vs order ID), give each its own type (e.g. `NewType`) and validate once at creation.
- External data is untyped until parsed. JSON, RPC payloads, CLI args, config, env vars, and DB rows go through one parse function at the boundary ([boundary-discipline](boundary-discipline.md)).
- Exhaust variants: match every case and let the checker flag a missing one (e.g. `assert_never`).
- Derive types from the authoritative schema instead of hand-writing a parallel one.

**Defers to:** `rules/python.md` for Python typing conventions (abstract argument types, concrete return types, PEP 585 generics). In exploratory ML code, add schemas only for real boundaries (`coding-rules` ML override).

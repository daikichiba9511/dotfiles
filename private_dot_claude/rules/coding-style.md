# Coding Style

## Comments
- Express "what" through code. Comments explain "why" only.
- If logic needs naming and explanation, extract into a function.

## Connascence
- Multiple return values: use structs (dataclass, etc.) instead of positional tuples.
- Multiple arguments: prefer named arguments over positional.

## Functional Style
- Prefer immutable. Minimize side effects.
- Prefer generating new values over mutating state.

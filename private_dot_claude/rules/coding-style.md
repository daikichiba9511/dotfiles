# Coding Style

## Comments
- Express "what" through code. Comments explain "why" only.
- If logic needs naming and explanation, extract into a function.
- Add comments for non-obvious invariants, experimental assumptions, leakage prevention, reproducibility constraints, and intentional deviations from the straightforward implementation.
- Do not add comments that merely restate the code, narrate each step, or become stale when names change.
- When changing code, update or remove nearby comments in the same edit.

## Connascence
- Multiple return values: use structs (dataclass, etc.) instead of positional tuples.
- Multiple arguments: prefer named arguments over positional.

## Functional Style
- Prefer immutable. Minimize side effects.
- Prefer generating new values over mutating state.

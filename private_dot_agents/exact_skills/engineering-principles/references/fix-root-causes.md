# Fix Root Causes

**Apply when:** debugging.

**Rule:** fix the fault, not the place where it surfaced. The root cause is the first place the system did something it should not do, or failed to handle a state it should handle.

- Reproduce first. Ask "why" until the answer is a wrong decision in the code. When stuck, instrument and read the actual state.
- Ask whether the triggering state is legitimate. If yes, handle it where the code broke. If it should never exist, a check there hides the bug; find what produced it.
- Guards, retries, swallowed errors, clamped values, and discarded state are the usual ways to hide a bug.
- Fix the pattern, not the instance: find every place with the same fault.
- If finding the deciding fact took a deep dig, propose the cheap always-on signal (log, assertion, metric) that would have shown it at first look.

See also: [attack-the-premise](attack-the-premise.md) when repeated fixes fail. Consistent with `no-fallbacks`.

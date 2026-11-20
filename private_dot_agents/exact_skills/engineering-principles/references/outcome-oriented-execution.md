# Outcome-Oriented Execution

**Apply when:** executing a planned rewrite or migration that has explicit phase boundaries.

**Rule:** optimize for the verifiable end state, not for keeping every intermediate step smooth. Temporary compatibility code tends to become permanent debt.

- Prioritize end-state integrity over transitional stability.
- Intermediate breakage is acceptable only when it is planned, scoped, and reversible. Declare up front where it is allowed.
- Keep high-signal checks running on the areas you are actively touching.
- Require full static and runtime verification at plan completion.

**Not for:** unplanned changes, or anything shipped to users mid-migration. Breakage on a shared or default branch needs the user's agreement.

See also: [migrate-callers-then-delete-legacy-apis](migrate-callers-then-delete-legacy-apis.md). `no-fallbacks` governs any compatibility shim.

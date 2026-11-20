# Migrate Callers Then Delete Legacy APIs

**Apply when:** introducing a new internal API while old callers still exist.

**Rule:** migrate every caller and delete the old API in the same wave. Do not keep a compatibility layer.

- Find all callers mechanically (search, type checker, or a codemod via [build-the-lever](build-the-lever.md)).
- Update tests to assert the new contract; delete tests that only protected pre-refactor implementation details.
- Remove the old entry point, its aliases, and its docs in the same change.

**Applies only when:** no external users depend on backward compatibility, and the project can absorb a coordinated breaking change. Published APIs need a deprecation plan agreed with the user.

**Defers to:** `no-fallbacks` is authoritative; if an alias is explicitly required, follow its rules for making it loud and removable.

# Laziness Protocol

**Apply when:** refactoring, judging diff size, or tempted to add an abstraction, layer, option, or parameter threaded through several calls.

**Rule:** bias toward deletion and the smallest change that solves the problem.

- Minimize the diff. Fewer lines beat "elegant" boilerplate.
- Consolidate decisions. Make each choice in one place (one source of truth) and pass the result down as a plain value, instead of re-deciding it in every consumer.
- Prefer removing a layer to adding one. A new abstraction must delete branches or duplication now, not later.

**Test:** could the same outcome be reached with fewer files touched, fewer new names, or fewer lines? If yes, do that.

See also: [subtract-before-you-add](subtract-before-you-add.md), [minimize-reader-load](minimize-reader-load.md). Consistent with `refactor-clean`'s Rule of Three and YAGNI.

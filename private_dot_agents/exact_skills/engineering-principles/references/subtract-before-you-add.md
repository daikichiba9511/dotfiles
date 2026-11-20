# Subtract Before You Add

**Apply when:** sequencing an addition, refactor, or rewrite.

**Rule:** remove complexity first, then build on the simpler base. Leave the design slightly simpler, behind the same or a smaller surface, than you found it.

- Remove dead code, redundant validators, stale branches, and stub references before constructing.
- Cut before you polish: reach the minimum before investing in quality.
- Design for observed usage, not speculative edge cases. No guards or parsers beyond what the spec demands.
- When a document, prompt, or reference has no novel content, delete it rather than leaving a stub.

**Test:** does the diff contain a removal step before the addition? If nothing could be removed, say so explicitly.

Consistent with `no-fallbacks` (delete the old path) and the ML rule "clean up stale branches and fallbacks before splitting files".

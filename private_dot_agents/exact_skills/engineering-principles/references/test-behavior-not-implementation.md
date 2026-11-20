# Test Behavior, Not Implementation

**Apply when:** writing, changing, or deciding whether to keep a test.

**Rule:** a test is a claim about what users of the code can observe through its interface: return values, errors, state they can read back, and effects on outside systems. Private helpers, internal call order, and intermediate data are implementation.

Judge each test against two imagined edits:

- **Break the behavior** (wrong value, skipped or doubled effect). If the test still passes, it proves nothing. Usual causes: loose assertions, an expected value computed by the code under test, asserting on data the test itself built.
- **Change the internals** while keeping every observable result. If the test fails, it is pinned to the implementation.

Keep tests that catch the first edit and survive the second; rewrite or delete the rest.

- Drive the code through its public interface with a concrete input; derive the expected value from the requirement.
- What an external service receives is behavior; a call to an internal helper is not.
- Pair "this never happens" with a case where it does happen.
- Assert the error type callers branch on, not the message.

**Defers to:** exploratory ML code defaults to no new tests, except the smallest test for a load-bearing pure function such as a metric or split rule (`coding-rules` ML override).

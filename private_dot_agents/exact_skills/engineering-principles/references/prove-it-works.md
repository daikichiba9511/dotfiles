# Prove It Works

**Apply when:** after completing a task, before declaring it done.

**Rule:** verify against the real artifact: run the feature, read the actual value, inspect the diff. Proxies (file mtimes, self-reports, cached output, "it compiles", a subagent saying "done") do not count.

- When a check fails, suspect the observation method before the system.
- Script the check when you can; a deterministic rerunnable comparison beats a one-time look. Show its output to the user.
- Diff against the main branch before marking work complete.

**Defers to:** in exploratory ML code, the real-artifact check is a cheap end-to-end debug run (small sample, one fold, one epoch) that produces the expected tracker record (`coding-rules` ML override).

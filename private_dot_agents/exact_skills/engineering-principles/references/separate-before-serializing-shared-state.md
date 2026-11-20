# Separate Before Serializing Shared State

**Apply when:** concurrent actors (processes, subagents, jobs, worktrees) might write the same file, branch, key, or state object.

**Rule:** first eliminate the sharing; serialize only when one shared write target is a real invariant.

- Ask whether actors need one shared object or are publishing independent facts. Default to giving each actor its own file, key, branch, or directory, and merge only where the state is read.
- Only when a single shared target is a true invariant, serialize structurally: a single writer, a lockfile, sequential phases, or compare-and-swap.
- Instructions ("don't touch X") are not concurrency control. "We need a lock" is a smell to check first.

**Example:** two workers each writing their own field into one `state.json` is still shared mutation. Give each worker `state/<worker>.json` and merge on read.

# Attack the Premise

**Apply when:** two or more fixes that share one premise have failed the same check (test, metric, reproduction).

**Rule:** suspect the premise, not the fixes. Do not start the next fix until the premise is written down and tested.

1. Write the premise as one sentence that every failed fix assumed.
2. Find an observation that would come out differently if the premise were false, and make it. Look at how the failures are distributed, not only how large they are.
3. If the evidence contradicts the premise, look for what the failures share that it did not predict. If one part always lands on the losing side, change what puts it there instead of adding a mechanism that cleans up after it.

**Example:** three cache-invalidation fixes all fail the same flaky test. Premise: "the stale read comes from the cache". Test it by disabling the cache; if the test still flakes, the premise is false and the next cache fix would also fail.

See also: [fix-root-causes](fix-root-causes.md).

# Explain the Number

**Apply when:** before measuring, and before trusting, reporting, or acting on a measured number: speedup, regression, throughput, latency, validation metric, or eval score.

**Rule:** find what limits the number, and rule out that it measured something other than the work you think.

- **Write the decision before you run.** Name the result that would change it and the noise floor. Stop when run-to-run spread is larger than the effect.
- **Ask "why not double?"** Name the resource or code path that bounds the result, from a profile or counters taken during a run. A guess from reading code is not a limiter.
- **List what else the number could be measuring:** errors, skipped or cached work, code that never ran, warmup, an untuned baseline, leakage, noise, a component too small to matter. Rule each out with evidence.
- **Keep the run count, the spread, and the limiter with the number** when you report it.

For model metrics: check that every run completed the task, that the gap holds across seeds or folds, and that the validation split matches what matters. Leakage and train/serve skew have dedicated skills (`ml-dataset-audit`, `ml-consistency`).

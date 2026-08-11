# ML Experiment Code

Use these rules only for exploratory ML or Kaggle experiment code. They override the general and Python coding rules when those rules would add production-oriented structure. Do not apply this exception to production ML systems or stabilized shared components.

The goal is learning: the result and its cause must remain easy to trace.

## Experiment Directory Isolation

- Treat every `src/exp/expXXX/` directory as a self-contained experiment snapshot.
- When starting a new experiment, create its directory by copying the closest prior experiment (for example, with `cp -r`) or by recreating only the needed files, then make the new changes inside that directory.
- Use earlier experiments as evidence, documentation, and copy sources only. Do not import functions, classes, configs, or other implementation from a sibling experiment directory at runtime.
- For example, `exp005` must not import implementation from `exp003` or `exp004`; copy or reimplement the needed code inside `exp005` instead. Intentional duplication is preferable to coupling experiments together.
- Do not modify an earlier experiment merely to support a newer one. Dependencies on stable shared modules outside the experiment directories remain allowed when those modules are already intended for cross-experiment reuse.

## Code Shape

- Prefer simple over easy, fewer moving parts over more, and the smallest code that tests the hypothesis.
- Keep orchestration linear and values explicit. Separate data selection, preprocessing, training, evaluation, and logging into visually clear stages.
- Give each block or function one experimental concept. Do not hide several concepts behind a generic pipeline or reusable abstraction.
- Do not add helpers, classes, config layers, factories, registries, wrappers, or shared modules for hypothetical reuse. Extract only a concept that is already stable and reused, or a non-trivial algorithm whose details would obscure the experiment.
- A few repeated obvious lines are preferable to a premature abstraction.
- Use direct local variables or a small literal config by default. Add dataclasses, Pydantic models, or other schemas only for an actual boundary where they remove demonstrated ambiguity.
- Comments explain the hypothesis, assumption, leakage constraint, reproducibility choice, or metric meaning; do not narrate mechanics.

## Failure Behavior

- Let unexpected exceptions stop the run. Do not add speculative error handling, retries, fallbacks, skipped steps, guessed defaults, or best-effort continuation.
- Do not catch an exception merely to keep the experiment running.
- Do not validate conditions that the runtime or library will already reject. Add an assertion only when a load-bearing experimental assumption could otherwise fail silently and invalidate the result.
- Keep required values required. Avoid optional access such as `dict.get()` when absence should crash.

## Tests and Execution Check

- Default to no new automated test.
- Add only the smallest test for a deterministic pure function whose silent mistake could invalidate the experiment, such as a custom metric, split rule, leakage-sensitive transform, or coordinate conversion.
- Do not test orchestration, training loops, third-party library behavior, speculative error cases, config wiring, trivial accessors, or every edge case.
- For the rest, run the real workflow in a cheap debug mode: a small sample, a few batches, one fold, or one epoch. Confirm that it completes end to end and produces the expected tracker record.

## Experiment Logging and Reproducibility

- Use the project's existing W&B, MLflow, or equivalent tracker directly; do not build a logging abstraction for one experiment.
- Record the parameters that affect the result, random seeds, data and split identity, model or checkpoint identity, primary and diagnostic metrics, run name or experiment ID, code version, and the execution command when available.
- Keep metric names and step semantics consistent with the baseline. Log intermediate values only when they help explain the outcome.
- Save only artifacts needed to reproduce or inspect the result, such as predictions, checkpoints, or resolved config.
- Do not silently continue without required tracking. A missing or broken required tracker setup should stop the run.

## Performance

- Start with the simplest implementation that makes iteration practical.
- Use straightforward vectorization or batching when it remains obvious. Add caching, precomputation, specialized data structures, or parallelism only when measured runtime or cost is blocking learning.

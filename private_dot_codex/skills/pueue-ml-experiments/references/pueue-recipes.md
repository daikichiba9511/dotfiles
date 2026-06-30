# Pueue Recipes for ML Experiments

Load this reference before setting up groups, enqueueing jobs, monitoring status, or composing post-run Codex analysis tasks.

## Validate the Local CLI

Run these first:

```bash
pueue --version
pueue status
pueue add --help
pueue group --help
pueue parallel --help
```

If pueue is installed but `status` cannot connect, the daemon is not running or the config/socket path differs from the shell environment.

## One-Time Group Setup

Common current syntax:

```bash
pueue group add gpu --parallel 1
pueue group add analysis --parallel 1
pueue group
```

If a group already exists, update its concurrency:

```bash
pueue parallel 1 --group gpu
pueue parallel 1 --group analysis
```

Use `gpu` only for work that consumes the GPU. Use `analysis` for Codex and note-writing jobs.

## Enqueue One Experiment

Use an explicit working directory and capture the train task id:

```bash
repo="/path/to/repo"
exp="exp042"
train_cmd="uv run python src/exp/${exp}/train.py --config src/exp/${exp}/config.toml"

train_id="$(
  pueue add \
    --group gpu \
    --working-directory "$repo" \
    --label "${exp}:train" \
    --print-task-id \
    -- "$train_cmd"
)"

pueue add \
  --group analysis \
  --working-directory "$repo" \
  --label "${exp}:analyze" \
  --after "$train_id" \
  -- "codex exec -C '$repo' 'Use \$ml-docs log ${exp} to analyze pueue task ${train_id}. Read pueue logs, metrics artifacts, config, and existing experiment notes; then write results, analysis, and next actions in Japanese.'"
```

Use `$ml-iterate` instead of `$ml-docs` when the repo follows the simple per-experiment README flow rather than the 3-layer docs flow.

## Batch Queueing Pattern

When the user wants to keep the GPU busy, enqueue all train jobs first or register each train/analysis pair as you go. Use `--stashed` if the batch should not begin until registration is complete.

```bash
repo="/path/to/repo"

for exp in exp042 exp043 exp044; do
  train_cmd="uv run python src/exp/${exp}/train.py --config src/exp/${exp}/config.toml"
  train_id="$(
    pueue add \
      --stashed \
      --group gpu \
      --working-directory "$repo" \
      --label "${exp}:train" \
      --print-task-id \
      -- "$train_cmd"
  )"

  pueue add \
    --stashed \
    --group analysis \
    --working-directory "$repo" \
    --label "${exp}:analyze" \
    --after "$train_id" \
    -- "codex exec -C '$repo' 'Use \$ml-docs log ${exp} to analyze pueue task ${train_id} and update experiment notes in Japanese.'"
done

pueue enqueue --group gpu
pueue enqueue --group analysis
```

## Failure-Aware Analysis

`pueue add --after <id>` starts the dependent task only after dependencies succeed. If the user wants analysis for failed runs too, register an analysis task that waits for completion and inspects final state instead of using `--after` as the only mechanism.

Template, after replacing `<train_id>`, `<repo>`, and `<exp>`:

```bash
pueue add \
  --group analysis \
  --working-directory "<repo>" \
  --label "<exp>:analyze-any-exit" \
  -- "pueue wait <train_id> --quiet; codex exec -C '<repo>' 'Analyze pueue task <train_id> for <exp>. Read status, logs, metrics if present, and existing notes. If training failed, explain the failure evidence and record next debugging actions in Japanese.'"
```

Before using this pattern, confirm the local `pueue wait --help` semantics and whether its exit status blocks the `codex exec` command. If needed, use `;` rather than `&&` so Codex still runs after a failed training task.

## Monitoring

Useful commands:

```bash
pueue status --group gpu
pueue status --group analysis
pueue status 'columns=id,status,label,start,end order_by id desc first 20'
pueue follow <task_id> --lines 80
pueue log <task_id> --lines 120
pueue log <task_id> --full
pueue status --json
pueue log <task_id> --json --full
```

Use `pueue log --full` carefully for very large logs. Prefer metrics files and final summaries when logs are huge.

## Codex Analysis Prompt Checklist

Include these facts in the analysis prompt:

- Experiment id and title.
- Pueue train task id and label.
- Train command and working directory.
- Config path and changed code paths.
- Metrics/log/artifact paths.
- Baseline and hypothesis from notes.
- Required docs target, such as `src/exp/exp042/README.md` or `docs/logs.md`.
- Whether to analyze only successful runs or failures too.

Ask the analysis Codex to update notes, not to rerun training unless explicitly requested.

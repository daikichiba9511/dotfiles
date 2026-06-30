---
name: pueue-ml-experiments
description: Use pueue as a local ML experiment scheduler on a single-GPU workstation. Use when the user wants to set up or operate pueue queues for ML experiments, keep one NVIDIA GPU busy, enqueue batches of train/eval jobs, inspect pueue status or logs, chain post-run Codex analysis, or update experiment notes from queued job outputs.
---

# Pueue ML Experiments

Use pueue as the local queue and Codex as the post-run analyst. Assume one NVIDIA GPU by default unless the repo or user says otherwise.

## Operating Model

- Use a `gpu` group with parallelism `1` for training and GPU evaluation jobs.
- Use a separate `analysis` group for `codex exec` jobs so the GPU slot is released before note writing starts.
- Use labels that include the experiment id and phase, such as `exp042:train` and `exp042:analyze`.
- Treat pueue as the execution queue. Keep hypotheses, results, interpretation, and next actions in repo docs through `$ml-iterate` or `$ml-docs` when those skills apply.
- Write experiment notes in Japanese unless the user requests another language.

## Required Checks

Before composing or running pueue commands, read [references/pueue-recipes.md](references/pueue-recipes.md).

Then verify the local environment:

1. Run `pueue --version` and `pueue status`.
2. If pueue is missing or the daemon is unavailable, report the blocker and the exact command that failed. Do not pretend the queue was changed.
3. Inspect `pueue add --help`, `pueue group --help`, or `pueue parallel --help` when command syntax matters because pueue flags can vary by version.
4. Avoid `pueue reset`, `pueue clean`, `pueue remove`, and `pueue kill` unless the user explicitly asks or stopping/removing queued work is necessary. State the impact before doing it.

## Workflow

1. **Gather context**: identify the experiment directory, command, config file, working directory, expected output artifacts, metrics location, and docs target.
2. **Pre-register the run**: before enqueueing, update the experiment notes with baseline, change, hypothesis, success criteria, command/config evidence, and expected interpretation scenarios.
3. **Ensure groups exist**: create or reuse `gpu` and `analysis`; set `gpu` parallelism to `1`.
4. **Enqueue the GPU job**: add the train/eval command to the `gpu` group with a clear label and capture the returned task id.
5. **Enqueue analysis**: add a `codex exec` task to the `analysis` group that depends on the GPU task when success-only analysis is acceptable.
6. **Monitor**: use `pueue status`, `pueue follow`, and `pueue log` to inspect progress. Prefer pueue logs over ad hoc terminal output.
7. **Post-run notes**: have the analysis Codex read pueue logs, metrics files, configs, and existing notes; then update results, analysis, and next actions.

## Analysis Job Rules

- Use `pueue add --after <train_id>` for analysis that should run only after successful GPU completion. Pueue marks the dependent task failed if a dependency fails.
- If failure analysis must also run, do not rely only on `--after`. Use an analysis-side watcher command that waits for the GPU task to finish, reads its status/logs, and invokes `codex exec` regardless of train exit status. Verify the exact `pueue wait` behavior locally first.
- Keep analysis tasks out of the `gpu` group unless they actually require the GPU.
- Include the pueue task id, command label, expected artifacts, metrics paths, and docs path in the Codex prompt.
- Prefer `codex exec -C <repo>` for non-interactive note writing. Keep sandboxing to normal repo writes unless the task truly needs broader access.

## Scheduling Guidance

- For a single RTX 3090, default to one GPU task at a time. Increase `gpu` parallelism only for explicitly CPU-bound tasks or tiny GPU probes that the user wants to overlap.
- Enqueue many GPU experiments in order rather than waiting for each to finish. The goal is to keep the GPU queue non-empty.
- Use `--stashed` when assembling a batch that should not start until all train and analysis tasks are registered.
- Use pueue priorities for urgent queue order changes instead of force-starting GPU jobs. `pueue start <task_id>` can ignore parallelism and dependency limits.
- Make each queued command self-contained: set the working directory, activate the needed environment, point to a unique output directory, and avoid interactive prompts.

## Completion Report

When you finish queue changes, report:

- Created/reused groups and parallelism.
- Enqueued task ids, labels, and dependency links.
- Where logs and metrics will be read from.
- Which docs will be updated by the analysis job.
- Anything that could not be verified locally.

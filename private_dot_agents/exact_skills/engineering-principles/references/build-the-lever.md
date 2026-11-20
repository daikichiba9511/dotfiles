# Build the Lever

**Apply when:** the work is non-trivial and mechanical in shape: bulk edits, migrations, repeated analyses, or checks a reviewer should be able to rerun.

**Rule:** build the small tool that does or proves the work (codemod, script, generator, rerunnable check) instead of doing it by hand. Skip the tool for a couple of obvious edits.

- Do the first unit by hand, then build the tool and prove it by rerunning it on that unit. Make it safe to rerun ([make-operations-idempotent](make-operations-idempotent.md)).
- A deterministic tool beats fanning out to subagents. When you do fan out, give delegates one written recipe with the verification contract and the boundaries they must not cross.
- Build the smallest script that does the job, never a framework.
- Keep the tool where the user can rerun it; propose committing it only when the work outlives the session.

**Defers to:** in exploratory ML code, do not add helpers or tooling for hypothetical reuse (`coding-rules` ML override); a one-off verification script outside the experiment is fine.

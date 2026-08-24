# Checkpoint history

This table is append-only. Compute `artifact_hash` from the semicolon-separated files in `artifact`. The latest fresh row for every required checkpoint is the current state.

| attempt_id | checkpoint | artifact | artifact_hash | status | finding | action | invalidates | supersedes |
|---|---|---|---|---|---|---|---|---|

---
name: no-fallbacks
description: Use before editing experiment code, specs, configs, diagnostics, or workflow files when a change could add compatibility behavior, aliases, silent fallbacks, alternate execution paths, optional defaults, environment defaults, or default-value fallbacks.
---

# No Fallbacks

For experiment code, prioritize hypothesis purity and fail-fast behavior over backward compatibility.

## Rules

- Do not add backward compatibility, aliases, compatibility layers, deprecated paths, silent fallbacks, or alternate execution paths unless the user explicitly asks for them.
- When replacing behavior, remove the old path. Do not keep historical traces, legacy branches, old config keys, or transitional aliases.
- Missing required config, missing dict keys, missing env vars, impossible states, and unsupported modes must fail fast with a clear error.
- Do not use default-value fallbacks for required values:
  - `dict.get(key, default)`
  - nested `cfg.get("new", cfg.get("old"))`
  - `os.getenv("NAME", default)`
  - `kwargs.pop(name, default)`
  - `value or default` when a missing or falsey value would indicate a bug
- If a value is truly optional, name it as optional and handle `None` explicitly.
- If a default is a real domain constant, define it as an explicit constant, not as a fallback hidden inside lookup code.
- If an alias or migration path is explicitly required, make it loud:
  - document why it exists
  - count or report when it fires
  - reject ambiguous mixed old/new keys
  - include a removal condition

## Experiment Code Guidance

- Prefer replacing the main path over adding a side path.
- Prefer deleting stale branches over preserving compatibility.
- Prefer one authoritative producer and one explicit consumer for each signal.
- Diagnostics should call production logic instead of reimplementing it.
- A fallback that keeps the run alive can invalidate the experiment result by hiding a disconnected or broken path.

## Before Finishing

Report whether the change introduced any of the following:

- compatibility layer
- alias
- fallback path
- default value for missing config
- `dict.get(..., default)` for required data
- `os.getenv(..., default)`
- old branch left in place
- diagnostics reimplementing main logic

If any item is present, explain why it was explicitly required.

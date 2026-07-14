# Global Rules

Follow the same coding rules defined in `~/.claude/rules/`.

## Codex-specific

- Keep output concise.
- When changing code, explain the reason in one line.
- When writing or editing Python, target Python 3.12 or later as the minimum supported version.
- Do not add compatibility constructs that Python 3.12 does not require, including `from __future__ import annotations`.
- For experiment code changes that could add compatibility behavior, aliases, silent fallbacks, alternate paths, or default-value fallbacks, use the `no-fallbacks` skill before editing.
- For any non-trivial task where a wrong initial framing is costly, read `~/.codex/skills/meta-perception/SKILL.md` before acting, even if the skill mechanism does not trigger automatically.
- Always do this when the user explicitly mentions `meta-perception`, `/meta-perception`, debugging, root-cause analysis, architecture or design choices, research-heavy investigations, or underperforming ML experiments.

## File Deletion

- NEVER use `rm`, `rm -r`, or `rm -rf`.
- Use `trash` on macOS.
- Use `gio trash` on Linux (especially Ubuntu).
- These move files to the system trash, making them recoverable.

## Network Downloads

- `curl` and `wget` are allowed for direct downloads or fetches when needed.
- NEVER pipe `curl` or `wget` output directly into a shell, such as `curl ... | sh` or `wget -qO- ... | bash`.
- If an installer suggests pipe-to-shell, ask the user to run it manually or download the script first and inspect it.

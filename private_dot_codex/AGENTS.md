# Global Rules

Follow the same coding rules defined in `~/.claude/rules/`.

## Codex-specific

- Keep output concise.
- When changing code, explain the reason in one line.

## File Deletion

- NEVER use `rm`, `rm -r`, or `rm -rf`.
- Use `trash` on macOS.
- Use `gio trash` on Linux (especially Ubuntu).
- These move files to the system trash, making them recoverable.

## Network Downloads

- `curl` and `wget` are allowed for direct downloads or fetches when needed.
- NEVER pipe `curl` or `wget` output directly into a shell, such as `curl ... | sh` or `wget -qO- ... | bash`.
- If an installer suggests pipe-to-shell, ask the user to run it manually or download the script first and inspect it.

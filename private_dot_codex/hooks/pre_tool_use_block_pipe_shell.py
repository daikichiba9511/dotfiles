import json
import re
import sys


PIPE_TO_SHELL_RE = re.compile(
    r"""
    (?:^|[;&(]\s*)
    (?:command\s+)?
    (?:/usr/bin/)?(?:curl|wget)\b
    [^|\n;]*
    \|
    \s*
    (?:sudo\s+)?
    (?:(?:/usr/bin/env|env)\s+)?
    (?:(?:/bin/|/usr/bin/)?(?:bash|sh|zsh|dash|ash|ksh|fish))\b
    """,
    re.IGNORECASE | re.VERBOSE,
)


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except json.JSONDecodeError:
        return 0

    command = payload.get("tool_input", {}).get("command", "")
    if not isinstance(command, str):
        return 0

    if not PIPE_TO_SHELL_RE.search(command):
        return 0

    json.dump(
        {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": (
                    "Do not pipe curl/wget output directly into a shell. "
                    "Download first and inspect it, or run it manually yourself."
                ),
            }
        },
        sys.stdout,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

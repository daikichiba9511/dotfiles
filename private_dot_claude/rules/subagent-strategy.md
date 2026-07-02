# Sub-agent Strategy

- Sub-agents inherit the session model by default — don't pin `model:` without a specific reason.
- For pure retrieval (file paths, line numbers, verbatim quotes, test output), use `model: "sonnet"` with the Explore agent and request structured facts only.
- Prefer several narrow, parallel queries over one broad one. Give explicit search keywords and scope; for web research, add domain or time-range constraints when applicable.

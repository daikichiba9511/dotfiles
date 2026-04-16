# Sub-agent Strategy

## Model Selection
- Exploration and search tasks: use `model: "sonnet"` with `subagent_type: "Explore"`
- Tasks requiring only raw data (file paths, code quotes, test results): use `model: "sonnet"`
- Tasks requiring synthesis, analysis, or judgment: use `model: "opus"`

## Prompt Rules for Non-Opus Sub-agents
- Always include "分析や提案は不要。事実のみ返して" or equivalent constraint
- Require structured output format (file path + line number + verbatim quote)
- Request only raw data: file paths, line numbers, and verbatim code quotes

## Research Sub-agent Guidelines (WebSearch, Grep, Read, Glob)
- Specify search keywords and scope explicitly in the prompt
- Request results as a list of: source URL or file path, relevant quote, and context
- Run multiple narrow queries in parallel rather than one broad query
- When searching the web, include domain constraints or time range if applicable

## When to Upgrade to Opus
- The sub-agent needs to summarize findings that won't fit in parent context
- The task involves architectural judgment or design decisions
- The output will be directly used in the final deliverable without parent re-evaluation

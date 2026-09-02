---
name: research-synthesis
description: "Use for a bounded, source-backed investigation or comparison of a technical topic, codebase, paper, API, benchmark, Kaggle discussion, or design option that ends in a written synthesis. Do not use when implementation alone is requested or when a multi-stage subagent research program is needed."
allowed-tools: Read, Glob, Grep, WebFetch, WebSearch, Bash(kaggle:*)
---

# Research Synthesis

Source-backed research workflow for technical questions.
Use `references/report-format.md` when you need a full comparison memo, option matrix, or recommendation write-up.

## Core Rules

- Prefer primary sources: official docs, source code, papers, specs, benchmark repositories
- Compare at least two plausible approaches when the answer is not obvious
- Research first; do not jump to implementation advice until the evidence is organized

## Workflow

### Step 1: Define the research target

Clarify:

- what exact question must be answered
- whether the target is a repo, paper, API, tool, architecture, or product choice
- whether the user needs a recommendation, a neutral summary, or a decision memo

### Step 2: Gather sources

Collect the minimum set of sources needed to answer the question:

- local codebase and configs if the question is project-specific
- official docs and source repos for implementation behavior
- papers, benchmarks, changelogs, and standards for claims about performance or correctness

For a Kaggle competition, dataset, notebook, model, benchmark, or community discussion, read `references/kaggle-discussions.md` before collecting. Use the official Kaggle CLI for topic discovery and comment trees; use the web only for content or stable links that the CLI does not expose.

If a source is large, skim structure first and then read only the relevant sections.

### Step 3: Extract claims

For each important claim, capture:

- claim
- source and provenance
- scope or assumptions
- evidence state from the global `Evidence and Inference` contract
- confidence or remaining verification need

Do not merge multiple claims together if they depend on different evidence.

### Step 4: Compare and synthesize

Organize findings by the user's decision surface:

- trade-offs
- prerequisites
- failure modes
- compatibility constraints
- maintenance cost
- performance or quality impact

Use the report formats in `references/report-format.md` when the result needs structure.

### Step 5: Recommend

When the user wants a recommendation:

1. state the best option for the user's constraints
2. explain why the alternatives lose
3. call out what would change your recommendation

## Output Expectations

- cite sources directly in the answer when using web or docs
- keep the final answer compressed unless the user asks for a full memo

$ARGUMENTS

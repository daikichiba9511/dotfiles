---
name: research-synthesis
description: "Research a technical topic, codebase, paper, tool, API, benchmark, or design choice and turn the findings into a source-backed synthesis. Use when the user asks to investigate, compare options, understand unfamiliar systems, read docs or papers, survey prior art, or wants recommendations before implementation. Trigger for requests like '調べて', '比較して', '先行事例を見て', '論文読んで整理して', 'この実装方針でよいか調査して'."
allowed-tools: Read, Glob, Grep, WebFetch, WebSearch
---

# Research Synthesis

Source-backed research workflow for technical questions.
Use `references/report-format.md` when you need a full comparison memo, option matrix, or recommendation write-up.

## Core Rules

- Prefer primary sources: official docs, source code, papers, specs, benchmark repositories
- Separate observed facts from your inference
- Make uncertainty explicit instead of smoothing it over
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

If a source is large, skim structure first and then read only the relevant sections.

### Step 3: Extract claims

For each important claim, capture:

- claim
- source
- scope or assumptions
- confidence level

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
- clearly mark inference vs evidence
- keep the final answer compressed unless the user asks for a full memo
- if evidence is weak, say so and explain what is missing

$ARGUMENTS

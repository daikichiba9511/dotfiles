---
name: meta-perception
description: "Understand a problem deeply before solving it: (1) build a precise, evidence-backed understanding, (2) research how similar problems were solved — in this codebase, in project knowledge, and on the web, (3) only then form solution candidates and recommend a direction. Use when starting any non-trivial problem: debugging an unfamiliar error, a design decision, an underperforming ML experiment, or any task where a wrong initial framing is costly. Trigger on requests like 'solve this problem', 'why is this failing', 'how should we approach this', 'デバッグして', 'この問題を解きたい', '原因を調べて', 'どう進めるべき', or an explicit /meta-perception."
allowed-tools: Read, Glob, Grep, WebSearch, WebFetch, Agent, Bash(git log:*), Bash(git show:*), Bash(git diff:*)
---

Models tend to pattern-match a problem to something familiar and start moving before the problem is actually understood — and rarely check whether the problem has already been solved. The result is confident progress in the wrong direction. This skill front-loads understanding and precedent research so the direction is right before implementation starts. The tool list is intentionally read-only: no editing until a direction is set.

## 1. Understand the problem deeply

Build an evidence-backed picture before hypothesizing:

- Restate the problem in your own words: what is actually being asked, and what does "solved" look like? Distinguish the reported symptom from the underlying problem — they are often not the same.
- Gather evidence from the source: reproduce the failure, read the actual error and the code path that produces it, look at the real data. For ML problems, look at the actual predictions and errors, not just the metric.
- List what is known (with evidence), what is unknown, and what is being assumed — and challenge every assumption the solution would depend on.

You are done here when you can state precisely what is happening, why, and what success looks like, each backed by something observed rather than inferred. If the evidence contradicts the user's framing, surface that before continuing.

## 2. Research similar problems

Before inventing anything, find out how this class of problem has been solved:

- **In this repository**: prior art in similar modules; `git log` / `git show` for past fixes of related symptoms.
- **In project knowledge**: check `.agents/lessons/`, and query the project wiki or zettel if one exists.
- **In the world**: search for the error message, the problem class, or the technique — GitHub issues, official docs, and for ML problems, papers and Kaggle discussions of similar setups.

Run these as parallel narrow searches, delegating to sub-agents per the sub-agent strategy. Collect two or three relevant precedents: what the situation was, what they did, and whether it transfers here.

## 3. Then form solutions

Only now, generate two or three candidate approaches informed by the precedents. For each: the mechanism (why it should work), its fit with the constraints found in phase 1, and its key risk. Recommend one with your reasoning, and state how the result will be verified.

## Boundaries

- Calibrate depth to the stakes: for a trivial problem with an obvious, verifiable fix, say so in one line and skip ahead — this skill exists to prevent wrong directions, not to add ceremony.
- Do not start implementing within this skill. Deliver the understanding, the precedents, and the recommended direction; implementation begins after the direction is confirmed (or immediately, if the user already gave the go-ahead and the direction is unambiguous).

## Additional Instructions

$ARGUMENTS

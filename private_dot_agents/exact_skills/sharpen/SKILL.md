---
name: sharpen
description: "Use before starting a task when the user wants their request played back and rewritten as a deeper (not bigger) prompt: restate the goal, underlying problem, assumptions, and success criterion in your own words, then produce a sharper prompt with outcome, verification, constraints, and out-of-scope items. Trigger on phrases like sharpen this prompt, in your own words, what do you think I'm trying to do, make this request deeper, 依頼を深掘りして. Do not use for implementation plans or task breakdowns (use plan), or for actually doing the task."
---

Do not start the task. Your output is a restatement and a rewritten prompt, nothing else.
Answer in the user's language (usually Japanese). Read files only when needed to understand the request; change nothing.

## 1. In your own words

Restate what you think the user is trying to achieve and what problem sits underneath the literal request. Cover:

- Goal: the outcome they want, not the action they named.
- Underlying problem: why this request exists now.
- Assumptions: what you are taking for granted about scope, context, or intent. Flag the ones that would change the work if wrong.
- Success criterion: what observable result would show it is done and right.

## 2. Go deeper, not bigger

Before rewriting, work out briefly:

- What a top professional in this field would do here that the user did not ask for.
- The rawest material they would start from (source data, logs, the actual code, primary docs) instead of an already digested summary.
- The specific methods and tools they would use.
- What, other than you or the user, would show the result is right (a test, a metric, a reproduction, an external reference).

Deeper means sharper and better evidenced, not more scope. Drop anything that only adds breadth.

## 3. Rewritten prompt

Write a self-contained prompt, in a fenced block, that states:

- Outcome: the sharpened goal and the success criterion.
- Inputs: the raw material to start from.
- Approach: the methods and tools from step 2.
- Verification: the independent check the agent must run and report.
- Experiments: prototype any choice an experiment can settle and recommend an option from what was observed; leave product or preference choices no experiment can settle to the user.
- Constraints and out of scope: what must not change and what to leave alone.

Then stop. Ask the user to confirm or correct the restatement, or to use the rewritten prompt as is.

Adapted from pstack (MIT, Lauren Tan); see LICENSE.pstack.

$ARGUMENTS

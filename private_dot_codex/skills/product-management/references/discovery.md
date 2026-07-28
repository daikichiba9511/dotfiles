# Product discovery

Use this reference to reduce uncertainty before committing to a product, feature, or solution.

## Choose the discovery context

- Existing product: start from observed behavior, support requests, interviews, usage data, and known constraints.
- New product: validate demand and reachability before spending much effort on feasibility or polish.
- Opportunity space: clarify the desired outcome and user problem before proposing features.

State the discovery question in a decision form, such as:

> Should we pursue X for Y users now, and what evidence would justify the commitment?

## Core workflow

### 1. Establish the evidence baseline

Record:

- what users actually did or said;
- the size and source of the sample;
- known business and technical constraints;
- prior attempts and their results;
- the decision deadline.

If evidence is thin, proceed with hypotheses but say so explicitly.

### 2. Map outcomes and opportunities

Use an Opportunity Solution Tree when several problems and solutions are being mixed together:

1. desired measurable outcome;
2. user opportunities or unmet needs;
3. candidate solutions for each opportunity;
4. experiments for the riskiest solution assumptions.

Do not put features in the opportunity layer.
Tie each opportunity to evidence or label it as hypothesized.

### 3. Generate options divergently

Generate options from at least three perspectives:

- Product: user value, business fit, strategic coherence;
- Design: workflow, comprehension, accessibility, behavior change;
- Engineering: feasibility, leverage, operational risk, simpler mechanisms.

Prefer meaningfully different mechanisms over cosmetic variants.
For a focused request, present 3–5 strong options; use 10 only for an explicit brainstorming workshop.

### 4. Surface assumptions

Write assumptions as falsifiable claims.
Cover the applicable risk categories:

- Value: the target user wants the outcome enough to change behavior.
- Usability: the user can discover, understand, and complete the workflow.
- Feasibility: the team can deliver and operate it within the constraints.
- Viability: economics, policy, legal, sales, and support remain workable.
- Reachability: the target can be found and acquired through plausible channels.
- Strategy: success reinforces rather than distracts from the chosen direction.
- Team: the required capabilities and ownership exist.

### 5. Prioritize assumptions

Rank assumptions using ordinal judgments rather than fake precision:

| Factor | Low | Medium | High |
|---|---|---|---|
| Consequence if false | Local inconvenience | Material rework | Invalidates the bet |
| Uncertainty | Directly evidenced | Partial or indirect evidence | Little or conflicting evidence |
| Test cost | Hours | Days | Weeks or substantial spend |

Test high-consequence, high-uncertainty assumptions first.
When two tests offer similar learning, choose the cheaper or faster one.

### 6. Design experiments

Every experiment must specify:

- assumption being tested;
- target population;
- observable behavior, not merely stated preference;
- success and failure thresholds set before running;
- duration or sample requirement;
- cost and operational risk;
- decision rule: proceed, revise, or stop.

Experiment options for existing products include log analysis, prototype tests, fake doors, concierge workflows, technical spikes, and controlled experiments.
Options for new products include problem interviews, landing-page demand tests, letters of intent, pre-orders, manual service delivery, and narrow prototypes.

Do not use an A/B test when traffic is insufficient or the core uncertainty is qualitative.

## Customer interviews

Prepare interviews around past behavior:

- ask about the last concrete occurrence;
- reconstruct the sequence, workaround, people involved, time, and cost;
- probe what triggered action and what prevented change;
- avoid pitching the idea or asking whether the user likes it;
- separate verbatim evidence from interpretation.

Afterward, summarize jobs, pains, alternatives, satisfaction signals, contradictions, and unanswered questions.
Do not promote one interview into a market conclusion.

## Feature-request triage

Group requests by underlying job or problem rather than wording.
For each group, record frequency, affected segment, severity, current workaround, strategic fit, evidence strength, and likely effort.
Recommend an action: investigate, test, plan, monitor, or decline.

## Discovery result

Return the smallest artifact that supports the decision:

1. discovery question and current recommendation;
2. evidence and confidence;
3. opportunities and candidate solutions;
4. critical assumptions in priority order;
5. experiments with thresholds and decision rules;
6. explicit stop or pivot conditions;
7. remaining unknowns.

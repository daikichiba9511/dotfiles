# Product planning and execution

Use this reference to turn a validated product direction into an aligned, testable plan.

Do not use product artifacts to hide unresolved discovery or strategy decisions.

## PRD

Match the document size to the decision and delivery risk.
A useful PRD contains:

1. decision summary: what is proposed, for whom, and why now;
2. problem evidence and current workaround;
3. goals, measurable outcomes, and explicit non-goals;
4. target users and applicable permissions or constraints;
5. user journeys and prioritized requirements;
6. solution boundaries and important product decisions, without pretending unresolved implementation choices are settled;
7. rollout, dependencies, and operational considerations;
8. risks, open questions, owners, and decision dates.

Requirements should be observable and testable.
Do not assign P0/P1/P2 labels until the basis for priority is stated.

## Prioritization

Select a framework based on the available evidence:

| Need | Appropriate method | Watch for |
|---|---|---|
| Fast early screening | Impact × effort | Ignores confidence and reach |
| Comparable initiatives | RICE | False precision in scores |
| Sequencing by economic urgency | WSJF | Weak cost-of-delay estimates |
| Customer importance vs satisfaction | Opportunity scoring | Survey and sampling bias |
| Satisfaction effects | Kano | Category changes by segment and time |
| Scope negotiation | MoSCoW | Everything becoming Must |

Show raw evidence and assumptions next to scores.
Use rankings to structure a decision, not to automate it.

## Outcome roadmap

Replace feature buckets with:

- desired user or business outcome;
- evidence for the opportunity;
- leading indicator and target;
- candidate bets, not fixed promises;
- confidence, dependencies, and review date.

Keep horizons honest.
Use dates only when there is a real commitment or dependency.

## Backlog items

Choose one format:

- User story: `As a [role], I want [capability], so that [benefit]` when actor and capability matter.
- Job story: `When [situation], I want to [motivation], so I can [outcome]` when context and causality matter.
- Why–What–Acceptance: when the team needs strategic context plus concise delivery boundaries.

Acceptance criteria must cover happy paths, important edge cases, error behavior, permissions, and observable outcomes.
Use `spec-behavior` for stateful or multi-actor behavior and `tdd` for implementation tests.

## OKRs

Objectives describe a qualitative change, not a project list.
Key results measure outcomes and include baseline, target, deadline, and source.
Check that the team can materially influence them and that guardrail metrics prevent harmful optimization.

## Pre-mortem and red-team

Assume the plan failed and identify:

- credible failure mechanism;
- earliest warning signal;
- impact and reversibility;
- mitigation or contingency;
- owner and trigger date;
- whether it blocks launch, follows immediately, or is monitored.

Surface unspoken risks explicitly, but do not inflate speculative concerns into blockers.

## Stakeholders

Map decision authority, influence, impact, incentives, concerns, and required involvement.
Use a power/interest grid only as a compact summary.
The communication plan should specify decision or message, audience, owner, channel, timing, and expected response.

## Delivery-cycle helpers

- Sprint planning: use actual capacity, dependencies, uncertainty, and a clear sprint outcome.
- Retrospective: turn observations into at most a few owned experiments with review dates.
- Release notes: organize around user-visible value and behavior changes, not internal ticket titles.
- Meeting notes: separate decisions, evidence, unresolved questions, and actions with owners and dates.

## Planning result

Return the requested artifact plus:

1. decision and scope;
2. evidence and assumptions;
3. outcomes and measures;
4. non-goals and trade-offs;
5. risks, dependencies, and open questions;
6. owners and review points.

---
name: product-management
description: "Use for evidence-backed product decisions and artifacts such as discovery, user or market research, product strategy, PRDs, roadmaps, go-to-market, product analytics, or shipping readiness. Do not use for software implementation plans, code review, generic writing, or legal documents."
---

# Product Management

Help the user make a product decision.
Do not act as a generic template generator: an artifact is useful only when it makes the decision, evidence, trade-offs, and next validation step clearer.

Respond in the user's language.

## Route the request

Identify the decision being made, then read only the references needed for that decision:

| Area | Use for | Reference |
|---|---|---|
| Discovery | Opportunities, ideas, assumptions, interviews, experiments, feature-request triage | [references/discovery.md](references/discovery.md) |
| Research | User evidence, personas, segmentation, journeys, feedback, competitors, market sizing | [references/research.md](references/research.md) |
| Strategy | Vision, strategic choices, value proposition, business model, pricing, market scan | [references/strategy.md](references/strategy.md) |
| Planning | PRDs, outcome roadmaps, prioritization, backlog items, OKRs, pre-mortems, stakeholders | [references/planning.md](references/planning.md) |
| Go-to-market | Beachhead, ICP, positioning, channels, launch, growth loops, battlecards | [references/go-to-market.md](references/go-to-market.md) |
| Analytics | Metrics, dashboards, cohorts, experiments, product SQL | [references/analytics.md](references/analytics.md) |
| Shipping | Documentation, intended-vs-implemented review, test coverage, shipping packet | [references/shipping-readiness.md](references/shipping-readiness.md) |

If the user names an upstream PM Skills method, use [references/framework-index.md](references/framework-index.md) to route it.

For a request spanning several areas, state the order and load the references progressively.
Do not run every framework merely because it is available.

## Universal workflow

1. Frame the decision.
   Capture the product stage, decision owner, audience, deadline, and the decision the work must inform.
2. Inventory the evidence.
   Separate `Observed`, `Inferred`, `Assumed`, and `Unknown` claims.
3. Choose the smallest adequate method.
   Load the relevant reference and explain why that method fits.
4. Perform the analysis.
   Preserve evidence links and calculations; do not turn missing inputs into invented facts.
5. Pressure-test the result.
   Identify load-bearing assumptions, plausible counterexamples, and what would reverse the recommendation.
6. Deliver a decision-oriented result.
   Lead with the recommendation or decision, then evidence, trade-offs, risks, and the cheapest useful next test.

## Interaction modes

- Default: complete the analysis end to end using available context. Ask only when an unanswered question would materially change the result.
- Workshop: when the user explicitly wants facilitation, pause at meaningful choice points such as selecting opportunities or choosing assumptions to test.
- Artifact: create or modify a workspace document only when the user asks for a file or the task explicitly requires one. Otherwise answer in the conversation.

## Evidence rules

- When no research data exists, label personas, segments, journeys, market sizes, and demand claims as hypotheses.
- Browse for current competitors, prices, market conditions, laws, benchmarks, and other time-sensitive facts; cite the supporting sources.
- Prefer primary evidence: user behavior, interviews, product data, contracts, support records, and direct competitor materials.
- For statistical or financial calculations, use a reproducible calculation rather than mental arithmetic and expose the assumptions.
- Do not confuse statistical significance, practical significance, and strategic importance.
- A strategic choice must name what is intentionally not being pursued.

## Boundaries with nearby skills

- Use `plan`, `architect`, or `spec-behavior` for software implementation design after the product decision is made.
- Use `code-review` or `security-review` for specialist code findings. The shipping workflow coordinates those reviews; it does not replace them.
- Use `prose-lint` or `japanese-tech-writing` for generic writing quality work.
- Legal documents, privacy policies, and resume tailoring are intentionally outside this skill.

## Source basis

This skill is a Codex-oriented adaptation of [phuryn/pm-skills](https://github.com/phuryn/pm-skills), reorganized around progressive disclosure and decision-focused workflows.
See [LICENSE.pm-skills](LICENSE.pm-skills) for the upstream MIT license.

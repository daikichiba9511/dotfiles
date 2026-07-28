# Product analytics

Use this reference to turn a product decision into a trustworthy measurement and analysis plan.

## Start from the decision

Define the behavior or outcome being measured, population, unit of analysis, time window, comparison, and decision threshold.
Write the metric definition before querying data.

## Metric system

Choose a North Star only when it represents recurring customer value and connects plausibly to durable business value.
Classify the dominant value mechanism when helpful:

- Attention: value grows with meaningful consumption or engagement.
- Transaction: value is realized through completed exchanges.
- Productivity: value comes from successful work accomplished.

Pair the outcome metric with:

- input metrics the team can influence;
- quality and guardrail metrics;
- segment and lifecycle cuts;
- freshness, ownership, and alert thresholds.

Avoid composite metrics that nobody can interpret or act on.

## Dashboard design

For each metric specify name, decision served, exact formula, grain, source, update cadence, owner, expected range, alert rule, and known failure modes.
Organize the dashboard around decisions rather than available charts.

## Cohort analysis

Define cohort membership, cohort date, eligibility, activity event, retention interval, observation window, and censoring treatment.

Check:

- acquisition-period effects;
- incomplete recent cohorts;
- changes in instrumentation or eligibility;
- survivorship and reactivation;
- segment composition shifts.

Return retention or adoption curves with cohort sizes and uncertainty where appropriate.
Explain whether a difference reflects behavior, mix, seasonality, or insufficient evidence.

## Controlled experiments

Before analysis, record hypothesis, primary metric, guardrails, randomization unit, allocation, MDE, power, significance level, planned duration, and stopping rule.

Validate:

- sample-ratio mismatch and assignment integrity;
- exposure and eligibility logic;
- adequate duration and sample size;
- missing data, bots, duplicates, and contamination;
- novelty, seasonality, peeking, and multiple comparisons.

Calculate absolute effect, relative effect, confidence interval, p-value when appropriate, and practical impact.
Use executable, reproducible calculations for statistics.

Recommend one of:

- Ship: evidence meets the predeclared decision rule and practical value exceeds costs and risks.
- Extend: the design remains valid but precision is insufficient and more data has information value.
- Stop: the test is invalid, the expected value is poor, or continuation is not worthwhile.

Do not reinterpret an underpowered null result as proof of no effect.

## Product SQL

Before writing SQL, inspect or request the schema, dialect, entity grain, event semantics, timezone, identity rules, and denominator.

Return:

1. assumptions;
2. query with readable stages;
3. validation queries or sanity checks;
4. known edge cases;
5. interpretation limits.

Protect against join multiplication, late events, slowly changing dimensions, inconsistent identities, and partial periods.
Use general coding conventions for executable scripts.

## Analytics result

Lead with the product decision and recommendation, followed by metric definitions, method, results with uncertainty, practical impact, caveats, and monitoring or follow-up analysis.

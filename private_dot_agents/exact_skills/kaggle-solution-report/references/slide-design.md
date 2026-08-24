# Kaggle slide adapter

Apply this reference after the general `topic-learning-slides` Typst/Polylux contract. It adds Kaggle-specific public-release limits, team headings, Gold overview requirements, publication-evidence coverage, and report/slide parity. The general Skill owns the abstract-to-detail reading order, Japanese logic reconstruction, and semantic checkpoints.

## Contents

1. Output and public-release boundary
2. Page contract
3. Salience and visual hierarchy
4. Design system
5. Typography and spacing
6. Composition choices
7. Compilation and deck-level QA

## 1. Output and public-release boundary

Create a 16:9 Typst deck with Polylux and `metropolis-polylux`. Derive it from the verified report and synthesis, not directly from raw discussions. Start from `assets/workspace-template/slides/theme.typ`.

Use these defaults when the fonts exist:

- Japanese text: `BIZ UDPGothic`
- math: `New Computer Modern Math`
- code: `HackGen35 Console NFJ`
- Polylux: `@preview/polylux:0.4.0`
- Metropolis: `@preview/metropolis-polylux:0.1.0`

If a font is absent, choose an installed Japanese font and record the change. Never accept missing-glyph boxes.

When `~/MyVault/slides` exists, inspect representative Kaggle retrospective pages and the relevant Metropolis theme source there before composing; otherwise start from the bundled theme. Also inspect any other local slide examples, theme, or public reference decks the user supplies. Abstract their hierarchy, density, and explanatory rhythm; do not copy branding or copyrighted figures.

The public deck must not contain Kaggle credentials, local usernames, private paths, raw comment dumps, inaccessible private artifacts, participant claims presented as verified facts, unlabeled inference, or copyrighted figures copied without permission and attribution. Redraw mechanisms from facts when appropriate and cite the underlying stable source. State the included rank range and unavailable/partial solution count.

Give each public source a stable `[S-001]`-style ID in `synthesis/slide-sources.csv`. Place the marker beside the factual claim or representation and add the matching entry to a visible `出典一覧`. The appendix is a publication index back to the canonical Kaggle ledgers, not a substitute research ledger. It may appear immediately before the final individual-solution reference block so that the ranked solutions remain the final substantive section.

## 2. Page contract

Use one slide for one question, concept, or logical step. Build every substantive slide as:

1. **Title:** name the subject, not a vague category or forced conclusion.
2. **Claim:** state the one thing the audience should understand.
3. **Explanation:** use two to four short paragraphs to connect evidence and mechanism.
4. **Optional representation:** add one diagram, equation, example, compact table, or supplement only when it improves comprehension, comparison, or recall.

Two to four short explanatory paragraphs are the default for analytical pages, not a quota. A team-level whole-solution overview is an explicit exception: use a title, one concrete claim, a dominant self-contained pipeline figure, a nearby source, and at most one short orientation paragraph. Put mechanism, evidence, and transfer lessons on the following pages instead of repeating the diagram in prose.

A prose-only slide is valid. Do not add a visual merely to fill space. Do not add a repeated `Implication`, takeaway bar, oversized number, or ritual card row; the claim already carries the conclusion.

Most analytical slides should include at least two concrete evidence items across the explanation and optional representation. Keep evidence limitations on the same slide when they materially change how the claim should be read. Put a nearby source marker on every factual figure, table, metric definition, and solution claim, and label participant-reported values as such.

Do not optimize for a target page count. Use the closed publication-evidence map to decide length: merge items only when they form one causal or experimental unit, and split them when the reader would otherwise have to infer the intervention, comparison, result, or decision. A visually clean but semantically under-covered deck does not pass release review.

Use English ordinals followed by `solution:` on gold-team pages, for example `1st solution: Avengersの全体像` and `11th solution: 損失値の大きい学習例を除くと悪化した`. Never use `Rank 1:`. Give every method-bearing gold team an end-to-end overview page and at least one page explaining its central decision, evidence, or negative result. Represent upper-silver teams in factor-level comparisons unless the user explicitly requests individual pages.

## 3. Salience and visual hierarchy

Assign one role to each substantive slide before styling it:

| role | purpose | default treatment |
|---|---|---|
| `quiet/context` | facts, definitions, evidence limits, connective reasoning | understated claim and prose; no payload visual by default |
| `support/evidence` | equation, exact comparison, worked example | prose plus one compact representation |
| `hero/mechanism` | decisive pipeline, failure path, spatial relation, experiment | one dominant representation |

Keep hero pages a clear minority at narrative turning points; do not enforce a numeric percentage. Review the sequence as quiet explanation, supporting evidence, and a few strong visual peaks. The representative pipeline should remain memorable in the contact sheet.

Within each gold-team block, treat the whole-solution overview as `hero/mechanism` and the following mechanism/evidence pages as quiet or supporting pages unless a second independent mechanism deserves emphasis. This creates local hierarchy even when the deck contains many team overviews.

Use one semantic accent plus neutrals. Establish hierarchy in this order: title, claim, position, size, weight, rule or border, then color. Accent a payload element only when the claim identifies it as the selected value, bottleneck, changed variable, error path, or decision. Keep symmetric peers neutral. At most one alert color may supplement the accent when a warning cannot be expressed structurally.

## 4. Design system

Keep these defaults unless the user supplies a public brand:

| role | default | use |
|---|---|---|
| canvas | white | content slides |
| title bar / title slide | dark ink `#263238` | stable frame |
| primary accent | teal `#00796b` | one semantic focus |
| structural text | gray `#6b777c` | captions, borders, secondary labels |
| neutral surface | `#f4f7f8` | ordinary panels |
| accent surface | `#e9f3f1` | one emphasized block |

If a competition-specific accent is needed, replace teal once in `theme.typ`; do not add parallel hues per slide.

Use the bundled primitives consistently:

- `explainer(title, point, explanation, visual, note: ..., source: ..., quiet: ...)`
- `lesson(title)[body]` for exceptional compositions
- `claim[body]` and `quiet-claim[body]`
- `prose[body]`
- `datum(value, label, detail: ...)` only for a value the audience must remember
- `stage(title, body)`, `step(number, title, body)`, and `quiet-step(number, title, body)`
- `supplement[body]` and `source-note[body]`

## 5. Typography and spacing

- Use 28–30 pt for the title-slide title and the Metropolis heading scale for content titles.
- Use 15–17 pt for explanatory prose, 12–14 pt for diagram labels and necessary tables, and 8.5–9.5 pt only for sources or footers.
- Never shrink analytical prose below 14.5 pt or diagram labels below 11 pt to fit. Split the page or enlarge the figure.
- Use 16–20 pt gutters for two-column layouts and 8–12 pt between compact stages.
- Align panels to a shared grid and keep insets consistent.
- Prefer a few large blocks; more than three peer panels usually weakens hierarchy.
- Balance whitespace above and below the content group. Keep the visual center near the middle of the usable canvas rather than pinning sparse content to the title bar.
- Give prose-only pages a shorter reading measure, larger paragraph spacing, and visibly separated claim and body.
- Judge text and figure scale on a full-resolution page. Use the contact sheet to judge deck rhythm, not legibility.

## 6. Composition choices

Use a table only when repeated fields require alignment. Do not impose a deck-wide table count; inspect whether repeated table layouts flatten the narrative. Prefer prose plus a concrete example, diagram, equation, timeline, or paired case when that representation adds information.

Use these recipes when appropriate:

1. **Task example:** explanation followed by one representative input/output case.
2. **Metric:** weights and symbols in prose, then one native Typst equation and numerical example.
3. **Comparison:** explain the distinction, then use symmetric examples or a compact table.
4. **Pipeline:** show the full flow once, then revisit one bottleneck per later slide.
5. **Data property:** explain why one count matters; enlarge it only when its magnitude must be remembered.
6. **Experiment:** show hypothesis, fixed conditions, intervention, result, and decision chronologically.

Omit agenda and section-divider slides by default. Include them only when a long live talk materially benefits from navigation.

When creating or editing diagrams, plots, node-edge layouts, or spatial schematics, apply the separate diagram contract selected by `SKILL.md`.

Do not use one gold-field comparison slide as a replacement for the individual solution overviews. In the default abstract-first narrative, the comparison or relationship map may appear before the detailed team blocks only when it defines the compared bottleneck, names the supporting ranks or teams, preserves counterexamples and unknowns, and remains understandable without prior team-page knowledge. The later reference section must still preserve every method-bearing gold topology. If the user explicitly chooses a team-first narrative, place the comparison after those blocks.

## 7. Compilation and deck-level QA

Use the mise-managed Typst toolchain. Compare the installed Typst version with `mise latest typst`; unless the workspace pins an older compiler, install and select the latest stable version with mise and record the used version in `scope/scope.md`. Verify package compiler requirements before selecting package releases.

Compile from the workspace root:

```bash
uv run --python 3.12 <skill-root>/scripts/validate_workspace.py <workspace>
mise exec -- typst compile --root <workspace> <workspace>/slides/slides.typ <workspace>/slides/slides.pdf
uv run --python 3.12 <skill-root>/scripts/validate_workspace.py <workspace> --require-pdf
```

Render every slide at full resolution under `reviews/renders/` and create a contact sheet in the same directory. Check:

- every slide has an obvious first reading target
- titles, claims, prose, and sources are legible
- no clipping, accidental Typst overflow/continuation pages, footer collisions, or tiny text; intentionally titled branch-zoom slides are allowed
- no decorative accent without semantic purpose
- quiet/support/hero roles produce deliberate peaks and valleys
- prose-only pages are vertically balanced rather than compressed at the top
- every table has a comparison purpose
- no generic `Implication` or repeated takeaway strip appears
- every method-bearing gold team has its own whole-solution overview, with the same topology as the report figure
- the abstract section is readable without the later team details, and every cross-team claim remains traceable to named solution blocks
- the transition into the individual solution reference section is explicit rather than accidental
- the deck works in grayscale because structure and labels carry meaning
- claims include evidence, mechanism, or a decision consequence rather than only slogans

Fix, recompile, rerender, and inspect until the full-resolution pages and contact sheet both pass.

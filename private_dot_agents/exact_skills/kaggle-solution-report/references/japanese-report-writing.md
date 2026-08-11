# Japanese explanatory report writing

This contract adapts the relevant rules from `japanese-tech-generation` for new drafting and `japanese-tech-writing` for revision. `kaggle-solution-report` remains the task entrypoint. Do not activate both writing workflows merely because the output language is Japanese.

## Contents

1. Phase routing
2. Reader and terminology contract
3. New-draft workflow
4. Existing-draft workflow
5. Paragraph and section rules
6. Evidence and uncertainty
7. Source-format rules
8. Completion checks

## Phase routing

Choose one mode for the current manuscript operation:

- **New-draft mode:** use for a new organized solution file, synthesis section, report chapter, or slide narrative written from collected evidence.
- **Revision mode:** use only when the user asks to rewrite an existing manuscript or when concrete review feedback identifies prose to change.

Do not automatically apply revision mode after new-draft mode. Generic second-pass rewriting often removes evidence boundaries, changes technical meaning, or creates unsupported causal claims.

If the requested change would alter the required report sequence, move claims between evidence categories, or restructure the argument beyond local sections, confirm that this broader rewrite is intended. Otherwise preserve section order and claim scope.

Raw discussion files are never manuscripts. Preserve them verbatim according to the raw evidence contract and never apply either mode to their quoted bodies or comments.

## Reader and terminology contract

Before drafting, complete the reader and terminology tables in `scope/scope.md`.

The reader contract must state:

- who the intended reader is
- why they will read the report
- what kind of document this is
- what prior knowledge may be assumed
- which concepts must be explained rather than named

For each central term, decide whether the reader already knows it, define it at first use when necessary, and record the later comparison or decision it supports. Do not introduce a term that is never used downstream.

Use one stable term for one concept. Prefer Japanese prose terms such as `解法` consistently, while keeping source identifiers and established technical names such as `GroupKFold`, `ImagePositionPatient`, `log loss`, and `OOF` exact. Define unfamiliar English terms in Japanese at first use.

## New-draft workflow

Do not begin by listing conclusions. First establish the observations and constraints that make the conclusion understandable.

For every paragraph, decide before writing:

1. **Receive:** the unresolved point inherited from the previous paragraph.
2. **Advance:** the one claim this paragraph establishes.
3. **Hand off:** the question or consequence the next paragraph receives.

For analytical passages, prefer this progression:

`task/data/metric observation -> failure mode or incentive -> solution evidence -> mechanism -> decision or implication -> uncertainty`

The full chain may span several paragraphs, but each paragraph must advance exactly one link. Equations, theory, diagrams, examples, and code samples belong only when they help the reader make a later comparison, understand a mechanism, or reproduce a calculation.

After the first draft, remove repetition, empty emphasis, unsupported assertions, and forward references that are never resolved. The summary must be derived from the body rather than introduce a new conclusion.

## Existing-draft workflow

Freeze the edit scope before rewriting:

- surface wording only
- sentences and paragraphs
- headings and local sections

Unless the user requests broader restructuring, default to sentences and paragraphs. Preserve verified claims, evidence status, citations, section order, numerical values, and technical identifiers.

Do not add unverified facts, causal explanations, numerical gains, reader personas, or recommendations. Do not convert `参加者報告` or `考察` into a confirmed fact. Compare the revised text against the organized solution files, comparison matrix, and evidence ledger before accepting it.

Editing should make the mechanism explicit without changing it. Repair undefined terms, overlong sentences, mixed topics, ambiguous antecedents, and duplicated conclusions. Keep the original level of uncertainty.

## Paragraph and section rules

- Use one topic and one main claim per paragraph.
- Start a paragraph from the unresolved point left by the previous paragraph; do not restart the subject without a bridge.
- Give sections headings that name the question or analytical target, not merely a vague theme.
- Keep examples and quoted evidence adjacent to the claim they support.
- Use a theory or formal framework only if it changes a later interpretation or decision.
- Avoid rhetorical questions, decorative metaphors, repeated conclusion statements, and exaggerated emphasis.
- Avoid empty phrases such as `重要なのは`, `多角的に`, `正面から`, and `深掘りする` when the following sentence can state the concrete claim directly.
- Use parentheses or a separate sentence for parenthetical explanation; do not use Japanese dashes as generic brackets.

The mandatory report section order remains defined in `typst-output.md`. These prose rules organize reasoning inside that structure; they do not replace it.

## Evidence and uncertainty

Keep the evidence status visible in prose and captions:

| Evidence status | Japanese wording | Writing rule |
|---|---|---|
| participant-reported | 参加者報告 | Attribute the claim to the participant or team. |
| directly-observed | 直接確認 | State what artifact or output was inspected. |
| inference | 考察 or 推論 | Give the reasoning chain and preserve alternatives. |
| unavailable | 未取得 | State the gap; do not fill it from rank or convention. |
| independently-reproduced | 独立再現 | Name the reproduction setting and result. |

Do not smooth over missing evidence to improve narrative flow. A limitation can be the hand-off to the next paragraph or the explicit end of a claim.

## Source-format rules

- In organized and synthesized Markdown, write one sentence per source line and leave one blank line between paragraphs.
- In Typst, leave a blank line between paragraphs and keep the source readable; do not force a manual line break after every Japanese sentence.
- Preserve code, equations, labels, ranks, scores, and citations exactly unless the source contract explicitly requires a translated representation.
- Mark reconstructed pseudocode, derived equations, and editorial diagrams as reconstructed or author-created.
- Never run prose normalization over raw discussion bodies or comments.

## Completion checks

Before accepting Japanese prose, confirm all of the following:

- The intended reader and assumed knowledge are explicit.
- Every specialized term is either assumed known or defined at first use.
- Every paragraph receives a prior issue, advances one claim, and hands off a consequence or closes it explicitly.
- Every example, equation, diagram, and code sample answers the same question as its surrounding claim.
- Every causal-looking statement follows the mechanism chain and retains its evidence status.
- Revision has not changed verified facts, citations, numerical values, or uncertainty.
- The summary contains no claim absent from the body.
- Empty emphasis and unused concepts have been removed.

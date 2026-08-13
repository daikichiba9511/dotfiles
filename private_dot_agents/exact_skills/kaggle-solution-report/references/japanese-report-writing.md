# Japanese explanatory report writing

This contract adapts the relevant rules from `japanese-tech-generation` for new drafting and `japanese-tech-writing` for revision. `kaggle-solution-report` remains the task entrypoint. Do not activate both writing workflows merely because the output language is Japanese.

## Contents

1. Phase routing
2. Reader and terminology contract
3. Engineer-facing prose contract
4. New-draft workflow
5. Existing-draft workflow
6. Paragraph and section rules
7. Evidence and uncertainty
8. Source-format rules
9. Completion checks

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

For a Kaggler audience, established machine-learning vocabulary such as `OOF`, `CV`, `log loss`, and `noise filtering` may be assumed when the reader contract says so. Do not spend space defining these terms mechanically. Explain what a team-specific expression means and what was actually compared: `OOF` may be known, while `team OOF` still requires a sentence stating which models were averaged and how the value was used.

When the intended reader has Kaggle experience but did not enter the competition, assume ordinary ML and competition vocabulary but never assume knowledge of the task schema, target relationships, organizer-specific rules, team shorthand, or competition-specific postprocessing. A familiar word such as `constraint`, `calibration`, `adapter`, or `projection` still needs a concrete explanation when its meaning depends on this competition. At first use, state the affected inputs or predictions, the exact operation or relationship, where it occurs in training/validation/inference, and why it changes the decision.

Do not juxtapose two task-specific operations with a connective such as `一方` or `両立する` before explaining their difference. For example, before saying that a team rejected a training constraint but used inference-time consistency, name the constrained equations, explain that the former adds a penalty while fitting model parameters, and explain that the latter changes only the five predictions after inference. If this bridge does not fit legibly, add a paragraph or slide; page count is not a compression target.

Use one stable term for one concept. Prefer Japanese prose terms such as `解法` consistently, while keeping source identifiers and established technical names such as `GroupKFold`, `ImagePositionPatient`, `log loss`, and `OOF` exact. Define unfamiliar English terms in Japanese at first use.

Before drafting slides, add a terminology ledger to the working notes with these columns:

| concept | canonical wording | first-use definition | rejected aliases |
|---|---|---|---|

Audit the complete deck against this ledger after drafting. Do not use two surface forms merely because both appeared in source discussions. For example, choose `損失値が大きい学習例` and reject later variants such as `high-loss sample`, `高lossのsample`, and `高loss例`.

Team-specific shorthand is not shared vocabulary. Expand expressions such as `team OOF`, `confident disagreement`, a private branch name, or a repository variable name into a complete description on first use. Keep the shorthand only in parentheses when it is useful for tracing the source. Established field terms such as `noise filtering`, `OOF`, `log loss`, and `temperature scaling` may remain when the reader contract assumes them, but their role in the particular experiment must still be stated.

Introduce a task-specific abstraction only after describing its concrete operation. The first-use sentence should name the input, the action, and the output before assigning a shorter label. For example, write `病変を分類する前に、対象の椎間レベル、slice、XY座標を画像から求める。この処理を位置推定と呼ぶ` before using `位置推定` alone. Prefer the ordinary reader-facing term `位置推定` to a source-derived term such as `局在推定` unless the latter names a distinct concept that must be preserved.

Distinguish related terms by conceptual level instead of alternating them casually. Keep `log loss` when naming the established metric, use `損失関数` for the training objective, `損失項` for one component of an aggregate metric, and `損失値` for the numerical value assigned to one example or prediction. Do not use bare `loss`, `高loss`, and `損失値` for the same quantity across different slides.

## Engineer-facing prose contract

Aim for the clarity of a well-edited Japanese engineering book, not for imitation of a named writer's personal voice. The prose should let a working engineer recover the data structure, failure mechanism, implementation choice, and evidence without translating the manuscript mentally.

Use Japanese as the grammatical skeleton of every explanatory sentence. Keep exact identifiers, API names, architecture names, metric names, and short terms that the reader must search for. Translate generic English nouns when the English form adds no precision:

| Avoid as ordinary prose | Prefer in Japanese prose |
|---|---|
| model / classifier / class | モデル / 分類器 / クラス |
| target / sample / label | 予測対象 / 学習例 / ラベル |
| pipeline / branch | 処理構成 or 処理経路 / 予測経路 |
| fold / validation | 分割 / 検証 |
| view / level | 撮像断面 / 椎間レベル |
| crop / fallback | 切り出し画像 or ROI / 代替経路 |

Terms that mirror the competition schema, such as `series`, `slice`, `study_id`, SCS, NFN, and SS, may remain exact after their Japanese meaning is defined once. Do not alternate casually between Japanese and English forms after choosing a term.

Prefer concrete subjects and actions. Write who or what selects a series, predicts a coordinate, creates an ROI, aggregates slices, or calibrates probabilities. Avoid nominal strings that force the reader to infer the relation, such as `局在・分類pipelineのgeometry分岐`. Replace them with a sentence such as `Sagittalで求めた位置を患者座標へ写し、対応するAxial sliceを選ぶ`.

Do not compress evidence into unexplained noun chains to save slide space. `強いteam OOFのconfident disagreement` is not an explanation. State the actor, comparison, threshold, and action when the source provides them: `2位チームは、複数モデルを平均したOOF予測と正解ラベルを比べ、両者の差が0.8以上の学習例を除外した`.

Keep the subject close to the predicate when a sentence contains several technical modifiers. Split a sentence when it contains two independent causal relations. Use a new paragraph when the evidence boundary changes from direct observation to participant report or inference.

Introduce formal material in reading order:

1. State what quantity the equation or table answers.
2. Define symbols and units in the order they appear.
3. Show the Typst-native equation or compact comparison.
4. Interpret one term or one numerical example in prose.
5. State the resulting modeling or validation decision.

Do not let an appendix become a parts catalog. Even in per-team summaries, connect the end-to-end input path to the failure it addresses, then separate reported gains, negative results, and missing reproduction details.

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

Run a dependency test on every revised explanation: could a reader who knows general ML but has not read the competition rules recover what each task-specific noun refers to and why the next sentence follows? If not, add the missing schema fact, equation, operation, or contrast before polishing the wording. Replacing English nouns with Japanese nouns does not repair a missing logical link.

## Paragraph and section rules

- Use one topic and one main claim per paragraph.
- Start a paragraph from the unresolved point left by the previous paragraph; do not restart the subject without a bridge.
- Give sections headings that name the question or analytical target, not merely a vague theme.
- Keep examples and quoted evidence adjacent to the claim they support.
- Use a theory or formal framework only if it changes a later interpretation or decision.
- Avoid rhetorical questions, decorative metaphors, repeated conclusion statements, and exaggerated emphasis.
- Avoid empty phrases such as `重要なのは`, `多角的に`, `正面から`, and `深掘りする` when the following sentence can state the concrete claim directly.
- Use parentheses or a separate sentence for parenthetical explanation; do not use Japanese dashes as generic brackets.

These prose rules organize reasoning inside the report structure selected by `SKILL.md`; they do not replace that structure.

For public slides, apply the separate page contract during slide composition. This writing contract controls the Japanese expression inside that structure: the title and claim must state a concrete subject and conclusion without unexplained counting labels such as `五つの判断` or noun chains such as `構造的な差`.

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
- Japanese forms the sentence skeleton; untranslated English remains only where it preserves an exact identifier, search term, or established technical meaning.
- Generic nouns such as model, class, target, pipeline, branch, fold, sample, view, and level are not mixed arbitrarily with their Japanese equivalents.
- Team-specific shorthand and source-local variable names are expanded before use.
- The same concept has one canonical wording across titles, claims, prose, diagrams, tables, and supplements.
- Task-specific abstractions are introduced only after a sentence names their input, action, and output.
- A reader who knows general ML but not the competition can explain what every competition-specific transformation changes and at which pipeline stage it happens.
- Contrastive sentences such as `Xは不採用だがYは採用` define X and Y before drawing the contrast.
- Every slide's title and claim state a concrete subject and conclusion without unexplained counting labels or noun chains.
- Equations and tables are introduced, interpreted, and connected to a decision in prose.

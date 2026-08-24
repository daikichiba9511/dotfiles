# Kaggle adapter for topic-learning-slides

Apply this reference after the general `topic-learning-slides` argument and checkpoint workflow. It adds competition-specific team coverage, factor synthesis, discovery reconstruction, and ranked solution-reference requirements. When a rule is not Kaggle-specific, follow the general Skill rather than duplicating a second narrative contract here.

## Contents

1. Purpose and abstraction
2. Analysis order and reading order
3. Two-pass synthesis
4. Discovery reconstruction
5. Slide narrative
6. Explanation depth
7. Required story types
8. Transfer map
9. Audit checklist

## Purpose

A public solution deck should leave the reader with a way to notice, test, and reuse an idea in a later competition. It is not a shorter report, a leaderboard recap, or a list of model names.

This contract was abstracted from the publicly visible YumeNeko corpus checked on 2026-08-11:

- Speaker Deck profile and all four visible decks: `https://speakerdeck.com/yumeneko`
- Zenn profile and all thirteen visible articles: `https://zenn.dev/yume_neko`
- especially the competition-retrospective talk, the Benetech competition story, the Benetech data-centric talk, the IMC 2025 retrospective, and the RSNA 2024 solution summary

Copy the reasoning structure, not the author's visual density, table frequency, wording, or branding. Preserve this Skill's own restrained Typst design system.

## The abstraction

The recurring useful structure is:

1. make the task concrete with an input, output, metric, or failure example;
2. show the author's or a simple baseline pipeline before discussing top solutions;
3. show a cross-team map of the main bottlenecks, solution families, and relationships before asking the reader to absorb long team histories;
4. treat widely shared factors as minimum conditions for competing, not as proof of what separated ranks;
5. identify distinctive factors and compare them against a control, counterexample, or alternative explanation;
6. reconstruct how a participant could have noticed the clue during the competition;
7. show the cheapest experiment that could accept or reject the hypothesis;
8. include failed ideas, non-reproduced gains, and reasoning turns;
9. give the reusable idea inventory, decision order, transfer boundary, and evidence limits;
10. finish with complete team-by-team solution blocks so the reader can inspect the concrete evidence behind the abstraction.

The causal unit of explanation is not a technique name. It is this chain:

`observable clue -> failure hypothesis -> intervention -> controlled result -> decision -> transfer boundary`

For example, `offset crop augmentation` is incomplete. A useful explanation says that predicted coordinates create a train/inference crop gap, specifies how to measure that gap, compares a fixed classifier on ground-truth and out-of-fold predicted crops, and states when offset training should be adopted.

## Analysis order and reading order

Do not equate the order used to build the evidence with the order offered to the reader.

- **Analysis order:** complete the team-centric pass first, then derive factor-centric claims. This prevents incompatible branches from being merged into a fictitious solution.
- **Reading order:** normally present the factor-centric overview before the detailed team blocks. Let the reader first understand the solution space, relationships, exceptions, and reusable decisions, then inspect individual implementations as evidence-bearing references.

The abstract section must stand on its own. Define the task-specific bottleneck, name the solution families that address it, distinguish shared conditions from rank differentiators, retain counterexamples and uncertainty, and identify the supporting ranks or teams. Do not rely on phrases such as `as shown earlier` when the detailed solution appears later.

The individual solution section must also stand on its own. Preserve each real end-to-end topology, central decision, evidence status, and unknown. Do not let the early abstraction replace these blocks or introduce a blended pipeline that no team actually built. When navigation is useful, end the abstract section with one sentence explaining that the following pages are ranked solution references.

## Two-pass synthesis

### Pass A: team-centric

For every method-bearing team, preserve:

- the end-to-end pipeline;
- the bottleneck the team appears to prioritize;
- the decisive mechanism, not only the component name;
- the reported validation setting and gain;
- evidence gaps and participant-only claims.

This pass prevents factor summaries from combining incompatible components into a fictitious solution.

Complete this pass before composing the abstract-first reader narrative, even though its slides are rendered later in the deck.

In slides, give every method-bearing gold team a recognizable ordinal heading such as `1st solution:`, `2nd solution:`, and `11th solution:`. Do not use `Rank 1:` or `Rank 11:` as the team-solution heading. The ordinal identifies the competition placement in the form commonly used by Kaggle solution write-ups; the text after the colon states the specific subject of that page. Upper-silver teams remain fully represented in organized Markdown and factor-level synthesis; give them individual slide blocks only when the user asks.

Start each method-bearing gold-team block with that team's own whole-solution figure. Apply the semantic and topology contract in `diagram-design.md`; this is a pipeline overview, not a row in a cross-team comparison. Reuse the shared rendering derived from the organized semantic topology rather than inventing a second simplified architecture for the deck.

Do not reduce a gold team to one memorable trick. For each method-bearing gold team, allocate enough pages to explain at least:

1. the end-to-end path from competition input to final probabilities;
2. the central modeling or data decision and the failure it addresses;
3. the validation result, reported gain, negative result, or evidence gap that determines how strongly the idea should be trusted.

Two pages per team are a useful default: `Nth solution: <team>の全体像` followed by `Nth solution: <central decision>`. Use a third page when the solution has another independent mechanism or experiment that cannot be understood as a detail of the first two. Page count is not a reason to collapse the pipeline into a component list.

Use `synthesis/publication-evidence.csv` as the completeness boundary. A team block is complete only when all of its core rows have named slide locations and its supporting rows are included, placed in a factor-level slide, or excluded with a specific reason. When raw evidence contains several independent failures, validation turns, or mechanisms, add pages as needed; the two-page pattern is a starting point, not an upper bound.

The overview should normally fit on one slide at the minimum permitted diagram-label size. If the real topology cannot fit legibly, keep a compact whole-solution map and add one or more zoomed continuation slides for coherent branches. Split by an actual boundary such as member path, imaging view, training/inference phase, or ensemble stage; never split at an arbitrary horizontal coordinate. The following team pages carry the prose explanation, mechanism, and evidence, so do not crowd the overview with paragraphs that merely repeat node labels.

### Pass B: factor-centric

Reorganize the same evidence around the task's bottlenecks:

- common entry conditions across method-bearing top teams;
- alternatives that solve the same bottleneck differently;
- factors enriched in the highest ranks;
- exceptions and negative evidence;
- factors that cannot be compared because publication coverage differs.

Do not call a frequent element a differentiator merely because it appears in winning solutions. A common element is usually an entry ticket. A differentiator needs a contrast, a mechanism, and enough evidence to survive confounders such as team size, compute, or missing write-ups.

Use this pass to build the first reader-facing synthesis. A relationship map should show which bottleneck each solution family addresses, which teams exemplify it, where strategies combine or diverge, and which counterexample limits the conclusion. It is an index into the later team blocks, not a substitute for them.

## Discovery reconstruction

For every central learning, fill this card before making slides:

| field | required question |
|---|---|
| Observable clue | What could be seen in the rules, schema, EDA, metric, OOF errors, logs, or runtime before reading the final solutions? |
| Failure hypothesis | What concrete failure process could produce that clue? |
| Cheapest test | What is the smallest controlled comparison that distinguishes this hypothesis from the main alternative? |
| Result | What measured or participant-reported evidence exists, and under what fixed conditions? |
| Decision | What result would make us adopt, reject, or defer the idea? |
| Reusable heuristic | What should the reader inspect first in a later task? |
| Transfer boundary | Which part is domain-specific, dataset-specific, or still uncertain? |

Do not silently fill missing fields with hindsight. Use `unknown`, `participant-reported`, `inference`, or `not independently reproduced` as appropriate.

## Slide narrative

Build a learning arc, not a report table of contents. A strong default sequence is:

1. **Reader question:** what will this retrospective help the reader decide next time?
2. **Concrete task:** one representative input-to-output path.
3. **Metric and data pressure:** one property per slide, with an equation, count, or example.
4. **Naive baseline:** the simplest plausible pipeline and where it fails.
5. **Solution-space overview:** relate the main bottlenecks to the solution families and name the teams that exemplify each response.
6. **Top-field entry ticket:** the common pipeline or principle and why it fits the task.
7. **Bottleneck map:** where errors enter, how they propagate to the metric, and where solution families intervene.
8. **Rank difference:** what the top group added beyond the entry ticket, with counterexamples and confounders stated.
9. **Worked success story:** clue, hypothesis, test, reported result, decision.
10. **Negative or non-reproduced story:** plausible idea, failed evidence, revised rule.
11. **During-competition playbook:** ordered measurements and decision gates.
12. **Transfer map:** general principle, task-family adaptation, and domain-specific detail.
13. **Coverage and evidence limits:** state which ranks and factors can support the synthesis.
14. **Individual solution references:** preserve every method-bearing gold solution end to end in rank order; add requested upper-silver blocks after Gold.

Page count may grow. Split a reasoning chain across slides whenever a reader would otherwise have to infer a missing step.

## Explanation depth

Use this reference to decide what the narrative must explain. The page structure and visual roles are applied separately during the slide-design phase.

Across the deck, distinguish four questions explicitly: what the team built, why it should work, what evidence supports it, and how the reader could have discovered it. A pipeline diagram answers only the first question; give mechanism, evidence, and discovery their own explanation when they need space.

Use progressive disclosure for unfamiliar mechanisms. One slide may establish the failure, the next the intervention, and the next the result. Do not compress all three into a dense grid simply to reduce page count.

Progressive disclosure also applies to language. Describe the concrete operation before shortening it to a task-specific term. The title and claim must be readable without reconstructing an unstated taxonomy: a count such as `五つの判断` is useful only when the five items are themselves the subject and are explicitly named. Otherwise state the actual failure or decision, such as `series、椎間レベル、slice、XY座標のどれかを誤ると、分類器は病変を見られない`.

Do not compress team-specific evidence into source shorthand. A slide must explain what an OOF prediction contains, what two quantities were compared, which threshold or criterion selected examples, and what happened after the intervention whenever the source reports those details. General technique names may remain concise; experiment-specific operations require complete sentences.

## Required story types

When evidence permits, the deck must contain:

- one concrete metric example showing how an error changes score;
- one baseline-to-top contrast;
- one cross-team relationship map that is understandable before the individual solution blocks;
- one complete pipeline for every method-bearing gold solution in the later reference section;
- one common-element explanation framed as an entry condition;
- one top-rank differentiator with an explicit confounder;
- one worked positive experiment with a numeric result;
- one failed, rejected, or non-reproduced intervention;
- one slide that names the clue available before the competition ended;
- one final checklist that can be applied without remembering team or model names.

## Transfer map

End by separating three levels:

1. **General principle:** for example, measure train/inference skew at pipeline boundaries.
2. **Task-family adaptation:** for example, compare oracle and predicted regions in weakly localized 3D classification.
3. **Competition-specific implementation:** for example, map Sagittal and Axial MRI through DICOM patient coordinates.

This prevents the reader from copying a Kaggle-specific recipe while missing the general idea.

## Audit checklist

Before release, answer yes or no:

- Can the reader state the task and metric failure mode after the opening slides?
- Can the reader explain the main solution families, their relationships, and their counterexamples before reaching the individual solution section?
- Does every abstract factor name the ranks or teams that support it and point naturally to a later solution block?
- Can the reader state what each slide is about and what it claims after reading only the title and claim?
- Are task-specific terms introduced through their input, operation, and output before their shortened form is used?
- Is there a simple baseline against which the top pattern is meaningful?
- Are solution components tied to the failure they address?
- Does every method-bearing gold team use an `Nth solution:` heading and retain its end-to-end pipeline, central decision, and evidence status?
- Does every method-bearing gold team have its own legible whole-solution figure rather than being represented only in a cross-team comparison?
- Do the report and slide versions of each pipeline preserve the same nodes, edges, branches, and unknowns?
- Is every central learning backed by a clue and a discriminating test?
- Are common factors separated from rank differentiators?
- Are counterexamples, failed ideas, and publication gaps visible?
- Are participant-reported gains labeled with their validation setting?
- Does the deck show what to measure before recommending what to build?
- Does the final playbook contain decision gates rather than a shopping list?
- Does the transfer map distinguish general, task-family, and competition-specific knowledge?
- Would the cross-team relationship map and the most important team pipeline remain memorable after viewing the full deck?
- Does every core publication-evidence row appear on a named slide?
- Can every excluded supporting item be defended as redundant, incidental, inaccessible, or outside the reader contract?
- Did every linked technical artifact reach an inspected, unavailable, or not-material decision?

If more than two answers are no, revise the narrative before working on layout or color. Run the separate visual QA during the slide-design phase after the narrative passes.

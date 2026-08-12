# Independent release review

Use this review after a full report run or a broad revision. It is a release gate, not a changelog and not a substitute for deterministic validation.

## Review protocol

Keep reviewers read-only and partition them by failure axis. Do not ask several reviewers to perform the same vague whole-document review. When subagents are available, assign these scopes independently:

1. evidence and technical accuracy;
2. Japanese terminology and explanation quality;
3. rendered report and slide geometry;
4. report/slide claim, terminology, evidence, and pipeline parity.

The main workflow owns all edits. After accepting a finding, fix the organized solution and its semantic topology first, update the shared Typst rendering when needed, propagate it to report and slides, recompile, rerender, and ask the affected reviewer for a focused recheck. High- and medium-priority findings must be fixed or explicitly rejected with evidence before release.

## Evidence and technical accuracy

Check every material claim against the paired raw and organized files, not only against the report prose.

- Team, final rank, medal band, and source ownership are correct.
- Participant reports, organizer facts, direct inspection, inference, and unavailable evidence remain distinct.
- Thresholds, weights, scores, split names, Public/Private Leaderboard values, and ablations retain their original setting.
- A missing coefficient or implementation detail does not turn a known threshold into an unknown one.
- One member's branch, metric, or negative result is not silently generalized to the whole team.
- Observed failures are attributed to the correct method; similar mechanisms are not swapped between keypoint, segmentation, rules, and classification paths.
- Every numerical comparison names baseline, intervention, metric, evaluation split, and evidence status when available.
- Common factors, rank differentiators, and causal explanations retain counterexamples and confounders.

## Japanese terminology and explanation

Read titles, claims, prose, equations, captions, diagrams, and appendices as one terminology surface.

- One concept uses one canonical expression after first use.
- Team-specific shorthand is expanded before abbreviation; ordinary Kaggler terms may remain assumed knowledge according to the reader contract.
- Concrete input, action, and output precede task-specific abstractions such as position estimation.
- Japanese carries the grammar; generic English nouns and unexplained noun chains do not replace sentences.
- `log loss`, training objective, loss term, and per-example loss value are not conflated.
- Disease type, left/right target, vertebral level, series, slice, coordinate, and ROI are named at the correct conceptual level.
- Prose does not compress a causal relation into labels such as `five decisions`, `geometry branch`, or `confident disagreement`.
- Each paragraph advances one claim, and participant report and editorial interpretation occupy separate sentences or paragraphs.
- Typst equations define symbols in reading order and contain no pasted LaTeX syntax.

## Rendered geometry

Inspect every page at full resolution and the full deck as a contact sheet.

- Text, arrows, arrow labels, and node labels do not overlap, clip, or leave their containers.
- Diagram labels and explanatory prose meet the minimum type sizes.
- Prose-only slides have a readable line length, paragraph spacing, and balanced vertical placement.
- Color marks one semantic focus; repeated accents, oversized facts, takeaway bars, and decorative panels do not compete with real mechanisms.
- Tables appear only where aligned repeated fields improve comparison; no numeric table quota is enforced.
- Quiet, support, and hero pages create deliberate visual rhythm; the important process overviews remain memorable in the contact sheet.

## Report and slide parity

Compare the organized semantic topology, shared Typst rendering, report, and slides.

- Every method-bearing gold team has its own whole-solution overview figure in report and slides.
- Each pipeline preserves actual inputs, branches, coordinate/ROI transfers, convergence, final integration, and explicit unknowns.
- A cross-team comparison figure is not used as a substitute for per-team architecture.
- Report and slide versions preserve the same topology, terminology, source ownership, and uncertainty.
- Team pages use `Nth solution:` headings, and following pages explain the mechanism and evidence rather than merely restating node labels.

## Release decision

Record findings with severity, artifact, location, evidence, disposition, and a concrete correction in `<workspace>/reviews/release-review.md`. Never append competition-specific findings to this Skill reference. Release only when:

- no unresolved high- or medium-priority finding remains;
- deterministic workspace validation and both Typst compilations pass after the final edit;
- every report and slide page has been rerendered and inspected after the final meaningful change.

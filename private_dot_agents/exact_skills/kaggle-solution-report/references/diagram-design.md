# Typst diagram and plot contract

## Contents

1. Choose the drawing abstraction
2. Build per-solution overview figures
3. Encode meaning
4. Route edges and labels
5. Fit text inside nodes and callouts
6. Visual QA

## 1. Choose the drawing abstraction

Choose the tool from the relationship to explain:

- **Fletcher:** pipelines, branching decisions, converging ensembles, dependency graphs, and error propagation through named nodes and edges.
- **CeTZ:** spatial or anatomical schematics, coordinate transforms, crop geometry, slice stacks, custom annotations, and figures requiring precise placement.
- **CeTZ-Plot:** measured bars, distributions, curves, and charts. Never invent synthetic plots as decoration.
- **Native Typst:** a simple pair, exact number, equation, or small multiple that does not need routed edges or coordinates.

Verify the current package versions and compiler requirements on Typst Universe, then pin the working versions in `.typ` source.

## 2. Build per-solution overview figures

For every method-bearing gold team, create a dedicated whole-solution figure before building cross-team comparison graphics. Use the organized solution's canonical topology and show, when the source exposes them:

1. competition inputs and imaging views;
2. slice, keypoint, detector, coordinate, ROI, or feature construction;
3. condition-, view-, member-, or model-specific branches;
4. classification or sequence aggregation;
5. branch convergence, ensembling, calibration, and postprocessing;
6. training-only filtering, pseudo-labeling, or pretraining when it changes the final models.

The goal is recognition at a glance, not visual uniformity across ranks. Do not force all teams into one generic left-to-right strip when the method contains parallel member routes, feedback, cross-view mapping, or disease-specific heads. Use group containers for meaningful systems or phases, not for decoration. Label unavailable connections or mixing weights explicitly and stop the edge rather than completing it by inference.

Keep exactly one shared Typst rendering source at `figures/gold-pipelines.typ`. Define one function per method-bearing gold team as `gold-pipeline-<rank>-<team-slug>`, for example `gold-pipeline-1-avengers`. The rank-plus-slug identity remains unique even when displayed ranks tie. Import that function and the bundled `rendered-gold-pipeline` wrapper into both artifacts. Render only as `#rendered-gold-pipeline("gold-pipeline-<rank>-<team-slug>", <gold-pipeline-<rank>-<team-slug>>, gold-pipeline-<rank>-<team-slug>(...))`; the fixed wrapper emits the invisible validation marker and its visual in the same block. Final validation queries the marker from the document tree and rejects a naked marker or a team function call hidden elsewhere. The organized Markdown topology record is the semantic source of truth; update it before changing this rendering. The two renderings may pass different layout primitives, rearrange coordinates, and shorten label wording, but must preserve every material node, edge, branch condition, source ownership, and uncertainty.

For a gold team whose processing path is unavailable, do not emit a pipeline marker or guessed figure. Put `=== 公開情報の限界` in that team's report subsection and wrap the explanation as `#rendered-gold-unavailable("gold-unavailable-<rank>-<team-slug>", <gold-unavailable-<rank>-<team-slug>>, [explanation])`. Report and slide sources must never call `metadata` directly; only the two fixed wrappers in the canonical shared source may emit release markers.

Final report and slide sources must not call `gold-pipeline-placeholder`, hide required calls under `#if false`, or define a rank function as `none`, an empty body, or a placeholder alias. The placeholder exists only to make the untouched starter template compile; replace it before final validation.

Fit the complete map on one slide when it remains legible. If it does not, keep a structurally complete overview on the first page and add zoomed views of coherent branches. Simplification may shorten labels and rearrange geometry; it may not remove a material node, branch, edge, or unknown. Never reduce text below the slide contract or turn the map into a comparison table merely to force one page.

## 3. Encode meaning

Create a diagram only when it makes sequence, branch, convergence, coordinate mapping, uncertainty propagation, repeated neighborhood, or evidence completeness easier to see than prose. Use one accent meaning throughout the figure, such as `position error`, instead of coloring nodes by identity.

Keep a diagram focused on one question. Do not make one pipeline stand in for what was built, why it should work, what evidence supports it, and how it could have been discovered; split those explanations when needed.

## 4. Route edges and labels

Treat an edge label as part of the topology. Put only a short relation of one to four words directly on an arrow. Put a longer condition, failure description, or consequence in a separate callout above or below the edge, connected by a leader line, or model it as its own node.

Reserve visible clearance between labels, callouts, edges, arrowheads, and node boundaries. If a label touches, crosses, or is hidden by a node, redraw the topology or add space. Never solve a collision by shrinking type.

When flow and explanation compete for the same space, use two visual layers—for example, a neutral process row and an annotated failure row.

## 5. Fit text inside nodes and callouts

CeTZ `rect` and separate `content` calls do not create an automatically constrained layout box. A correct center coordinate does not prevent text from crossing the rectangle.

For each custom node or callout:

1. design a text area smaller than the rectangle;
2. set deliberate line breaks for multi-line labels;
3. position the lines explicitly when automatic layout is unreliable;
4. leave visible padding on all four sides;
5. enlarge the rectangle or simplify wording before reducing type size.

Inspect mixed Japanese and Latin labels in the rendered image; source length does not predict Japanese line breaking reliably.

## 6. Visual QA

Inspect every diagram on a full-resolution slide and again in the contact sheet. Check:

- titles do not collide with body text
- all text remains inside rectangles with padding
- labels and callouts do not touch node boundaries
- edge labels and arrowheads are not hidden beneath nodes
- line crossings are necessary and unambiguous
- reading order remains clear in grayscale
- no diagram creates an accidental continuation page
- plots show only measured values and label units, axes, conditions, and evidence source
- every method-bearing gold team has its own source-backed whole-solution figure
- the report and slide renderings preserve the same topology and unavailable links
- the team can be identified from the pipeline structure without relying only on the rank label

Fix the topology, geometry, or wording before accepting a smaller font.

# Typst and Polylux deck contract

## Output

Create a 16:9 Typst deck with Polylux and `metropolis-polylux`. Use the bundled theme as a starting point. Prefer these fonts when installed:

- Japanese: `BIZ UDPGothic`
- math: `New Computer Modern Math`
- code: `HackGen35 Console NFJ`

If a font is missing, choose an installed Japanese font and record the substitution. Never accept missing-glyph boxes.

## Page contract

Each substantive slide has:

1. a concrete title naming the subject or question;
2. one claim the reader should retain;
3. enough explanation to connect premise, mechanism, evidence, and limitation;
4. at most one main representation when it materially improves understanding.

Prose-only slides are valid. Do not add diagrams, icons, cards, or large numbers merely to fill space. Do not optimize for a target page count.

## Visual roles

Assign one role before layout:

| role | purpose | treatment |
|---|---|---|
| context | definitions, scope, connective reasoning | restrained prose |
| mechanism | causal path, topology, interaction | dominant diagram or example |
| evidence | exact comparison, equation, measurement | compact representation plus explanation |
| comparison | aligned alternatives or repeated fields | symmetric examples or table |
| counterexample | limit or failure | evidence first, warning only when necessary |
| decision | ordered checks or experiment gates | sequence with explicit conditions |
| reference | detailed case or source-specific implementation | complete but visually quieter |

Use one semantic accent plus neutrals. Color marks a selected value, bottleneck, changed variable, error path, or decision. Structure and labels must still work in grayscale.

## Typography and density

- Use approximately 28–30 pt for the title slide and the Metropolis heading scale for content titles.
- Use 15–17 pt for analytical prose.
- Use 12–14 pt for diagram labels and necessary tables.
- Reserve 8.5–9.5 pt for citations and footers.
- Never shrink analytical prose below 14.5 pt or diagram labels below 11 pt to fit.
- Prefer a few large blocks; more than three peers usually weakens hierarchy.
- Keep prose lines short enough to read without scanning the full canvas width.

Split a slide when the reader would otherwise infer a missing operation, comparison, or transition. A clean but semantically incomplete page fails.

## Representations

Use:

- a diagram for relationships, pipelines, branching, feedback, or state changes;
- a table for aligned repeated fields;
- an equation when the symbols and numerical consequence matter;
- an example when an abstract definition needs a concrete instance;
- a timeline or ordered steps when sequence is the claim.

Every factual representation receives a nearby source marker in the form `[S-012]`. The ID must match `research/source-ledger.csv`. Define one reusable Typst marker helper, use the ID beside the claim or representation, and add a final `出典一覧` appendix with the same ID, title, stable URL or path, inspected scope, retrieval date, and material limitation. Label inference and author-reported results explicitly. Redraw copyrighted figures from verified facts instead of copying them without permission.

## Narrative rhythm

The contact sheet should make the broad issue map and a few decisive mechanisms memorable. Use quiet context pages around evidence and mechanism peaks. Do not let detailed reference pages visually outweigh the central argument.

Omit agenda and section-divider pages by default. Add navigation only when a long deck needs a clear transition, especially from the abstract section to detailed references.

## Compile and inspect

Compile from the workspace root:

```bash
mise exec -- typst compile --root <workspace> <workspace>/slides/slides.typ <workspace>/slides/slides.pdf
```

If the workspace does not use mise, use its pinned Typst command and record the version.

Render every page under `reviews/renders/`, and keep contact sheets in the same directory. Inspect:

- titles, claims, prose, labels, sources, and footers at full resolution;
- clipping, overlap, overflow, accidental continuation pages, and isolated one-character wraps;
- reading order of diagrams and tables;
- font size, line length, whitespace, and paragraph rhythm;
- abstract-to-detail sequence in a contact sheet;
- whether the page remains understandable in grayscale;
- whether a visual hides an unstated logical step.

After a meaningful edit, recompile, rerender, and rerun the affected semantic checkpoints.

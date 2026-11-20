# Redesign from First Principles

**Apply when:** integrating a new requirement into an existing design.

**Rule:** do not bolt the change on. Redesign as if the requirement had been a foundational assumption from the start, then deliver it incrementally.

- Read all affected files and understand the current design first.
- Ask: "if we were writing this from scratch with this requirement, what would we build?"
- Propagate the change through every reference: types, call sites, docs, examples, rationale.
- Think through the whole redesign; ship it in verifiable steps ([sequence-verifiable-units](sequence-verifiable-units.md)).

**Smell that you skipped this:** a new flag or special case threaded through code that otherwise ignores it.

**Defers to:** for exploratory ML experiments, a new hypothesis gets a new experiment directory copied from the closest prior one (`coding-rules` ML override), not a redesign of earlier experiments.

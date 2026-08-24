# Japanese writing for understanding slides

## Reader contract

Write for the reader defined in `research/scope.md`. Assume only the vocabulary explicitly marked as known. General technical terms may remain concise for an experienced reader, but topic-specific entities, transformations, constraints, and evaluation rules must be explained before their short labels are reused.

## Rewrite notes instead of publishing them

Internal reasoning often contains fragments such as labels, English nouns, arrows, tentative categories, and compressed causal chains. Treat these as a private intermediate representation. Before publication, rewrite them as Japanese sentences whose grammatical structure expresses the relation.

Do not publish:

- translated noun chains;
- unexplained English nouns embedded in Japanese;
- headings such as `five decisions` or `geometry branch` whose members are not named;
- labels joined by arrows when the operation is not stated;
- conclusions connected by `一方`, `つまり`, or `両立する` when the bridge is missing;
- a source's unusual verb-object combination translated word for word.

## Sentence contract

For every consequential statement, make these recoverable when they matter:

- subject or actor;
- input or object being changed;
- operation, comparison, or condition;
- stage or context;
- result or decision consequence;
- evidence status and uncertainty.

Not every sentence must spell out all six fields. The page and immediate context must make them unambiguous.

Prefer concrete explanation before abstraction. First state what enters, what changes, and what comes out. Then introduce the short technical term if later slides reuse it.

## Paragraph and slide flow

Use one paragraph for one claim. Before drafting each paragraph, decide:

1. what it receives from the previous paragraph;
2. what relation or claim it advances;
3. what it passes to the next paragraph.

The slide title names the subject or question. The claim states one conclusion. The body explains mechanism and evidence. A line break is not a substitute for a complete sentence.

## Safe shortening

Shortening is a reasoning-preservation task, not a character-deletion task. Shorten in this order:

1. remove repeated conclusions;
2. remove details that do not change the claim;
3. replace several similar examples with one representative example;
4. move aligned repeated fields into a table;
5. move a coherent branch to another slide;
6. shorten established terminology only after it has been defined.

Do not shorten primarily by dropping:

- particles that identify actor, object, source, or destination;
- conjunctions that distinguish cause, contrast, condition, or sequence;
- subjects or predicates needed to identify the operation;
- baselines, conditions, evaluation splits, or uncertainty labels;
- stage boundaries such as training, validation, inference, and postprocessing.

After shortening, expand the sentence back into this record:

`subject -> operation or relation -> object -> condition/stage -> result -> evidence/uncertainty`

If the remaining Japanese supports two materially different records, the shortening failed. Restore the relation, split the sentence, or add a slide. Do not trade logical recoverability for page count.

Record each checked slide group in `reviews/prose-reconstruction.csv`:

```csv
group_id,slide_ids,expanded_proposition,published_claim,reconstructed_proposition,ambiguity_found,correction,status
```

`expanded_proposition` is the complete relation before shortening. `reconstructed_proposition` is written without looking at that field. Use `yes` or `no` for `ambiguity_found` and `pass` or `revise` for `status`. A release cannot retain `revise`, unresolved ambiguity, or an empty correction when ambiguity was found.

## Naturalness check

Read the prose aloud or as continuous text rather than as boxes. Revise when:

- the same noun repeats because the sentence lacks a natural subject transition;
- particles are missing around English terms;
- several `〜する` phrases form a list without hierarchy;
- `これ`, `それ`, or `この方法` has more than one possible referent;
- a connective claims a relation not established by the preceding sentence;
- a sentence contains several ordered operations with no explicit sequence;
- a nominal ending hides whether the text is a fact, inference, or instruction.

Prefer ordinary Japanese verbs: `入力する`, `比較する`, `平均する`, `除外する`, `置き換える`, `制約を加える`, `予測値を修正する`. Use English only when it is the canonical technical name or improves source traceability.

## Terminology ledger

Record:

| concept | canonical Japanese | source term | first-use explanation | assumed knowledge | prohibited variants |
|---|---|---|---|---|---|

One concept uses one expression. Distinguish conceptual levels such as objective function, loss term, loss value, metric, prediction, and decision threshold rather than alternating a convenient short word.

## Final reconstruction test

For each slide, hide the source notes and ask:

- Can the title and claim be restated as one proposition?
- Can the body recover why the proposition follows?
- Can the reader identify the evidence and its limitation?
- Can the transition to the next slide be predicted?

If not, rewrite before changing typography or reducing font size.

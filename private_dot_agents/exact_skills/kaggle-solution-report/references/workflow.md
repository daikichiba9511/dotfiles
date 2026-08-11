# Workflow and evidence rules

## Contents

1. Research contract
2. Rank and medal scope
3. Kaggle collection
4. Solution discovery
5. Raw preservation
6. Per-solution analysis
7. Cross-solution synthesis
8. Task-grounded explanation
9. Strategy retrospective
10. Evidence labels and failure rules

## 1. Research contract

Write `scope/scope.md` before bulk retrieval. Record:

- competition slug, title, URL, host, competition type, close date, and retrieval time
- final leaderboard source and whether it is private/final
- whether the competition awarded medals and points
- exact selected rank set
- exact definition of upper-silver
- exact top-gold/lower-gold split
- report language, intended reader, and public-slide audience
- CLI or NVIDIA Kaggle Skill version/capability used
- known access and evidence limitations

When the report is Japanese, complete both the reader contract and terminology contract in `scope/scope.md` according to `japanese-report-writing.md` before drafting prose.

## 2. Rank and medal scope

Use final team rank as the unit of coverage.

1. Retrieve or export the final leaderboard.
2. Confirm the competition page says medals/points were awarded.
3. Identify all gold teams from explicit medal markers or an official cutoff.
4. Apply the user-provided upper-silver maximum rank or team count.
5. Deduplicate multiple solution posts from the same team into one coverage row while retaining every source.
6. Keep ties and team merges visible; do not silently renumber ranks.

Do not derive medal boundaries from generic Kaggle progression rules when the competition page or final leaderboard has explicit awards. Some competition types do not award medals or use nonstandard winner selection.

Default top-gold/lower-gold split only when the user has not specified one: order gold teams by final rank, place the first `ceil(n/2)` in top-gold, and the remainder in lower-gold. Record this analytical convention; do not imply Kaggle defines it.

If an official solution cannot be mapped to a final team, mark the mapping uncertain and do not use it for rank-separation claims.

## 3. Kaggle collection

Use the bundled wrapper, which forces Kaggle CLI through uv with Python 3.11 and Kaggle CLI 2.2.0 or newer:

```bash
scripts/kaggle_uv --version
scripts/kaggle_uv competitions topics list <slug> \
  --sort-by top --format json --quiet
scripts/kaggle_uv competitions topics list <slug> \
  --sort-by recent --format json --quiet
scripts/kaggle_uv competitions topics list <slug> \
  --sort-by active --format json --quiet
scripts/kaggle_uv competitions topics list <slug> \
  --search "solution" --sort-by relevance --format json --quiet
scripts/kaggle_uv competitions topics show <slug>/<topic-id> \
  --page-size 200 --format json --quiet
```

If a sandbox cannot write uv's normal cache or tool directories, assign `UV_CACHE_DIR`, `UV_TOOL_DIR`, and `UV_TOOL_BIN_DIR` to explicit writable temporary directories for this task, then rerun the same wrapper command. This changes only uv storage; it must not change Kaggle credentials or the research scope.

Follow `Next Page Token` with `--page-token`. The CLI may print the token after otherwise valid JSON; do not pipe that combined output directly to a JSON parser. Save each page separately and pass all pages to `scripts/render_topic_raw.py`, which parses the leading JSON value and records trailing tokens.

Use cross-forum discovery when competition-local search misses a known team or method:

```bash
scripts/kaggle_uv forums topics list \
  --search "<competition title or team> solution" \
  --category competitions --sort-by relevance \
  --page-size 200 --format json --quiet
```

Use topic IDs for deduplication and comment IDs for comment deduplication. Record every discovery ordering, query, page token, and retrieval timestamp.

## 4. Solution discovery

Search by more than votes or the word `solution`:

- ordinal phrases: `1st place`, `2nd place`, `gold`, `silver`
- team name and member handles from the final leaderboard
- `write-up`, `approach`, `postmortem`, `what worked`, `lessons learned`
- linked notebook titles, repositories, papers, and external blog titles

Build a candidate map:

| final rank | team | candidate topic IDs | linked artifacts | mapping confidence | selected source |
|---:|---|---|---|---|---|

Prefer sources in this order:

1. team-authored final write-up with code or measurements
2. team-authored write-up without code
3. organizer-hosted winner summary explicitly attributed to the team
4. team member notebook/repository linked from the discussion
5. third-party summary, used only as a discovery lead

Never promote a third-party description to team-authored evidence.

## 5. Raw preservation

Each solution raw file is an evidence container, not a summary. It must contain:

- final rank, medal band, team, members when known
- topic metadata, stable official URL or exact topic reference
- retrieval method/version/time
- original post content exactly as returned
- every retrieved comment exactly as returned, with ID and parent ID when available
- all linked artifacts and their retrieval status
- pagination tokens/pages and missing-body notes
- the search log when no solution was found

Do not normalize technical terminology, fix typos, translate, or merge comments in raw files. You may wrap returned HTML directly in Markdown because Markdown permits HTML. Clearly mark whether the source returned HTML, Markdown, plain text, or structured fields.

If the CLI returns topic metadata and comments but no original body:

1. state that the body was absent from the CLI response;
2. try the installed NVIDIA Kaggle Skill when available;
3. open the stable official topic page when the body is material;
4. preserve only content actually retrieved;
5. never reconstruct the body from replies.

## 6. Per-solution analysis

Complete the organized Markdown only from retained sources. Required content:

- one-paragraph overview
- end-to-end pipeline from input to prediction/submission
- key points, including reported contribution or ablation where available
- explanations that derive why the pieces fit together
- validation design and public/private leaderboard relationship
- ensemble, postprocessing, external data, compute, and reproducibility details
- evidence/confidence table and unresolved questions

For every numerical gain, record:

- metric and direction
- validation, public LB, or private LB
- baseline and comparison
- split/fold/seed/model scope
- whether the number is participant-reported or reproduced

Do not compare gains measured on different settings as if they were commensurate.

## 7. Cross-solution synthesis

Construct `synthesis/comparison-matrix.md` first. Use one row per team and columns that reflect the competition, such as:

- validation/split strategy
- data cleaning or external data
- input representation and augmentation
- model families/backbones
- loss/objective alignment
- inference and test-time adaptation
- postprocessing
- ensembling/diversity
- compute/runtime
- reported gains and evidence strength

Then separate three questions:

1. What appears across the full scoped field?
2. What differs between top-gold and lower-gold?
3. What differs between gold and upper-silver?

Frequency is descriptive, not causal. For each candidate factor, test alternative explanations:

- Is it just correlated with more compute?
- Is it a consequence of team size or late access to public notebooks?
- Was it reported only after leaderboard feedback?
- Does it survive ablation or independent replication?
- Is absence in a write-up true absence or merely unreported?

Use `unknown` rather than `no` when a write-up is silent.

## 8. Task-grounded explanation

For each common or differentiating factor, write this mechanism chain:

| link | required question |
|---|---|
| Task/data/metric property | What is structurally unusual or difficult? |
| Failure mode or incentive | What error does it create or reward? |
| Solution element | What did teams change? |
| Expected effect | Why should that change the measured error? |
| Observed evidence | Which write-up, ablation, discussion, or result supports it? |
| Uncertainty | What confounder or missing experiment remains? |

Research at least these non-solution contexts:

- target definition and label generation
- train/test provenance and distribution shift
- duplicates, groups, temporal/geographic/patient/entity structure
- annotation noise and ambiguous cases
- public/private test allocation and leaderboard shake-up
- exact metric formula, averaging, clipping, thresholds, ties, and edge cases
- organizer clarifications and evaluation bugs
- validation failures, leakage reports, and negative results

Derive metric incentives explicitly with equations or controlled examples. Do not stop at the metric name.

## 9. Strategy retrospective

Avoid a hindsight-only list of winning tricks. Reconstruct a discoverable path:

1. Which property could have been noticed from rules, data schema, or metric?
2. Which failure hypothesis follows from it?
3. What was the cheapest discriminating validation experiment?
4. What signal would justify investing in a larger model or ensemble?
5. Which leaderboard behaviors should have been distrusted?
6. Which solution ideas were unavailable without privileged hindsight?

Produce an ordered playbook: baseline, trustworthy validation, metric-aligned error analysis, targeted representation/model changes, inference/postprocessing, and finally diversity-aware ensembling.

## 10. Evidence labels and failure rules

Use these labels consistently:

- `organizer-confirmed`: competition host or Kaggle staff statement
- `directly-observed`: content, code, data field, or leaderboard value retrieved directly
- `participant-reported`: team or participant claim not independently reproduced
- `independently-reproduced`: rerun or separate measurement with aligned conditions
- `inference`: reasoned interpretation from cited evidence
- `unavailable`: source or claim could not be retrieved

Votes are discovery signals, not correctness. A notebook that was not executed locally is not reproduced evidence. A linked repository at a later commit is not necessarily the competition-time implementation.

Never:

- infer a missing write-up from comments
- invent absent ranks, methods, ablations, or medal cutoffs
- use the public leaderboard as final rank
- hide scoped teams with no public solution
- present a common element as the reason for winning without mechanism and evidence
- expose Kaggle authentication material
- submit, vote, comment, bookmark, or mutate Kaggle state

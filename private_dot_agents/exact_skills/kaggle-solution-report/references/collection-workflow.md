# Scope and Kaggle collection workflow

## Contents

1. Scope contract
2. Rank and medal scope
3. Kaggle retrieval
4. Solution discovery
5. Raw preservation

## 1. Scope contract

Write `scope/scope.md` before bulk retrieval. Record:

- competition slug, title, URL, host, competition type, close date, and retrieval time
- final leaderboard source and whether it is private and final
- whether the competition awarded medals and points
- exact selected rank set and upper-silver boundary
- exact top-gold/lower-gold split
- report language, intended reader, and public-slide audience
- CLI or NVIDIA Kaggle Skill version and capability used
- known access and evidence limitations

Complete the machine-readable frontmatter:

- `selection_mode`: `max-rank` or `team-count`
- `selection_value`: the positive integer boundary supplied by the user
- `typst_version`: the mise-selected version used for publication; leave `TODO` only while research is in progress

For `max-rank`, retrieve the complete final-leaderboard prefix through the boundary: it must reach that rank, contain at least `selection_value` unique team rows, and preserve ties. For `team-count`, retrieve at least that many unique final team rows. In `sources/leaderboard.csv`, preserve the source ordering as the consecutive, one-based `final_order`; this is not a replacement for tied Kaggle ranks. Validation checks this ordering and boundary before comparing the selected leaderboard row set with `coverage.csv`; truncating both files or keeping only the first and last rank cannot satisfy the gate.

When the report is Japanese, defer reader and terminology setup until the writing phase.

## 2. Rank and medal scope

Use final team rank as the unit of coverage.

1. Retrieve or export the final leaderboard.
2. Confirm that medals and points were awarded.
3. Identify gold teams from explicit medal markers or an official cutoff.
4. Apply the user-provided upper-silver maximum rank or team count.
5. Deduplicate multiple posts from one team into one coverage row while retaining every source.
6. Keep ties and team merges visible; never silently renumber ranks.

Do not derive medal boundaries from generic Kaggle progression rules when the competition or final leaderboard has explicit awards. Some competition types use no medals or nonstandard winner selection.

When the user does not define a top-gold/lower-gold split, order gold teams by final rank, place the first `ceil(n/2)` in top-gold, and the remainder in lower-gold. Record that this is an analytical convention, not a Kaggle definition.

If a solution cannot be mapped reliably to a final team, mark the mapping uncertain and exclude it from rank-separation claims.

## 3. Kaggle retrieval

Use the bundled wrapper, which forces Kaggle CLI through uv with Python 3.12 and resolves `kaggle@latest`:

```bash
scripts/kaggle_uv --version
scripts/kaggle_uv competitions topics list <slug> --sort-by top --format json --quiet
scripts/kaggle_uv competitions topics list <slug> --sort-by recent --format json --quiet
scripts/kaggle_uv competitions topics list <slug> --sort-by active --format json --quiet
scripts/kaggle_uv competitions topics list <slug> --search "solution" --sort-by relevance --format json --quiet

# Original topic body; JSON can omit it.
scripts/kaggle_uv competitions topics show <slug>/<topic-id> --page-size 200 --quiet

# Structured metadata and comments.
scripts/kaggle_uv competitions topics show <slug>/<topic-id> --page-size 200 --format json --quiet
```

If the sandbox cannot write uv's cache or tool directories, assign `UV_CACHE_DIR`, `UV_TOOL_DIR`, and `UV_TOOL_BIN_DIR` to explicit writable temporary directories and rerun the wrapper. Do not change credentials or research scope.

Follow every `Next Page Token` with `--page-token` until none remains. Do this for every selected discovery ordering and search query, not only for selected topic comments. The CLI can print the token after otherwise valid JSON; save it separately instead of piping the combined output to a JSON parser.

Kaggle CLI JSON can omit a publicly retrievable original body. Retrieve each selected topic through three representations from the same official Kaggle package version:

1. package API HTML via `scripts/fetch_topic_body.py`;
2. non-JSON CLI output proving public body retrieval;
3. CLI JSON for stable metadata, comment IDs, and pagination.

For one topic, prefer `scripts/collect_topic_raw.py`; it performs all retrievals, follows comment pagination, and calls the renderer. For multiple team-authored topics, collect each independently and merge the complete topic sections with `scripts/combine_topic_raw.py`. Never pass pages from different topic IDs to one renderer invocation.

Use `scripts/render_topic_raw.py` for manual assembly. Pass HTML with `--topic-html-input`, non-JSON output with `--topic-text-input`, and JSON pages as positional inputs. It must fail when no representation contains a body unless `--allow-missing-body` is supplied after recording the failed plain-text attempt.

For cross-forum discovery:

```bash
scripts/kaggle_uv forums topics list \
  --search "<competition title or team> solution" \
  --category competitions --sort-by relevance \
  --page-size 200 --format json --quiet
```

Use topic IDs and comment IDs for deduplication. Record every discovery order, query, page token, retrieval timestamp, and tool version.

## 4. Solution discovery

Search beyond votes and the word `solution`:

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
4. team member notebook or repository linked from the discussion
5. third-party summary, used only as a discovery lead

Never promote a third-party description to team-authored evidence.

Run the discovery gate independently for every selected rank before assigning `unavailable`:

1. exhaust the `top`, `recent`, and `active` topic orderings and the relevance search, following all page tokens;
2. search the exact final team name and every known member handle;
3. search rank and medal phrases such as `1st`, `20th`, `gold`, and `silver` together with `solution`, `write-up`, `approach`, `postmortem`, and `what worked`;
4. inspect team-authored notebooks, repositories, attachments, and cross-forum results reached from those searches;
5. record every query, ordering, page count, terminal page-token state, candidate topic, and mapping decision in the raw search log.

An empty relevance search is not evidence that no solution exists. Set `method_status=unavailable` only after the rank-specific search matrix is complete. In the raw file, mark the four search-completion checkboxes defined in `schemas.md`; validation rejects a method-unavailable row without them.

## 5. Raw preservation

Treat each raw file as an evidence container, not a summary. Include:

- final rank, medal band, team, and members when known
- topic metadata and stable official URL or exact topic reference
- retrieval method, version, and time
- original post exactly as returned
- every retrieved comment exactly as returned, including ID and parent ID when available
- linked artifacts and retrieval status
- pagination tokens/pages and missing-body notes
- search log when no solution was found

Do not normalize terms, fix typos, translate, or merge comments in raw files. Mark whether content was returned as HTML, Markdown, plain text, or structured fields.

If neither CLI representation returns a body:

1. record both failures;
2. try the installed NVIDIA Kaggle Skill when available;
3. open the stable official topic page when the body is material;
4. preserve only retrieved content;
5. never reconstruct the body from replies.

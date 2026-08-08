# Kaggle Discussion Collection

Use this reference only when the research target includes Kaggle community evidence.

## Authentication and safety

- Run the official `kaggle` CLI in the host environment so it can use `~/.kaggle/kaggle.json`.
- Never print, copy, summarize, or commit the authentication file or its values.
- Check availability with `kaggle --version`. The `forums` and `topics` workflow requires Kaggle CLI 2.2.0 or newer.
- Keep this workflow read-only. Do not submit, post, vote, bookmark, or mutate Kaggle state.

## Discover topics

For one competition, start with more than one ordering so popularity does not hide recent failures or unresolved questions:

```bash
kaggle competitions topics list <competition-slug> --sort-by top --format json --quiet
kaggle competitions topics list <competition-slug> --sort-by recent --format json --quiet
kaggle competitions topics list <competition-slug> --sort-by active --format json --quiet
```

Kaggle CLI 2.2.3 paginates competition topic lists with `--page <number>` and returns 20 topics per page. Continue until a page is empty or repeats topic IDs.

For keyword search across Kaggle discussions, use the unified forums endpoint:

```bash
kaggle forums topics list \
  --search "<query>" \
  --category competitions \
  --sort-by relevance \
  --page-size 200 \
  --format json \
  --quiet
```

Change `--category` when the target is `forums`, `datasets`, `competition_write_ups`, `models`, or `benchmarks`. Use `kaggle forums list --format json --quiet` to discover general forum slugs. Follow `nextPageToken` with `--page-token` when it is present.

Search with terms tied to the decision: metric names, feature names, model families, leakage, validation, shake-up, failure, bug, reproducibility, or organizer clarification. Do not treat the first or most-upvoted result as complete coverage.

## Read topics and comments

For a competition topic:

```bash
kaggle competitions topics show \
  <competition-slug>/<topic-id> \
  --page-size 200 \
  --format json \
  --quiet
```

For a general forum topic:

```bash
kaggle forums topics show \
  <forum-slug>/<topic-id> \
  --page-size 200 \
  --format json \
  --quiet
```

If the response includes `nextPageToken`, fetch the remaining comments with `--page-token <token>`. Prefer `topics show`; `competitions topic-messages` is deprecated.

The API can return topic metadata and comments without the original post body. When that happens:

- do not reconstruct the missing post from replies;
- limit claims to the returned title, author, date, votes, comments, and independently retrieved links or notebooks;
- open the official topic page only when the missing body is material to the conclusion;
- state that the original post body was unavailable through the CLI.

## Record evidence

Deduplicate topics by topic ID and comments by comment ID. For each retained item, record:

- competition or forum scope;
- topic ID, title, author, post date, votes, and comment count;
- query, category, ordering, and page used for discovery;
- relevant comment ID, author, date, votes, and content;
- linked notebook, code, paper, rule, or organizer statement;
- retrieval time and any missing-body or pagination limitation.

Preserve a URL returned by Kaggle when available. Otherwise retain the exact `<scope>/<topic-id>` reference and resolve a stable official URL in the browser before citing it; do not guess URL structure.

## Judge evidence conservatively

Kaggle discussions are community evidence, not automatically verified facts.

- Separate organizer or host clarification from participant claims.
- Separate winner write-ups with code or measurements from unsupported anecdotes.
- Treat votes as a discovery signal, not a correctness score.
- Capture disagreements and failure reports, not only consensus or high scores.
- For each claim, note the evaluation setting, data split, public/private leaderboard status, date, and reproducibility evidence when available.
- Cross-check consequential claims against competition rules, official pages, executable notebooks, source code, papers, or leaderboard data.

In the final synthesis, label what is directly observed, participant-reported, organizer-confirmed, independently reproduced, or unavailable.

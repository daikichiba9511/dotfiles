# Evidence labels and failure rules

Use these labels consistently:

- `organizer-confirmed`: competition host or Kaggle staff statement
- `directly-observed`: retrieved content, code, data field, or leaderboard value
- `participant-reported`: team or participant claim not independently reproduced
- `independently-reproduced`: rerun or separate measurement with aligned conditions
- `inference`: reasoned interpretation from cited evidence
- `unavailable`: source or claim could not be retrieved

Votes are discovery signals, not proof. An unexecuted notebook is not reproduced evidence. A repository at a later commit is not necessarily the competition-time implementation.

Never:

- infer a missing write-up from comments
- invent absent ranks, methods, ablations, or medal cutoffs
- use the public leaderboard as final rank
- hide scoped teams with no public solution
- present a common element as the reason for winning without a mechanism and evidence
- expose Kaggle authentication material
- submit, vote, comment, bookmark, or otherwise mutate Kaggle state

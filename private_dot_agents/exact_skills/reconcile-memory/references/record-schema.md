# Memory record schema

Use this schema as a semantic checklist. Match the storage format supported by the active memory system; do not invent a new database or rewrite generated summaries.

```markdown
# <short subject>

- Operation: ADD | REFINE | CONFIRM | SUPERSEDE | CONTRADICT | REVIEW
- Kind: preference | fact | decision | instruction | relationship | event
- Claim: <one complete sentence whose subject and scope are explicit>
- Source: <user statement, local file, log, URL, or other identifiable source>
- Evidence status: user-stated | observed | source-backed | inferred | disputed | unknown
- Current status: current | conditional | historical | review
- Scope: <where, for whom, and under which conditions the claim applies>
- Valid from: <date or unknown>
- Valid until: <date, event, or unknown>
- Supersedes: <record reference or none>
- Superseded by: <record reference or none>
- Notes: <only what is needed to interpret the claim>
```

## Audit checklist

- Can the claim be understood without supplying a missing subject, particle, or predicate?
- Does the source support the claim at the stated scope?
- Is a user statement distinguished from an externally verified fact?
- Is an inference explicitly marked as an inference?
- If a fact changed, are the old and new validity periods distinguishable?
- Does each current claim have at most one current replacement for the same scope?
- Are historical and disputed claims prevented from silently driving current answers?
- Was task-local state kept out of long-term memory?

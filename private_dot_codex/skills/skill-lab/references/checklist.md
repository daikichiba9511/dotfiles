# Skill Lab Checklist

## Trigger Checklist

- Does `description` state both what the skill does and when to use it?
- Does it include realistic user phrasing?
- Is the trigger boundary distinct from nearby skills?
- Would a future reader know when *not* to use it?

## Structure Checklist

- Is `SKILL.md` mostly workflow, not data dump?
- Are long templates or examples moved to `references/`?
- Are references mentioned from `SKILL.md` at the point of use?
- Are scripts included only for deterministic or repeated work?

## Migration Checklist

When porting a Claude skill to Codex:

- remove Claude-specific wording unless intentional
- remove assumptions about tools that do not exist in Codex
- rename if it would collide with built-in skills
- re-check `allowed-tools` against Codex usage
- keep the skill concise instead of copying the source verbatim

## Refactor Checklist

- Split sections when the skill supports multiple modes or domains
- Replace repeated examples with one reference file
- Keep the main workflow readable in one pass
- Preserve only the details that actually change agent behavior

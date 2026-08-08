---
name: skill-lab
description: "Use when creating, porting, refactoring, or auditing local Codex Skills: trigger descriptions, overlap, context size, SKILL.md structure, references, or bundled resources. Do not use for merely executing an existing skill."
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Skill Lab

Build and improve local Codex skills.
Use `references/checklist.md` when you need the migration checklist, trigger audit list, or progressive-disclosure review.

## Goals

- create skills that trigger reliably
- keep `SKILL.md` compact
- move bulky detail into `references/`
- avoid overlap and naming conflicts with existing skills

## Workflow

### Step 1: Inventory the current state

Check:

- existing skill names and descriptions
- overlap with built-in or local skills
- whether the request is a new skill, a migration, or a refactor

### Step 2: Define the trigger boundary

Write the description around:

- what the skill does
- when it should trigger
- concrete user phrases or contexts

If the description only explains the skill and not the trigger surface, it is too weak.

### Step 3: Design the skill structure

Keep `SKILL.md` for:

- workflow skeleton
- decision points
- references to deeper files

Move into `references/`:

- long templates
- checklists
- large examples
- schemas
- format specs

### Step 4: Implement

Create or update:

- `SKILL.md`
- `references/` files if needed
- bundled scripts only when a step benefits from deterministic execution

### Step 5: Verify

Check the skill against `references/checklist.md`.

If working in this dotfiles repo, edit `private_dot_agents/exact_skills/...`, then apply it to `~/.agents/skills/...` with chezmoi.

## Rules

- do not create redundant skills when a description fix would solve the problem
- do not stuff evaluation notes or changelogs into the skill directory
- prefer one sharp skill over a broad vague one
- prefer references over giant SKILL bodies

$ARGUMENTS

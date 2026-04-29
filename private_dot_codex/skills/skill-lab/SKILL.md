---
name: skill-lab
description: "Create, port, refactor, or improve Codex skills. Use when the user wants a new skill, wants to migrate a Claude skill to Codex, tighten trigger descriptions, split a bloated SKILL.md into references, add bundled resources, or audit whether current skills are missing coverage. Trigger for requests like 'skill作って', 'Claudeのskillを移植して', 'contextを軽くしたい', 'triggerを改善したい', 'skillを整理して'."
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

If working in this dotfiles repo, keep `private_dot_codex/skills/...` and `~/.codex/skills/...` in sync after edits.

## Rules

- do not create redundant skills when a description fix would solve the problem
- do not stuff evaluation notes or changelogs into the skill directory
- prefer one sharp skill over a broad vague one
- prefer references over giant SKILL bodies

$ARGUMENTS

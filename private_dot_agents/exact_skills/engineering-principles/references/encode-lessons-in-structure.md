# Encode Lessons in Structure

**Apply when:** you catch yourself writing the same instruction a second time, or notice the same correction recurring.

**Rule:** encode the rule as structure (a lint rule, type, runtime assertion, test, hook, or script) instead of adding more text.

- If the fix is structural, use only the structural fix and remove the redundant instruction. The repeated instruction was the symptom.
- If the lesson needs judgment and cannot be encoded, make the instruction more prominent and add one example of the failure mode.

**Defers to:** changes to persistent configuration (hooks, settings, CLAUDE.md, rules files, dotfiles) are proposed to the user, not made silently. In this dotfiles repo, edit the chezmoi source, not the target.

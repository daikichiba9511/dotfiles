# Dotfiles Repository

This repository is managed by [chezmoi](https://www.chezmoi.io/).

## Chezmoi File Editing Rules

- Always edit files in this repository, never at the target locations (e.g., `~/.config/`, `~/.claude/`)
- After editing, apply with `chezmoi apply --force`
- Chezmoi uses naming conventions to map source files to targets:
  - `dot_` prefix → `.` (e.g., `dot_zshrc` → `~/.zshrc`)
  - `private_` prefix → sets file permissions to private
  - `executable_` prefix → sets file as executable
  - Prefixes are combinable (e.g., `private_dot_claude/` → `~/.claude/`)

# Dotfiles Project Rules

This repository is managed by [chezmoi](https://www.chezmoi.io/).

## Workflow

When modifying chezmoi-managed files (files with prefixes like `dot_`, `private_dot_`, `executable_`, etc.):

1. Edit files in this repository (not in the target location like `~/.config/`)
2. Apply changes with `chezmoi apply --force`

## File Naming Convention

- `dot_` → `.` (e.g., `dot_zshrc` → `~/.zshrc`)
- `private_` → file with 0600 permissions
- `executable_` → file with executable permission
- `run_once_` → script that runs once
- `run_` → script that runs on every apply

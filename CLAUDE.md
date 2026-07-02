# Dotfiles (chezmoi)

Dotfiles under `~` (e.g. `~/.config/`, `~/.claude/`, `~/.zshrc`) are managed by [chezmoi](https://www.chezmoi.io/). The source of truth is the repo at `~/dotfiles`.

## Editing Rules

- Never edit managed files at their target locations — edit the source in `~/dotfiles`, then apply with `chezmoi apply --force`
- Chezmoi maps source names to targets:
  - `dot_` prefix → `.` (e.g., `dot_zshrc` → `~/.zshrc`)
  - `private_` prefix → sets file permissions to private
  - `executable_` prefix → sets file as executable
  - Prefixes are combinable (e.g., `private_dot_claude/` → `~/.claude/`)

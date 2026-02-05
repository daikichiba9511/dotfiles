#!/bin/bash
input=$(cat)

# Extract from JSON
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir // "?"' | xargs basename)
CONTEXT_USED=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
MODEL_NAME=$(echo "$input" | jq -r '.model.display_name // "?"')

# User and Host
USER=$(whoami)
HOST=$(hostname -s)

# Git branch (skip optional locks)
GIT_BRANCH=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git --no-optional-locks branch --show-current 2>/dev/null)
    [ -n "$BRANCH" ] && GIT_BRANCH=" ($BRANCH)"
fi

# Context usage info
CONTEXT_INFO=""
if [ -n "$CONTEXT_USED" ]; then
    CONTEXT_USED_INT=$(printf "%.0f" "$CONTEXT_USED")
    CONTEXT_INFO="${CONTEXT_USED_INT}%"
fi

# Format: [Model] user@host:directory (branch) | ctx: X%
# Cyan for model, green for user@host, blue for directory, magenta for branch, yellow for ctx
# Dark gray (90m) for separators (: and |)
printf "\033[01;36m[%s]\033[00m \033[01;32m%s@%s\033[00m\033[90m:\033[00m\033[01;34m%s\033[00m\033[01;35m%s\033[00m \033[90m|\033[00m \033[01;33m%s\033[00m\n" \
    "$MODEL_NAME" "$USER" "$HOST" "$CURRENT_DIR" "$GIT_BRANCH" "$CONTEXT_INFO"

#!/bin/bash
input=$(cat)

# Extract from JSON
MODEL=$(echo "$input" | jq -r '.model.display_name // "?"')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir // "?"' | xargs basename)
CONTEXT_USED=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

# User and Host
USER=$(whoami)
HOST=$(hostname -s)

# Git branch
GIT_BRANCH=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    [ -n "$BRANCH" ] && GIT_BRANCH=" ($BRANCH)"
fi

echo "[$MODEL] $USER@$HOST:$CURRENT_DIR$GIT_BRANCH | ctx:${CONTEXT_USED}%"

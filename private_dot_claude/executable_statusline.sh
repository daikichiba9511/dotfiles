#!/bin/bash
input=$(cat)

# Extract from JSON
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir // "?"')
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
    CONTEXT_INFO=" | ctx: ${CONTEXT_USED_INT}%"
fi

# Format: [Model] user@host:directory (branch) | ctx: X%
# Cyan for model, green for user@host, blue for directory, yellow for branch
CYAN='\e[01;36m'
GREEN='\e[01;32m'
BLUE='\e[01;34m'
YELLOW='\e[01;33m'
RESET='\e[00m'

echo -e "${CYAN}[${MODEL_NAME}]${RESET} ${GREEN}${USER}@${HOST}${RESET}:${BLUE}${CURRENT_DIR}${RESET}${YELLOW}${GIT_BRANCH}${RESET}${CONTEXT_INFO}"

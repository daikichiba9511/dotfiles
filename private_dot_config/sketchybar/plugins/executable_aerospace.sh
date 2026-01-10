#!/bin/bash

# AeroSpace dynamic workspace indicator
# Shows only non-empty workspaces, highlights current

CURRENT=$(aerospace list-workspaces --focused 2>/dev/null)
WORKSPACES=$(aerospace list-workspaces --monitor all --empty no 2>/dev/null)

# Colors
ACCENT=0xff7aa2f7
TEXT=0xffffffff
INACTIVE=0x80ffffff
BG_ACTIVE=0x407aa2f7

# Update each workspace item
for sid in 1 2 3 4 5 6 7 8 9 10; do
  # Check if workspace has windows
  if echo "$WORKSPACES" | grep -q "^${sid}$"; then
    # Workspace has windows - show it
    if [ "$sid" = "$CURRENT" ]; then
      # Current workspace
      sketchybar --set space.$sid \
        drawing=on \
        icon.color=$ACCENT \
        background.drawing=on \
        background.color=$BG_ACTIVE
    else
      # Other workspace with windows
      sketchybar --set space.$sid \
        drawing=on \
        icon.color=$INACTIVE \
        background.drawing=off
    fi
  else
    # No windows - hide it
    sketchybar --set space.$sid drawing=off
  fi
done

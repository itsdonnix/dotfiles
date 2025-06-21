#!/usr/bin/env bash

# Path to your Zsh history file
ZSH_HISTORY_FILE="${HOME}/.zsh_history"
BACKUP_FILE="${ZSH_HISTORY_FILE}.bak.$(date +%Y%m%d%H%M%S)"

# Backup the original history file
cp "$ZSH_HISTORY_FILE" "$BACKUP_FILE"
echo "Backup saved to $BACKUP_FILE"

# Create a temporary directory using mktemp
TEMP_DIR=$(mktemp -d)

# Extract just the commands from the history
# Format: : 1667386293:0;command
# Remove metadata (everything before first semicolon)
awk -F';' '{if (NF>1) print $2}' "$ZSH_HISTORY_FILE" |

  # Remove blank lines
  grep -v '^\s*$' |

  # Trim whitespace
  sed 's/^[ \t]*//;s/[ \t]*$//' |

  # Remove duplicates, keep recent (use tac to reverse, sort + uniq, then reverse again)
  tac | awk '!seen[$0]++' | tac >/tmp/cleaned_zsh_history

# Optionally limit number of entries (e.g. 5000)
MAX_LINES=5000
tail -n "$MAX_LINES" "$TEMP_DIR/cleaned_zsh_history" >"$TEMP_DIR/trimmed_zsh_history"

# Reformat into Zsh history format
awk -v now="$(date +%s)" '{print ": " now ":0;" $0}' "$TEMP_DIR/trimmed_zsh_history" >"$ZSH_HISTORY_FILE"

# Clean up
rm -r "$TEMP_DIR"

echo "Zsh history cleaned successfully."

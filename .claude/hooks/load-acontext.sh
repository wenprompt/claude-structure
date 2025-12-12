#!/bin/bash
# ============================================================================
# ACONTEXT LOADER - Session Start Context Injection
# ============================================================================
# Trigger: SessionStart (when a new conversation begins)
# Purpose: Load previous feedback context so Claude learns from past sessions
# ============================================================================

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
ACONTEXT_FILE="$PROJECT_DIR/.claude/docs/acontext.json"

# Exit silently if no context file exists
[ ! -s "$ACONTEXT_FILE" ] && exit 0

# Check if there's any meaningful content (not just empty arrays)
WINS=$(grep -o '"wins": \[\]' "$ACONTEXT_FILE" 2>/dev/null)
LOSSES=$(grep -o '"losses": \[\]' "$ACONTEXT_FILE" 2>/dev/null)
CORRECTIONS=$(grep -o '"corrections": \[\]' "$ACONTEXT_FILE" 2>/dev/null)

# If all arrays are empty, skip loading
if [ -n "$WINS" ] && [ -n "$LOSSES" ] && [ -n "$CORRECTIONS" ]; then
  exit 0
fi

# Output context for Claude to see
cat << 'EOF'
<previous-session-feedback>
The following is feedback from previous sessions. Use this to improve:
- WINS: Actions the user liked (repeat these patterns)
- LOSSES: Actions the user disliked (avoid these patterns)
- CORRECTIONS: Explicit rules from the user (highest priority)
</previous-session-feedback>
EOF

cat "$ACONTEXT_FILE"

exit 0

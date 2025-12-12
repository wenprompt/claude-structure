#!/bin/bash
# ============================================================================
# ACONTEXT TRACKER - User Prompt Analyzer
# ============================================================================
# Trigger: UserPromptSubmit (when user sends a message)
# Purpose: Detect wins, losses, and corrections to learn from feedback
#
# Wins     → User happy (repeat this behavior)
# Losses   → User unhappy (avoid this behavior)  
# Corrections → Explicit rules (highest priority learning)
# ============================================================================

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
ACONTEXT_FILE="$PROJECT_DIR/.claude/docs/acontext.json"

# Read stdin (Claude Code pipes the prompt JSON here)
INPUT=$(cat 2>/dev/null || true)
[ -z "$INPUT" ] && exit 0

# Extract prompt text
PROMPT=$(echo "$INPUT" | sed -n 's/.*"prompt"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
[ -z "$PROMPT" ] && exit 0

PROMPT_LOWER=$(echo "$PROMPT" | tr 'A-Z' 'a-z')
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Truncate prompt for context (first 150 chars), escape for JSON
CONTEXT=$(echo "$PROMPT" | cut -c1-150 | tr '"' "'" | tr '\n' ' ' | sed 's/\\/\\\\/g')

# Initialize acontext.json if it doesn't exist
mkdir -p "$PROJECT_DIR/.claude/docs"
if [ ! -s "$ACONTEXT_FILE" ]; then
  cat > "$ACONTEXT_FILE" << 'EOF'
{
  "updated": "",
  "wins": [],
  "losses": [],
  "corrections": []
}
EOF
fi

# Helper function for cross-platform sed
update_json() {
  local pattern="$1"
  local replacement="$2"
  local TMP_FILE=$(mktemp)
  sed "s|$pattern|$replacement|" "$ACONTEXT_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$ACONTEXT_FILE"
}

# ----------------------------------------------------------------------------
# Detect WINS - user is happy with what Claude did
# ----------------------------------------------------------------------------
WIN_TRIGGERS="perfect|great|exactly|awesome|nice|good job|that's right|thats right|correct|well done|love it|nailed it|excellent"

if echo "$PROMPT_LOWER" | grep -qE "(^|[^a-z])($WIN_TRIGGERS)([^a-z]|$)"; then
  TRIGGER=$(echo "$PROMPT_LOWER" | grep -oE "($WIN_TRIGGERS)" | head -1)
  update_json '"wins": \[' '"wins": [{"trigger":"'"$TRIGGER"'","context":"'"$CONTEXT"'","at":"'"$TIMESTAMP"'"},'
fi

# ----------------------------------------------------------------------------
# Detect LOSSES - user is unhappy with what Claude did
# ----------------------------------------------------------------------------
LOSS_TRIGGERS="no that's wrong|no thats wrong|that's not right|thats not right|incorrect|don't do that|dont do that|undo|revert|that's bad|thats bad|not what i asked|not what i wanted"

if echo "$PROMPT_LOWER" | grep -qE "($LOSS_TRIGGERS)"; then
  TRIGGER=$(echo "$PROMPT_LOWER" | grep -oE "($LOSS_TRIGGERS)" | head -1)
  update_json '"losses": \[' '"losses": [{"trigger":"'"$TRIGGER"'","context":"'"$CONTEXT"'","at":"'"$TIMESTAMP"'"},'
fi

# ----------------------------------------------------------------------------
# Detect CORRECTIONS - explicit rules from user
# Pattern: "actually...", "remember...", "always...", "never...", "from now on..."
# ----------------------------------------------------------------------------
CORRECTION_PATTERNS="^actually|^remember|^always|^never|^from now on|^in the future|^going forward|^don't ever|^dont ever"

if echo "$PROMPT_LOWER" | grep -qE "($CORRECTION_PATTERNS)"; then
  RULE=$(echo "$PROMPT" | cut -c1-200 | tr '"' "'" | tr '\n' ' ' | sed 's/\\/\\\\/g')
  update_json '"corrections": \[' '"corrections": [{"rule":"'"$RULE"'","at":"'"$TIMESTAMP"'"},'
fi

# Clean up trailing commas before ]
TMP_FILE=$(mktemp)
sed 's/,]/]/g' "$ACONTEXT_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$ACONTEXT_FILE"

# Update timestamp
TMP_FILE=$(mktemp)
sed 's/"updated": "[^"]*"/"updated": "'"$TIMESTAMP"'"/' "$ACONTEXT_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$ACONTEXT_FILE"

exit 0

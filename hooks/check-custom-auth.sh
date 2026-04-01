#!/bin/bash
# PostToolUse hook: Warn when non-Supabase auth packages are imported.
# Reads JSON from stdin with tool_input.file_path, checks for forbidden auth imports.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)

# Skip if no file path
[[ -z "$FILE_PATH" ]] && exit 0

# Skip non-TypeScript/JavaScript files
[[ ! "$FILE_PATH" =~ \.(ts|tsx|js|jsx)$ ]] && exit 0

# Skip test files
[[ "$FILE_PATH" =~ \.(test|spec)\.(ts|tsx|js|jsx)$ ]] && exit 0

# Skip if file doesn't exist
[[ ! -f "$FILE_PATH" ]] && exit 0

# Check for forbidden auth imports
AUTH_HITS=$(grep -nE "(import|require).*['\"](@auth/|next-auth|next\/auth|jsonwebtoken|jose|passport)" "$FILE_PATH" 2>/dev/null)
if [[ -n "$AUTH_HITS" ]]; then
  echo "[TYTOS STANDARDS] Non-approved auth package detected in $FILE_PATH:" >&2
  echo "$AUTH_HITS" >&2
  echo "Use @supabase/ssr and @supabase/supabase-js for authentication. See CLAUDE.md anti-pattern #3." >&2
fi

# Check for manual JWT operations
JWT_HITS=$(grep -nE '(jwt\.sign|jwt\.verify|jwt\.decode|new SignJWT|jwtVerify)' "$FILE_PATH" 2>/dev/null)
if [[ -n "$JWT_HITS" ]]; then
  echo "[TYTOS STANDARDS] Manual JWT operations detected in $FILE_PATH:" >&2
  echo "$JWT_HITS" >&2
  echo "Use Supabase Auth instead of manual JWT handling." >&2
fi

exit 0

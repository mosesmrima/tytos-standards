#!/bin/bash
# PostToolUse hook: Warn when mock/stub/fake data patterns are written to source files.
# Reads JSON from stdin with tool_input.file_path, checks the file for violations.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)

# Skip if no file path
[[ -z "$FILE_PATH" ]] && exit 0

# Skip non-TypeScript/JavaScript files
[[ ! "$FILE_PATH" =~ \.(ts|tsx|js|jsx)$ ]] && exit 0

# Skip test files and fixtures (mock data is acceptable there)
[[ "$FILE_PATH" =~ \.(test|spec)\.(ts|tsx|js|jsx)$ ]] && exit 0
[[ "$FILE_PATH" =~ __tests__|__mocks__|fixtures|\.stories\. ]] && exit 0
[[ "$FILE_PATH" =~ prisma/seed ]] && exit 0

# Skip if file doesn't exist
[[ ! -f "$FILE_PATH" ]] && exit 0

# Check for mock/stub/dummy/fake data arrays or objects
MOCK_HITS=$(grep -nE '(const|let|var)\s+(mock|stub|dummy|fake|placeholder|sample)\w*\s*[:=]\s*[\[\{]' "$FILE_PATH" 2>/dev/null)
if [[ -n "$MOCK_HITS" ]]; then
  echo "[TYTOS STANDARDS] Mock/stub data detected in $FILE_PATH:" >&2
  echo "$MOCK_HITS" >&2
  echo "Errors must propagate — never mask them with fake data. See CLAUDE.md anti-pattern #1." >&2
fi

# Check for fallback data in catch blocks (catch returning arrays/objects)
CATCH_HITS=$(grep -nA5 'catch\s*(' "$FILE_PATH" 2>/dev/null | grep -E 'return\s*[\[\{]' | head -3)
if [[ -n "$CATCH_HITS" ]]; then
  echo "[TYTOS STANDARDS] Possible fallback data in catch block in $FILE_PATH:" >&2
  echo "$CATCH_HITS" >&2
  echo "Catch blocks should throw or return error responses, not fake data." >&2
fi

exit 0

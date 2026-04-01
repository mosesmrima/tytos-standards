#!/bin/bash
# PostToolUse hook: Warn when INSERT INTO statements appear in migration files.
# Reads JSON from stdin with tool_input.file_path, checks for seed data in migrations.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)

# Skip if no file path
[[ -z "$FILE_PATH" ]] && exit 0

# Only check migration SQL files
[[ ! "$FILE_PATH" =~ migrations/.*\.sql$ ]] && exit 0

# Skip if file doesn't exist
[[ ! -f "$FILE_PATH" ]] && exit 0

# Check for INSERT INTO statements
INSERT_HITS=$(grep -nE 'INSERT\s+INTO' "$FILE_PATH" 2>/dev/null)
if [[ -n "$INSERT_HITS" ]]; then
  echo "[TYTOS STANDARDS] Seed data detected in migration file $FILE_PATH:" >&2
  echo "$INSERT_HITS" >&2
  echo "Migrations are for schema changes only. Move seed data to prisma/seed.ts. See CLAUDE.md anti-pattern #2." >&2
  echo "(Note: INSERT INTO for enum/lookup tables that are part of the schema may be intentional — review manually.)" >&2
fi

exit 0

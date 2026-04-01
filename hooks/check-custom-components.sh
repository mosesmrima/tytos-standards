#!/bin/bash
# PostToolUse hook: Warn when custom UI components are created that duplicate HeroUI/shadcn.
# Reads JSON from stdin with tool_input.file_path, checks for custom component definitions.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)

# Skip if no file path
[[ -z "$FILE_PATH" ]] && exit 0

# Only check .tsx files (React components)
[[ ! "$FILE_PATH" =~ \.tsx$ ]] && exit 0

# Skip test files and stories
[[ "$FILE_PATH" =~ \.(test|spec|stories)\.tsx$ ]] && exit 0

# Skip node_modules
[[ "$FILE_PATH" =~ node_modules ]] && exit 0

# Skip if file doesn't exist
[[ ! -f "$FILE_PATH" ]] && exit 0

# Components that should come from HeroUI or shadcn
PRIMITIVES="Button|Modal|Card|Input|Select|Dialog|Table|Tabs|Dropdown|Navbar"

# Check if file exports one of these component names
COMPONENT_HITS=$(grep -nE "export\s+(default\s+)?function\s+($PRIMITIVES)\b|export\s+const\s+($PRIMITIVES)\b" "$FILE_PATH" 2>/dev/null)

if [[ -n "$COMPONENT_HITS" ]]; then
  # Check if file imports from HeroUI or shadcn (components/ui/ convention)
  USES_HEROUI=$(grep -c "@heroui/" "$FILE_PATH" 2>/dev/null)
  USES_SHADCN=$(grep -cE "@/components/ui/|from ['\"]@shadcn" "$FILE_PATH" 2>/dev/null)

  # If no HeroUI or shadcn import, this is a custom component from scratch
  if [[ "$USES_HEROUI" -eq 0 ]] && [[ "$USES_SHADCN" -eq 0 ]]; then
    echo "[TYTOS STANDARDS] Custom UI component detected in $FILE_PATH:" >&2
    echo "$COMPONENT_HITS" >&2
    echo "Use @heroui/react or shadcn/ui instead of building components from scratch. See CLAUDE.md anti-pattern #4." >&2
  fi
fi

exit 0

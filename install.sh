#!/bin/bash
# Tytos Standards Installer (Manual Method)
#
# PREFERRED: Use the plugin system instead:
#   /plugin marketplace add tytos/standards
#   /plugin install tytos-standards@tytos-standards
#
# This script is the fallback for manual installation.
# It symlinks slash commands and skills to ~/.claude/ so they're available across all projects.
# Project-level enforcement (hooks, rules, settings.json) is in project-template/ and
# should be copied into each project's root directory.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "Tytos Standards Installer"
echo "========================="
echo ""

# Verify ~/.claude exists
if [[ ! -d "$CLAUDE_DIR" ]]; then
  echo "Error: ~/.claude directory not found. Is Claude Code installed?"
  exit 1
fi

# Ensure target directories exist
mkdir -p "$CLAUDE_DIR/commands"
mkdir -p "$CLAUDE_DIR/skills/tytos-standards"

# Install slash commands
echo "Installing slash commands..."
for cmd in "$SCRIPT_DIR/commands/"*.md; do
  name=$(basename "$cmd")
  ln -sf "$cmd" "$CLAUDE_DIR/commands/$name"
  echo "  ✓ /$(basename "$name" .md)"
done

# Install skill
echo ""
echo "Installing skills..."
ln -sf "$SCRIPT_DIR/skills/tytos-standards/SKILL.md" "$CLAUDE_DIR/skills/tytos-standards/SKILL.md"
echo "  ✓ tytos-standards"

echo ""
echo "Installation complete!"
echo ""
echo "Available commands:"
echo "  /init-project <name>  — Scaffold a new project with Tytos standards"
echo "  /audit-project        — Scan current project for standards violations"
echo "  /fix-standards        — Auto-fix common violations"
echo ""
echo "To add standards enforcement to an existing project:"
echo "  cp $SCRIPT_DIR/project-template/CLAUDE.md ./CLAUDE.md"
echo "  cp -r $SCRIPT_DIR/project-template/.claude ./.claude"
echo "  chmod +x .claude/hooks/*.sh"
echo "  git add CLAUDE.md .claude/"
echo "  git commit -m 'chore: add Tytos team standards enforcement'"
echo ""
echo "Once committed, all team members get hooks and rules automatically on git pull."

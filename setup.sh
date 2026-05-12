#!/bin/bash
# setup.sh — Install OpenOCD review prompts as Claude Code skills and slash commands
#
# Usage:
#   ./setup.sh [--openocd-src <path>]
#
#   --openocd-src <path>   Path to your OpenOCD source tree clone.
#                          Defaults to ~/src/openocd or ~/Src/opensource/openocd
#                          if either exists, otherwise asks interactively.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$HOME/.claude/skills/openocd"
COMMANDS_DIR="$HOME/.claude/commands"

# --- Determine OpenOCD source path ---
OPENOCD_SRC=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --openocd-src)
            OPENOCD_SRC="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

if [[ -z "$OPENOCD_SRC" ]]; then
    # Try common default paths
    for candidate in \
        "$HOME/src/openocd" \
        "$HOME/Src/opensource/openocd" \
        "$HOME/openocd" \
        "/opt/openocd-src"; do
        if [[ -d "$candidate/src" && -f "$candidate/configure.ac" ]]; then
            OPENOCD_SRC="$candidate"
            echo "Auto-detected OpenOCD source: $OPENOCD_SRC"
            break
        fi
    done
fi

if [[ -z "$OPENOCD_SRC" ]]; then
    read -rp "Enter path to your OpenOCD source tree: " OPENOCD_SRC
fi

if [[ ! -d "$OPENOCD_SRC/src" || ! -f "$OPENOCD_SRC/configure.ac" ]]; then
    echo "ERROR: '$OPENOCD_SRC' does not look like an OpenOCD source tree."
    echo "Expected: $OPENOCD_SRC/src/ and $OPENOCD_SRC/configure.ac"
    exit 1
fi

OPENOCD_SRC="$(cd "$OPENOCD_SRC" && pwd)"
echo "OpenOCD source tree: $OPENOCD_SRC"

# --- Install ---
mkdir -p "$SKILLS_DIR"
mkdir -p "$COMMANDS_DIR"

# Install skill (auto-loaded in OpenOCD trees)
sed -e "s|{{OPENOCD_REVIEW_PROMPTS_DIR}}|$SCRIPT_DIR|g" \
    -e "s|{{OPENOCD_SRC}}|$OPENOCD_SRC|g" \
    "$SCRIPT_DIR/skills/openocd.md" \
    > "$SKILLS_DIR/SKILL.md"
echo "  Installed: $SKILLS_DIR/SKILL.md"

# Install slash commands
for cmd in openocd-review openocd-verify; do
    sed -e "s|{{REVIEW_DIR}}|$SCRIPT_DIR|g" \
        -e "s|{{OPENOCD_SRC}}|$OPENOCD_SRC|g" \
        "$SCRIPT_DIR/slash-commands/${cmd}.md" \
        > "$COMMANDS_DIR/${cmd}.md"
    echo "  Installed: $COMMANDS_DIR/${cmd}.md"
done

echo ""
echo "Installation complete."
echo ""
echo "Available commands:"
echo "  /openocd-review <change_id>         — full review of an OpenOCD Gerrit patch"
echo "  /openocd-review <id> skip-build     — review without building"
echo "  /openocd-verify                     — apply false-positive gates"
echo ""
echo "Gerrit: https://review.openocd.org"
echo "Source: $OPENOCD_SRC"

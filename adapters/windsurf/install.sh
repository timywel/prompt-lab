#!/bin/bash
# Windsurf Adapter Installer
# Symlinks skills/ to .windsurf/skills/ with relative path

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

safe_link() {
    local link="$1"
    local target="$2"
    local dir
    dir="$(dirname "$link")"
    mkdir -p "$dir"
    ([ -L "$link" ] && rm "$link") || ([ -d "$link" ] && rm -rf "$link") || true
    ln -sfn "$target" "$link"
}

safe_link ".windsurf/skills" "../skills"
echo "✅ Windsurf skills installed -> .windsurf/skills"
echo "   Target: $(readlink .windsurf/skills)"

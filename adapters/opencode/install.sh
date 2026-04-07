#!/bin/bash
# OpenCode Adapter Installer
# Symlinks to ~/.opencode/skills/prompt-lab

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

mkdir -p ~/.opencode/skills

([ -L ~/.opencode/skills/prompt-lab ] && rm ~/.opencode/skills/prompt-lab) || ([ -d ~/.opencode/skills/prompt-lab ] && rm -rf ~/.opencode/skills/prompt-lab) || true
ln -sfn "$PROJECT_ROOT" ~/.opencode/skills/prompt-lab

echo "✅ OpenCode skills installed -> ~/.opencode/skills/prompt-lab"
echo "   Target: $(readlink ~/.opencode/skills/prompt-lab)"

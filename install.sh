#!/bin/bash
# PRD Generator Cross-Platform Installer
# Supports Claude Code, Cursor, Windsurf, OpenCode interactive installation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   PRD Generator Installer v1.0.0             ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════╝${NC}"
echo ""

# Detect available platforms
echo -e "${YELLOW}Detecting available platforms...${NC}"

[ -d "$HOME/.claude" ] && echo -e "  ${GREEN}[✓]${NC} Claude Code ($HOME/.claude)"
[ -d "$HOME/.cursor" ] && echo -e "  ${GREEN}[✓]${NC} Cursor ($HOME/.cursor)"
[ -d "$HOME/.windsurf" ] && echo -e "  ${GREEN}[✓]${NC} Windsurf ($HOME/.windsurf)"
[ -d "$HOME/.opencode" ] && echo -e "  ${GREEN}[✓]${NC} OpenCode ($HOME/.opencode)"
[ -d "$HOME/.vscode/extensions" ] && echo -e "  ${GREEN}[✓]${NC} VSCode"

echo ""
echo -e "${YELLOW}Select installation option:${NC}"
echo "  1) Quick install (core: Claude Code + Cursor + Windsurf)"
echo "  2) Full install (core + OpenCode)"
echo "  3) Select platforms"
echo "  4) Show VSCode installation guide"
echo "  5) Uninstall all"
echo "  6) Exit"
echo ""

read -p "Choice [1-6]: " choice

# Safe symlink: removes existing file/dir/symlink before creating
safe_link() {
    local link="$1"
    local target="$2"
    local dir
    dir="$(dirname "$link")"
    mkdir -p "$dir"
    ([ -L "$link" ] && rm "$link") || ([ -d "$link" ] && rm -rf "$link") || true
    ln -sfn "$target" "$link"
}

do_install() {
    local name="$1"
    local dir="$2"
    local rel_target="$3"
    safe_link "$dir/skills" "$rel_target"
    echo -e "  ${GREEN}✓${NC} $name"
}

case "$choice" in
    1)
        echo -e "\n${BLUE}▶ Installing core platforms...${NC}"
        do_install "Claude Code" ".claude" "../skills"
        do_install "Cursor" ".cursor" "../skills"
        do_install "Windsurf" ".windsurf" "../skills"
        echo -e "\n${GREEN}✅ Done!${NC}"
        ;;
    2)
        echo -e "\n${BLUE}▶ Full install...${NC}"
        do_install "Claude Code" ".claude" "../skills"
        do_install "Cursor" ".cursor" "../skills"
        do_install "Windsurf" ".windsurf" "../skills"
        safe_link ~/.opencode/skills/prompt-lab "$PWD"
        echo -e "  ${GREEN}✓${NC} OpenCode"
        echo -e "\n${GREEN}✅ Done!${NC}"
        ;;
    3)
        echo -e "\n${YELLOW}Select platforms (e.g. a b c):${NC}"
        echo "  a) Claude Code  - project-level .claude/skills/"
        echo "  b) Cursor       - project-level .cursor/skills/"
        echo "  c) Windsurf     - project-level .windsurf/skills/"
        echo "  d) OpenCode     - global ~/.opencode/skills/prompt-lab"
        echo "  e) VSCode       - show install guide"
        read -p "Choice [e.g. a b c]: " platforms

        for p in $platforms; do
            case "$p" in
                a) do_install "Claude Code" ".claude" "../skills" ;;
                b) do_install "Cursor" ".cursor" "../skills" ;;
                c) do_install "Windsurf" ".windsurf" "../skills" ;;
                d)
                    mkdir -p ~/.opencode/skills
                    safe_link ~/.opencode/skills/prompt-lab "$PWD"
                    echo -e "  ${GREEN}✓${NC} OpenCode"
                    ;;
                e)
                    echo -e "\n${YELLOW}VSCode Installation Guide:${NC}"
                    echo "  Method 1: cp -r adapters/vscode ~/.vscode/extensions/prompt-lab-prd-generator"
                    echo "  Method 2: cd adapters/vscode && npm install -g @vscode/vsce && vsce package && code --install-extension prompt-lab-prd-generator-1.0.0.vsix"
                    ;;
            esac
        done
        echo -e "\n${GREEN}✅ Done!${NC}"
        ;;
    4)
        echo -e "\n${YELLOW}VSCode Installation Guide:${NC}"
        echo ""
        echo "  Method 1 (copy directory):"
        echo "    cp -r adapters/vscode ~/.vscode/extensions/prompt-lab-prd-generator"
        echo ""
        echo "  Method 2 (package + install):"
        echo "    cd adapters/vscode"
        echo "    npm install -g @vscode/vsce"
        echo "    vsce package"
        echo "    code --install-extension prompt-lab-prd-generator-1.0.0.vsix"
        echo ""
        echo "  After install: restart VSCode, Ctrl+Shift+P -> 'Show PRD Generator Skills'"
        ;;
    5)
        echo -e "\n${YELLOW}▶ Uninstalling...${NC}"
        ([ -L .claude/skills ] && rm .claude/skills) || ([ -d .claude/skills ] && rm -rf .claude/skills) || true
        ([ -L .cursor/skills ] && rm .cursor/skills) || ([ -d .cursor/skills ] && rm -rf .cursor/skills) || true
        ([ -L .windsurf/skills ] && rm .windsurf/skills) || ([ -d .windsurf/skills ] && rm -rf .windsurf/skills) || true
        ([ -L ~/.opencode/skills/prompt-lab ] && rm ~/.opencode/skills/prompt-lab) || true
        echo -e "${GREEN}✅ Done!${NC}"
        ;;
    6)
        echo "Exiting."
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice. Run the script again.${NC}"
        exit 1
        ;;
esac

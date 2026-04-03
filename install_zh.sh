#!/bin/bash
# PRD Generator 跨平台安装脚本
# 支持 Claude Code、Cursor、Windsurf、OpenCode 交互式安装

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   PRD Generator 安装脚本 v1.0.0             ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════╝${NC}"
echo ""

# 检测可用平台
echo -e "${YELLOW}检测可用平台...${NC}"

[ -d "$HOME/.claude" ] && echo -e "  ${GREEN}[✓]${NC} Claude Code ($HOME/.claude)"
[ -d "$HOME/.cursor" ] && echo -e "  ${GREEN}[✓]${NC} Cursor ($HOME/.cursor)"
[ -d "$HOME/.windsurf" ] && echo -e "  ${GREEN}[✓]${NC} Windsurf ($HOME/.windsurf)"
[ -d "$HOME/.opencode" ] && echo -e "  ${GREEN}[✓]${NC} OpenCode ($HOME/.opencode)"
[ -d "$HOME/.vscode/extensions" ] && echo -e "  ${GREEN}[✓]${NC} VSCode"

echo ""
echo -e "${YELLOW}选择安装方式：${NC}"
echo "  1) 快速安装（核心平台：Claude Code + Cursor + Windsurf）"
echo "  2) 全量安装（核心平台 + OpenCode）"
echo "  3) 选择平台安装"
echo "  4) 显示 VSCode 安装说明"
echo "  5) 卸载所有安装"
echo "  6) 退出"
echo ""

read -p "选择 [1-6]: " choice

do_install() {
    local name="$1"
    local dir="$2"
    local target="$3"
    [ -d "$dir/skills" ] && [ ! -L "$dir/skills" ] && rm -rf "$dir/skills" || true
    mkdir -p "$dir" && ln -sfn "$target" "$dir/skills"
    echo -e "  ${GREEN}✓${NC} $name"
}

case "$choice" in
    1)
        echo -e "\n${BLUE}▶ 安装核心平台...${NC}"
        do_install "Claude Code" ".claude" "$(pwd)/skills"
        do_install "Cursor" ".cursor" "$(pwd)/skills"
        do_install "Windsurf" ".windsurf" "$(pwd)/skills"
        echo -e "\n${GREEN}✅ 完成！${NC}"
        ;;
    2)
        echo -e "\n${BLUE}▶ 全量安装...${NC}"
        do_install "Claude Code" ".claude" "$(pwd)/skills"
        do_install "Cursor" ".cursor" "$(pwd)/skills"
        do_install "Windsurf" ".windsurf" "$(pwd)/skills"
        [ -d ~/.opencode/skills/prompt-lab ] && [ ! -L ~/.opencode/skills/prompt-lab ] && rm -rf ~/.opencode/skills/prompt-lab || true
        mkdir -p ~/.opencode/skills && ln -sfn "$(pwd)/skills" ~/.opencode/skills/prompt-lab
        echo -e "  ${GREEN}✓${NC} OpenCode"
        echo -e "\n${GREEN}✅ 完成！${NC}"
        ;;
    3)
        echo -e "\n${YELLOW}选择平台（输入编号，空格分隔）：${NC}"
        echo "  a) Claude Code  - 项目级 .claude/skills/"
        echo "  b) Cursor       - 项目级 .cursor/skills/"
        echo "  c) Windsurf     - 项目级 .windsurf/skills/"
        echo "  d) OpenCode     - 全局 ~/.opencode/skills/prompt-lab"
        echo "  e) VSCode       - 显示安装说明"
        read -p "选择 [例如: a b c]: " platforms

        for p in $platforms; do
            case "$p" in
                a) do_install "Claude Code" ".claude" "$(pwd)/skills" ;;
                b) do_install "Cursor" ".cursor" "$(pwd)/skills" ;;
                c) do_install "Windsurf" ".windsurf" "$(pwd)/skills" ;;
                d)
                    mkdir -p ~/.opencode/skills && ln -sfn "$(pwd)/skills" ~/.opencode/skills/prompt-lab
                    echo -e "  ${GREEN}✓${NC} OpenCode"
                    ;;
                e)
                    echo -e "\n${YELLOW}VSCode 安装说明：${NC}"
                    echo "  方式一: cp -r adapters/vscode ~/.vscode/extensions/prompt-lab-prd-generator"
                    echo "  方式二: cd adapters/vscode && npm install -g @vscode/vsce && vsce package && code --install-extension prompt-lab-prd-generator-1.0.0.vsix"
                    ;;
            esac
        done
        echo -e "\n${GREEN}✅ 完成！${NC}"
        ;;
    4)
        echo -e "\n${YELLOW}VSCode 安装说明：${NC}"
        echo ""
        echo "  方式一（复制目录）:"
        echo "    cp -r adapters/vscode ~/.vscode/extensions/prompt-lab-prd-generator"
        echo ""
        echo "  方式二（打包安装）:"
        echo "    cd adapters/vscode"
        echo "    npm install -g @vscode/vsce"
        echo "    vsce package"
        echo "    code --install-extension prompt-lab-prd-generator-1.0.0.vsix"
        echo ""
        echo "  安装后重启 VSCode，使用 Ctrl+Shift+P -> '显示 PRD 生成器技能库'"
        ;;
    5)
        echo -e "\n${YELLOW}▶ 卸载...${NC}"
        [ -L .claude/skills ] && rm .claude/skills || true
        [ -L .cursor/skills ] && rm .cursor/skills || true
        [ -L .windsurf/skills ] && rm .windsurf/skills || true
        [ -L ~/.opencode/skills/prompt-lab ] && rm ~/.opencode/skills/prompt-lab || true
        echo -e "${GREEN}✅ 完成！${NC}"
        ;;
    6)
        echo "退出。"
        exit 0
        ;;
    *)
        echo -e "${RED}无效选择，请重新运行。${NC}"
        exit 1
        ;;
esac

#!/bin/bash
# Claude Code 适配器安装脚本
# 将根目录 skills/ 符号链接到 .claude/skills/

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

mkdir -p "$PROJECT_ROOT/.claude"
# 如果 .claude/skills 是目录（残留），先移除
[ -d "$PROJECT_ROOT/.claude/skills" ] && [ ! -L "$PROJECT_ROOT/.claude/skills" ] && rm -rf "$PROJECT_ROOT/.claude/skills"
ln -sfn "$PROJECT_ROOT/skills" "$PROJECT_ROOT/.claude/skills"

echo "✅ Claude Code: skills 已链接到 .claude/skills/"
echo "   目标: $(readlink "$PROJECT_ROOT/.claude/skills")"

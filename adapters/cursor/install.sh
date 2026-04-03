#!/bin/bash
# Cursor 适配器安装脚本
# 将根目录 skills/ 符号链接到 .cursor/skills/

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

mkdir -p "$PROJECT_ROOT/.cursor"
# 如果 .cursor/skills 是目录（残留），先移除
[ -d "$PROJECT_ROOT/.cursor/skills" ] && [ ! -L "$PROJECT_ROOT/.cursor/skills" ] && rm -rf "$PROJECT_ROOT/.cursor/skills"
ln -sfn "$PROJECT_ROOT/skills" "$PROJECT_ROOT/.cursor/skills"

echo "✅ Cursor: skills 已链接到 .cursor/skills/"
echo "   目标: $(readlink "$PROJECT_ROOT/.cursor/skills")"

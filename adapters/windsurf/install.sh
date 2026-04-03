#!/bin/bash
# Windsurf 适配器安装脚本
# 将根目录 skills/ 符号链接到 .windsurf/skills/

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

mkdir -p "$PROJECT_ROOT/.windsurf"
# 如果 .windsurf/skills 是目录（残留），先移除
[ -d "$PROJECT_ROOT/.windsurf/skills" ] && [ ! -L "$PROJECT_ROOT/.windsurf/skills" ] && rm -rf "$PROJECT_ROOT/.windsurf/skills"
ln -sfn "$PROJECT_ROOT/skills" "$PROJECT_ROOT/.windsurf/skills"

echo "✅ Windsurf: skills 已链接到 .windsurf/skills/"
echo "   目标: $(readlink "$PROJECT_ROOT/.windsurf/skills")"

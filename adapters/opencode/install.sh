#!/bin/bash
# OpenCode 适配器安装脚本
# 将根目录 skills/ 符号链接到 ~/.opencode/skills/prompt-lab

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

mkdir -p ~/.opencode/skills
ln -sfn "$PROJECT_ROOT" ~/.opencode/skills/prompt-lab

echo "✅ OpenCode: skills 已安装到 ~/.opencode/skills/prompt-lab"
echo "   目标: $(readlink ~/.opencode/skills/prompt-lab)"

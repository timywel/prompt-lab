.PHONY: install install-claude install-cursor install-windsurf install-opencode install-vscode install-all uninstall clean help

# 默认安装 Claude Code + Cursor + Windsurf
install: install-claude install-cursor install-windsurf
	@echo ""
	@echo "✅ 核心平台安装完成：Claude Code, Cursor, Windsurf"
	@echo "   如需安装其他平台：make install-opencode / make install-vscode"
	@echo "   或运行 ./install.sh 交互式安装"

install-claude:
	@mkdir -p .claude && [ -d .claude/skills ] && [ ! -L .claude/skills ] && rm -rf .claude/skills || true
	@ln -sfn $(PWD)/skills .claude/skills
	@echo "✅ Claude Code skills installed -> .claude/skills"

install-cursor:
	@mkdir -p .cursor && [ -d .cursor/skills ] && [ ! -L .cursor/skills ] && rm -rf .cursor/skills || true
	@ln -sfn $(PWD)/skills .cursor/skills
	@echo "✅ Cursor skills installed -> .cursor/skills"

install-windsurf:
	@mkdir -p .windsurf && [ -d .windsurf/skills ] && [ ! -L .windsurf/skills ] && rm -rf .windsurf/skills || true
	@ln -sfn $(PWD)/skills .windsurf/skills
	@echo "✅ Windsurf skills installed -> .windsurf/skills"

install-opencode:
	@[ -d ~/.opencode/skills/prompt-lab ] && [ ! -L ~/.opencode/skills/prompt-lab ] && rm -rf ~/.opencode/skills/prompt-lab || true
	@mkdir -p ~/.opencode/skills && ln -sfn $(PWD)/skills ~/.opencode/skills/prompt-lab
	@echo "✅ OpenCode skills installed -> ~/.opencode/skills/prompt-lab"

install-vscode:
	@echo "⚠️  VSCode 扩展安装方式："
	@echo "   方式一（复制目录）:"
	@echo "     cp -r adapters/vscode ~/.vscode/extensions/prompt-lab-prd-generator"
	@echo "   方式二（打包安装）:"
	@echo "     cd adapters/vscode && npm install -g @vscode/vsce && vsce package && code --install-extension prompt-lab-prd-generator-1.0.0.vsix"
	@echo "   安装后重启 VSCode，使用 Ctrl+Shift+P -> '显示 PRD 生成器技能库'"

install-all: install install-opencode
	@echo ""
	@echo "✅ 全部平台安装完成"

uninstall:
	@[ -L .claude/skills ] && rm .claude/skills || true
	@[ -L .cursor/skills ] && rm .cursor/skills || true
	@[ -L .windsurf/skills ] && rm .windsurf/skills || true
	@[ -L ~/.opencode/skills/prompt-lab ] && rm ~/.opencode/skills/prompt-lab || true
	@echo "✅ All skill symlinks removed"

clean:
	@find . -type l -name "skills" -delete 2>/dev/null || true
	@echo "✅ Symlinks cleaned"

help:
	@echo "PRD Generator 跨平台分发架构 - Makefile"
	@echo ""
	@echo "用法:"
	@echo "  make install          安装核心平台（Claude Code, Cursor, Windsurf）"
	@echo "  make install-claude   仅安装 Claude Code"
	@echo "  make install-cursor   仅安装 Cursor"
	@echo "  make install-windsurf 仅安装 Windsurf"
	@echo "  make install-opencode 仅安装 OpenCode（全局）"
	@echo "  make install-vscode   显示 VSCode 安装说明"
	@echo "  make install-all      安装所有平台"
	@echo "  make uninstall        卸载所有符号链接"
	@echo "  make clean            清理符号链接"
	@echo "  make help             显示本帮助"
	@echo ""
	@echo "或运行 ./install.sh 进行交互式安装"

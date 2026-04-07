.PHONY: install install-claude install-cursor install-windsurf install-opencode install-vscode install-all uninstall clean help

# 默认安装 Claude Code + Cursor + Windsurf
install: install-claude install-cursor install-windsurf
	@echo ""
	@echo "✅ Core platforms installed: Claude Code, Cursor, Windsurf"
	@echo "   For other platforms: make install-opencode / make install-vscode"
	@echo "   Or run ./install.sh for interactive install"

# 安装单个平台：使用相对路径，支持任意位置克隆
install-claude:
	@mkdir -p .claude
	@([ -L .claude/skills ] && rm .claude/skills) || ([ -d .claude/skills ] && rm -rf .claude/skills) || true
	@ln -sfn ../skills .claude/skills
	@echo "✅ Claude Code skills installed -> .claude/skills"

install-cursor:
	@mkdir -p .cursor
	@([ -L .cursor/skills ] && rm .cursor/skills) || ([ -d .cursor/skills ] && rm -rf .cursor/skills) || true
	@ln -sfn ../skills .cursor/skills
	@echo "✅ Cursor skills installed -> .cursor/skills"

install-windsurf:
	@mkdir -p .windsurf
	@([ -L .windsurf/skills ] && rm .windsurf/skills) || ([ -d .windsurf/skills ] && rm -rf .windsurf/skills) || true
	@ln -sfn ../skills .windsurf/skills
	@echo "✅ Windsurf skills installed -> .windsurf/skills"

install-opencode:
	@([ -L ~/.opencode/skills/prompt-lab ] && rm ~/.opencode/skills/prompt-lab) || ([ -d ~/.opencode/skills/prompt-lab ] && rm -rf ~/.opencode/skills/prompt-lab) || true
	@mkdir -p ~/.opencode/skills && ln -sfn "$(pwd)" ~/.opencode/skills/prompt-lab
	@echo "✅ OpenCode skills installed -> ~/.opencode/skills/prompt-lab"

install-vscode:
	@echo "⚠️  VSCode extension installation:"
	@echo "   Method 1 (copy directory):"
	@echo "     cp -r adapters/vscode ~/.vscode/extensions/prompt-lab-prd-generator"
	@echo "   Method 2 (package + install):"
	@echo "     cd adapters/vscode && npm install -g @vscode/vsce && vsce package && code --install-extension prompt-lab-prd-generator-1.0.0.vsix"
	@echo "   After install: restart VSCode, Ctrl+Shift+P -> 'Show PRD Generator Skills'"

install-all: install install-opencode
	@echo ""
	@echo "✅ All platforms installed"

uninstall:
	@([ -L .claude/skills ] && rm .claude/skills) || ([ -d .claude/skills ] && rm -rf .claude/skills) || true
	@([ -L .cursor/skills ] && rm .cursor/skills) || ([ -d .cursor/skills ] && rm -rf .cursor/skills) || true
	@([ -L .windsurf/skills ] && rm .windsurf/skills) || ([ -d .windsurf/skills ] && rm -rf .windsurf/skills) || true
	@([ -L ~/.opencode/skills/prompt-lab ] && rm ~/.opencode/skills/prompt-lab) || true
	@echo "✅ All skill symlinks removed"

clean:
	@find . -type l -name "skills" -delete 2>/dev/null || true
	@echo "✅ Symlinks cleaned"

help:
	@echo "PRD Generator Cross-Platform Installer - Makefile"
	@echo ""
	@echo "Usage:"
	@echo "  make install           Install core (Claude Code + Cursor + Windsurf)"
	@echo "  make install-claude    Claude Code only"
	@echo "  make install-cursor    Cursor only"
	@echo "  make install-windsurf  Windsurf only"
	@echo "  make install-opencode  OpenCode only (global)"
	@echo "  make install-vscode   VSCode instructions"
	@echo "  make install-all      All platforms"
	@echo "  make uninstall        Remove all symlinks"
	@echo "  make clean            Clean symlinks"
	@echo "  make help             Show this help"
	@echo ""
	@echo "Or run ./install.sh for interactive installation"

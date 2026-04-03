# Claude Code 适配器

本适配器将根目录 `skills/` 符号链接到 Claude Code 的项目级 skills 目录。

## 安装方式

### 自动安装（推荐）
```bash
cd prompt-lab
make install-claude
# 或
./adapters/claude-code/install.sh
```

### 手动安装
```bash
mkdir -p .claude
ln -sfn ../skills .claude/skills
```

## 工作原理

Claude Code 在项目级读取 `.claude/skills/` 目录中的技能。
本适配器通过符号链接，将共享的 `skills/` 目录映射到该位置，
实现一次维护，多端同步。

## 验证安装

安装后，重新加载 Claude Code 项目，技能应自动出现在 `/skills` 命令中。

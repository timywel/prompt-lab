# Cursor 适配器

本适配器将根目录 `skills/` 符号链接到 Cursor 的项目级 skills 目录。

## 安装方式

### 自动安装（推荐）
```bash
cd prompt-lab
make install-cursor
# 或
./adapters/cursor/install.sh
```

### 手动安装
```bash
mkdir -p .cursor
ln -sfn ../skills .cursor/skills
```

## 工作原理

Cursor 使用与 Claude Code 兼容的 skill 格式。
通过符号链接共享 `skills/` 目录，实现跨平台技能同步。

## 验证安装

安装后，在 Cursor 中触发 skill 命令（如 `/prd-autofill`）验证加载。

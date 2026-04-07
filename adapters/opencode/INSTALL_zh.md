# OpenCode 适配器

本适配器将技能库符号链接到 OpenCode 的全局 skills 目录。

## 安装方式

### 自动安装（推荐）
```bash
cd prompt-lab
make install-opencode
# 或
./adapters/opencode/install.sh
```

### 手动安装
```bash
mkdir -p ~/.opencode/skills
ln -sfn "$(pwd)" ~/.opencode/skills/prompt-lab
```

## 工作原理

OpenCode 使用 `~/.opencode/skills/` 作为全局技能目录。
安装后，skills 作为名为 `prompt-lab` 的技能模块可用。

**入口点**：所有 PRD 生成请求首先被 `prd-dispatcher` 捕获，
分析复杂度后与您确认路由方案，再委托给对应技能执行。

## 验证安装

安装后，在 OpenCode 中运行 `/prompt-lab` 或查看技能列表验证。

## 快速使用

说出 `"帮我生成PRD"`，调度器将引导您完成路由选择。

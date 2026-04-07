# Windsurf 适配器

本适配器将根目录 `skills/` 符号链接到 Windsurf 的项目级 skills 目录。

## 安装方式

### 自动安装（推荐）
```bash
cd prompt-lab
make install-windsurf
# 或
./adapters/windsurf/install.sh
```

### 手动安装
```bash
mkdir -p .windsurf
ln -sfn ../skills .windsurf/skills
```

## 工作原理

Windsurf 使用与 Claude Code 兼容的 skill 格式。
通过符号链接共享 `skills/` 目录，实现跨平台技能同步。

**入口点**：所有 PRD 生成请求首先被 `prd-dispatcher` 捕获，
分析复杂度后与您确认路由方案，再委托给对应技能执行。

## 验证安装

安装后，在 Windsurf 中触发 skill 命令验证加载。

## 快速使用

说出 `"帮我生成PRD"`，调度器将引导您完成路由选择。

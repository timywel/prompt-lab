# PRD Generator

[![GitHub](https://img.shields.io/badge/GitHub-timywel-181717?style=flat-square&logo=github)](https://github.com/timywel)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Claude%20Code%20%7C%20Cursor%20%7C%20Windsurf%20%7C%20OpenCode%20%7C%20VSCode-blue?style=flat-square)](https://github.com/timywel/prompt-lab)

**作者 & 维护者**: [timywel](https://github.com/timywel)

---

PRD Generator 是一套 AI 原生的产品需求文档（PRD）生成系统。它不是简单的模板填充工具，而是一套由 8 个专业技能组成的**智能协作网络**——从一句话需求到可执行 PRD，只需几轮对话。

## 项目能力

### 核心能力矩阵

| 能力维度 | 说明 |
|---------|------|
| **多入口接入** | 一句话想法 → 交钥匙 PRD；或多轮对话逐步澄清 |
| **智能路由** | 自动分析需求复杂度，匹配最优生成策略 |
| **深度扩展** | 架构设计 / UI/UX / 工程化 / 测试 / 边界条件 / 运维 |
| **质量门禁** | 自动审查 PRD 常见缺陷，修复后输出质量报告 |
| **专业评审** | 6 维度评审团（技术架构、产品设计、工程实现、可执行性、UI/UX、测试策略） |
| **安全加固** | 威胁建模 / 隐私合规 / 数据加密 / API 鉴权 — 登录/支付/数据场景自动触发 |
| **性能剖析** | 性能测试计划 / 平台工具指南 / 基准指标 / 回归检测 — 高性能场景自动触发 |

### 工作流示意

```
用户输入（一句话想法）
    │
    ▼
┌─────────────────┐
│  Orchestrator   │ ← 智能路由：分析复杂度
│  协调层         │
└────────┬────────┘
         │
    ┌────┴────┬──────────┬──────────┐
    ▼         ▼          ▼          ▼
Autofill  Conversational  Deep-Expand  （按需组合）
    │         │             │
    └────┬────┴─────────────┘
         ▼
┌─────────────────┐
│   PRD-QA        │ ← 质量门禁：审查 + 修复
│   质检与修复    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Review-Panel   │ ← 6维度评审团
│  评审团         │
└────────┬────────┘
         │
    可选触发 ▼
┌──────────────────┐  ┌──────────────────────┐
│ Security-Analysis │  │ Performance-Profile │
│ 安全分析          │  │ 性能剖析             │
└──────────────────┘  └──────────────────────┘
         │
         ▼
   最终 PRD 文档
```

### 技能一览

| 技能 | 触发场景 | 核心价值 |
|------|----------|----------|
| `prd-autofill` | 快速启动 | 一句话进，详细 PRD 出 |
| `prd-conversational` | 需求模糊 | 多轮引导，精准澄清 |
| `prd-deep-expand` | 深度需求 | 6 维度全面扩展 |
| `prd-orchestrator` | 通用入口 | 智能分析，自动路由 |
| `prd-qa` | 质量把关 | 自动审查 + 修复 |
| `prd-review-panel` | 评审阶段 | 6 维度综合评分 |
| `prd-security-analysis` | 安全相关 | 威胁建模 / 合规 / 加密 |
| `prd-performance-profile` | 性能相关 | 测试计划 / 基准指标 |

---

## 快速开始

### 方式一：交互式安装（推荐）
```bash
./install.sh
```

### 方式二：Makefile 安装
```bash
# 安装核心平台（Claude Code + Cursor + Windsurf）
make install

# 安装所有平台
make install-all

# 安装特定平台
make install-claude   # Claude Code
make install-cursor    # Cursor
make install-windsurf  # Windsurf
make install-opencode  # OpenCode（全局）
```

## 支持的平台

| 平台 | 安装方式 | 详情 |
|------|----------|------|
| Claude Code | `make install-claude` | 项目级 `.claude/skills/` |
| Cursor | `make install-cursor` | 项目级 `.cursor/skills/` |
| Windsurf | `make install-windsurf` | 项目级 `.windsurf/skills/` |
| OpenCode | `make install-opencode` | 全局 `~/.opencode/skills/prompt-lab` |
| VSCode | 手动安装 | 参考 `adapters/vscode/README.md` |

## 项目结构

```
prompt-lab/
├── skills/                    # 规范技能源（所有平台共用）
│   ├── _registry.yaml         # 技能注册表
│   ├── _shared/               # 共享知识库
│   │   ├── platform-configs/  # iOS/macOS 配置模板
│   │   ├── qa-checks/         # 自检清单
│   │   └── test-templates/    # 测试金字塔
│   └── prd-*/                 # 8个技能模块
├── adapters/                  # 各平台适配器
│   ├── claude-code/          # Claude Code
│   ├── cursor/               # Cursor
│   ├── windsurf/             # Windsurf
│   ├── opencode/             # OpenCode
│   └── vscode/               # VSCode 扩展
├── docs/                      # 项目文档（PRD/评审/规范）
├── Makefile                   # 跨平台安装/卸载
├── install.sh                 # 交互式安装脚本
└── README.md
```

## 卸载

```bash
make uninstall
# 或运行 ./install.sh 选择"卸载"
```

## 本地保留目录

以下目录包含本地集成文件，**不会**上传到仓库：
- `tmp/` — 会话临时文件
- `baize-loop/` — 本地集成

## 相关文档

- [Claude Code 适配器](adapters/claude-code/README.md)
- [Cursor 适配器](adapters/cursor/README.md)
- [Windsurf 适配器](adapters/windsurf/README.md)
- [OpenCode 适配器](adapters/opencode/INSTALL.md)
- [VSCode 适配器](adapters/vscode/README.md)

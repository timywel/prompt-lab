# PRD Generator 跨平台分发架构

[![GitHub](https://img.shields.io/badge/GitHub-timywel-181717?style=flat-square&logo=github)](https://github.com/timywel)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

**作者 & 维护者**: [timywel](https://github.com/timywel)

PRD 生成器技能库的跨平台分发解决方案，支持 Claude Code、Cursor、Windsurf、OpenCode 和 VSCode。

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

## 技能库

本项目包含 8 个 PRD 生成器技能：

| 技能 | 说明 |
|------|------|
| `prd-autofill` | 全自动 PRD 生成器：输入一句话想法，自动补全技术细节 |
| `prd-conversational` | 交互式 PRD 构建器：通过多轮引导对话探测需求 |
| `prd-deep-expand` | 深度扩展型：从初步PRD扩展架构/UI/UX/工程化/测试等维度 |
| `prd-orchestrator` | 协调层：分析输入复杂度，智能路由 |
| `prd-qa` | 质检与修复：自动审查 + 修复常见问题 |
| `prd-review-panel` | 评审团：自动调度6维度评审 |
| `prd-security-analysis` | 安全分析扩展：威胁建模、隐私合规、数据加密 |
| `prd-performance-profile` | 性能剖析扩展：性能测试计划、基准指标 |

详细说明见 `skills/` 目录。

## 项目结构

```
prompt-lab/
├── skills/                    # 规范技能源（所有平台共用）
│   ├── _registry.yaml
│   ├── _shared/               # 共享知识库
│   └── prd-*/                 # 8个技能
├── adapters/                  # 各平台适配器
│   ├── claude-code/
│   ├── cursor/
│   ├── windsurf/
│   ├── opencode/
│   └── vscode/
├── Makefile                   # 跨平台安装
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
- `tmp/` - 会话临时文件
- `baize-loop/` - 本地集成

## 相关文档

- [Claude Code 适配器](adapters/claude-code/README.md)
- [Cursor 适配器](adapters/cursor/README.md)
- [Windsurf 适配器](adapters/windsurf/README.md)
- [OpenCode 适配器](adapters/opencode/INSTALL.md)
- [VSCode 适配器](adapters/vscode/README.md)

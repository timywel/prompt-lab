# README 富视觉增强设计方案

## 状态

已接受

## 日期

2026-04-07

## 背景

当前 README.md 只有 ASCII 流程图和表格，缺乏数据解释图、架构可视化等富视觉内容。需要增强为平衡风格（技术细节 + 视觉美感兼顾）。

## 设计决策

### 图形格式

使用 **Mermaid** — 直接嵌入 Markdown，GitHub/GitLab 原生渲染，无需额外工具维护。

### README 增强结构

```
README.md
│
├── Hero Section
│   ├── Badges (保留)
│   ├── 项目名称 + 一句话定位
│   └── Hero 架构总图（Mermaid flowchart）
│
├── 1. Project Capabilities
│   ├── Capability Matrix (表格 → 能力雷达图 Mermaid)
│   └── 8 Skills Overview Cards (图标 + 简述)
│
├── 2. Workflow Deep Dive
│   ├── 2.1 全局调用链图（Orchestrator 决策树）
│   ├── 2.2 数据流穿越图（PRD 状态变化）
│   └── 2.3 技能协作关系图（依赖调用）
│
├── 3. Skill Deep Dives
│   ├── prd-autofill: 6步流水线图
│   ├── prd-conversational: 15问状态机图
│   ├── prd-orchestrator: 复杂度决策树图
│   ├── prd-qa: 13维度质检图
│   └── 其他4个技能: 简图 + 触发关键词
│
├── 4. Platform Support (保留表格)
├── 5. Quick Start (保留)
├── 6. Project Structure (保留表格)
└── 7. Uninstall (保留)
└── 8. Locally Preserved (保留)
```

### Mermaid 图清单

| # | 图类型 | Mermaid 类型 | 内容 |
|---|--------|-------------|------|
| 1 | Hero Flow | flowchart | 用户输入 → Orchestrator → 各技能 → PRD 输出 |
| 2 | Orchestrator 决策树 | flowchart TB | 复杂度判断 → 路由到 A/B/C |
| 3 | 数据流穿越图 | flowchart LR | PRD 在技能间的状态变化（草稿→填充→扩展→质检→评审→定稿）|
| 4 | 技能协作关系图 | flowchart | 技能间依赖和调用关系 |
| 5 | Autofill 流水线 | flowchart LR | 意图识别→知识检索→技术推断→量化填充→PRD组装→自检 |
| 6 | Conversational 状态机 | stateDiagram-v2 | 4阶段 × 15问的状态流转 |
| 7 | QA 质检雷达图 | xychart-beta | 13维度质检评分可视化 |

### 风格原则

- **平衡风格**：技术细节 + 视觉美感兼顾
- Mermaid 图使用 `%%{init: {'theme': 'base'}}%%` 主题，保持浅色清爽风格
- 保留所有表格和代码块（安装命令等）
- 中文版 README_zh.md 同步更新

## 实施步骤

1. 重写 README.md 根目录，嵌入所有 Mermaid 图
2. 同步更新 README_zh.md 中文版
3. 提交并推送

## 风险

- GitHub 渲染 Mermaid 需要启用[相关支持](https://github.blog/changelog/2022-06-14-render-mermaid-diagrams-in-markdown-fields/)，现代版本均支持

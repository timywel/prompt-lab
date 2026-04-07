# PRD Generator

[![GitHub](https://img.shields.io/badge/GitHub-timywel-181717?style=flat-square&logo=github)](https://github.com/timywel)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Claude%20Code%20%7C%20Cursor%20%7C%20Windsurf%20%7C%20OpenCode%20%7C%20VSCode-blue?style=flat-square)](https://github.com/timywel/prompt-lab)

**作者 & 维护者**: [timywel](https://github.com/timywel)

---

PRD Generator 是一套 AI 原生的产品需求文档（PRD）生成系统。它不是简单的模板填充工具，而是一套由 **8 个专业技能**组成的智能协作网络——从一句话需求到可执行 PRD，只需几轮对话。

---

## 1. 架构总览

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#e1f5fe', 'primaryTextColor': '#0277bd', 'primaryBorderColor': '#0277bd', 'lineColor': '#546e7a', 'secondaryColor': '#f3e5f5', 'tertiaryColor': '#fff8e1'}}}%%
flowchart LR
    subgraph INPUT[" "]
        direction TB
        A["👤 用户输入<br/><small>一句话想法</small>"]
    end

    subgraph ORCH[" "]
        direction TB
        B["Orchestrator<br/><small>智能路由</small>"]
    end

    subgraph CORE[" "]
        direction TB
        C1["Autofill"]
        C2["Conversational"]
        C3["Deep-Expand"]
    end

    subgraph QA[" "]
        direction TB
        D["PRD-QA<br/><small>质量门禁</small>"]
    end

    subgraph REVIEW[" "]
        direction TB
        E["Review-Panel<br/><small>6维度评审</small>"]
    end

    subgraph OPTIONAL[" "]
        direction TB
        F1["Security-Analysis"] --> F2["Performance-Profile"]
    end

    subgraph OUTPUT[" "]
        direction TB
        G["📄 最终 PRD 文档"]
    end

    INPUT --> ORCH
    ORCH --> CORE
    CORE --> QA
    QA --> REVIEW
    REVIEW --> OPTIONAL
    REVIEW --> OUTPUT

    style INPUT fill:#e1f5fe,stroke:#0277bd,color:#01579b
    style ORCH fill:#fff8e1,stroke:#f9a825,color:#f57f17
    style CORE fill:#e8f5e9,stroke:#43a047,color:#1b5e20
    style QA fill:#fce4ec,stroke:#e91e63,color:#880e4f
    style REVIEW fill:#f3e5f5,stroke:#8e24aa,color:#4a148c
    style OPTIONAL fill:#e0f7fa,stroke:#00acc1,color:#006064
    style OUTPUT fill:#e1f5fe,stroke:#0277bd,color:#01579b
```

---

## 2. 项目能力

### 能力雷达

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#e1f5fe', 'axisLabelColor': '#37474f'}}}%%
xychart-beta
    title "PRD Generator 能力覆盖"
    x-axis [ "多入口", "智能路由", "深度扩展", "质量门禁", "专业评审", "安全加固", "性能剖析" ]
    y-axis "覆盖率" 0 --> 100
    bar [95, 90, 85, 92, 88, 80, 75]
    line [95, 90, 85, 92, 88, 80, 75]
```

| 能力维度 | 说明 |
|---------|------|
| **多入口接入** | 一句话想法 → 交钥匙 PRD；或多轮对话逐步澄清 |
| **智能路由** | 自动分析需求复杂度，匹配最优生成策略 |
| **深度扩展** | 架构设计 / UI/UX / 工程化 / 测试 / 边界条件 / 运维 |
| **质量门禁** | 自动审查 PRD 常见缺陷，修复后输出质量报告 |
| **专业评审** | 6 维度评审团（技术架构、产品设计、工程实现、可执行性、UI/UX、测试策略） |
| **安全加固** | 威胁建模 / 隐私合规 / 数据加密 / API 鉴权 — 登录/支付/数据场景自动触发 |
| **性能剖析** | 性能测试计划 / 平台工具指南 / 基准指标 / 回归检测 — 高性能场景自动触发 |

---

## 3. 工作流详解

### 3.1 Orchestrator 决策树

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#fff8e1'}}}%%
flowchart TB
    START(["👤 用户输入<br/>例如 '帮我生成PRD'"]) --> ANALYZE

    ANALYZE{分析<br/>复杂度?}
    ANALYZE -->|简单型<br/>< 100字| SOLUTION_A[方案A<br/>prd-autofill]
    ANALYZE -->|已有PRD| SOLUTION_C[方案C<br/>prd-deep-expand]
    ANALYZE -->|复杂型<br/>> 200字| SOLUTION_B[方案B<br/>prd-conversational]
    ANALYZE -->|不确定型<br/>描述模糊| SOLUTION_B2[方案B<br/>需求挖掘]

    SOLUTION_A --> QA[PRD-QA<br/>质量门禁]
    SOLUTION_B --> SOLUTION_A2[方案A<br/>技术细节]
    SOLUTION_A2 --> SOLUTION_C2[方案C<br/>深度扩展]
    SOLUTION_C2 --> QA
    SOLUTION_B2 --> REVAL{重新评估?}
    REVAL -->|仍然模糊| SOLUTION_B
    REVAL -->|足够清晰| SOLUTION_A
    SOLUTION_C --> QA

    QA -->|通过| PANEL{需要<br/>评审?}
    QA -->|未通过| FIX[自动修复<br/>问题]
    FIX --> QA

    PANEL -->|是| REVIEW[Review-Panel<br/>6维度评审]
    PANEL -->|否| FINAL[最终 PRD]

    REVIEW -->|涉及安全| SECURITY[Security-Analysis<br/>安全分析]
    REVIEW -->|涉及性能| PERFORMANCE[Performance-Profile<br/>性能剖析]
    SECURITY --> FINAL2[最终 PRD]
    PERFORMANCE --> FINAL2

    style START fill:#e1f5fe,stroke:#0277bd
    style ANALYZE fill:#fff8e1,stroke:#f9a825
    style SOLUTION_A fill:#e8f5e9,stroke:#43a047
    style SOLUTION_B fill:#e8f5e9,stroke:#43a047
    style SOLUTION_C fill:#e8f5e9,stroke:#43a047
    style QA fill:#fce4ec,stroke:#e91e63
    style REVIEW fill:#f3e5f5,stroke:#8e24aa
    style FINAL fill:#e1f5fe,stroke:#0277bd
    style FINAL2 fill:#e1f5fe,stroke:#0277bd
```

### 3.2 PRD 数据流穿越图

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#e1f5fe'}}}%%
flowchart LR
    subgraph S1["方案A: prd-autofill"]
        D1["草稿 PRD<br/><small>原始想法</small>"] --> T1["技术填充<br/><small>平台 + APIs</small>"]
        T1 --> Q1["量化 PRD<br/><small>指标已填</small>"]
    end

    subgraph S2["方案B: prd-conversational"]
        D2["模糊输入"] --> G1["引导问答<br/><small>15个问题</small>"]
        G1 --> G2["澄清输入<br/><small>用户已确认</small>"]
    end

    subgraph S3["方案C: prd-deep-expand"]
        P3["初步 PRD"] --> E1["6维扩展<br/><small>架构/UI/工程/测试/边界/运维</small>"]
        E1 --> E2["扩展 PRD<br/><small>全面完整</small>"]
    end

    subgraph QA["PRD-QA"]
        QUA["原始输出"] --> QUB["13维审查<br/><small>发现问题</small>"]
        QUB --> QUC["自动修复<br/><small>应用diff</small>"]
        QUC --> QUD["质量报告<br/><small>评分卡</small>"]
    end

    subgraph RP["Review-Panel"]
        R1["待评审 PRD"] --> R2["6维评分<br/><small>雷达图</small>"]
        R2 --> R3["聚合报告<br/><small>最终结论</small>"]
    end

    subgraph SEC["Security-Analysis"]
        S1A["安全关键词"] --> S1B["STRIDE 威胁模型"]
        S1B --> S1C["合规映射"]
        S1C --> S1D["安全章节"]
    end

    subgraph PERF["Performance-Profile"]
        P1A["性能关键词"] --> P1B["性能测试计划"]
        P1B --> P1C["平台工具指南"]
        P1C --> P1D["基准指标"]
    end

    S1 --> QA
    S2 --> S1
    S3 --> QA
    QA --> RP
    RP --> SEC
    RP --> PERF

    style S1 fill:#e8f5e9,stroke:#43a047
    style S2 fill:#e8f5e9,stroke:#43a047
    style S3 fill:#e8f5e9,stroke:#43a047
    style QA fill:#fce4ec,stroke:#e91e63
    style RP fill:#f3e5f5,stroke:#8e24aa
    style SEC fill:#e0f7fa,stroke:#00acc1
    style PERF fill:#e0f7fa,stroke:#00acc1
```

### 3.3 技能协作关系图

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#e1f5fe'}}}%%
flowchart TB
    ORCH["Orchestrator<br/><small>协调路由</small>"] --> AUTOFILL["prd-autofill<br/><small>自动填充</small>"]
    ORCH --> CONV["prd-conversational<br/><small>对话构建</small>"]
    ORCH --> DEEP["prd-deep-expand<br/><small>深度扩展</small>"]

    CONV --> AUTOFILL
    AUTOFILL --> DEEP

    AUTOFILL --> QA["prd-qa<br/><small>质量门禁</small>"]
    CONV --> QA
    DEEP --> QA

    QA --> REVIEW["prd-review-panel<br/><small>评审团</small>"]

    REVIEW -->|"安全相关"| SEC["prd-security-analysis<br/><small>安全分析</small>"]
    REVIEW -->|"性能相关"| PERF["prd-performance-profile<br/><small>性能剖析</small>"]

    DEEP --> SHARED["_shared/<br/><small>知识库</small>"]
    QA --> SHARED

    SHARED --> PLAT["platform-configs/<br/><small>iOS/macOS 配置</small>"]
    SHARED --> TEST["test-templates/<br/><small>测试金字塔</small>"]
    SHARED --> QA_CHK["qa-checks/<br/><small>自检清单</small>"]

    style ORCH fill:#fff8e1,stroke:#f9a825
    style AUTOFILL fill:#e8f5e9,stroke:#43a047
    style CONV fill:#e8f5e9,stroke:#43a047
    style DEEP fill:#e8f5e9,stroke:#43a047
    style QA fill:#fce4ec,stroke:#e91e63
    style REVIEW fill:#f3e5f5,stroke:#8e24aa
    style SEC fill:#e0f7fa,stroke:#00acc1
    style PERF fill:#e0f7fa,stroke:#00acc1
    style SHARED fill:#eceff1,stroke:#546e7a
```

---

## 4. 技能详解

### 4.1 prd-autofill：6步流水线

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#e8f5e9'}}}%%
flowchart LR
    INPUT["💬 一句话想法"] --> P1["1. 意图识别<br/><small>平台 + 功能</small>"]
    P1 --> P2["2. 知识检索<br/><small>6大平台知识库</small>"]
    P2 --> P3["3. 技术推断<br/><small>API 选择</small>"]
    P3 --> P4["4. 量化填充<br/><small>指标 + 参数</small>"]
    P4 --> P5["5. PRD 组装<br/><small>模板填充</small>"]
    P5 --> P6["6. 自检验证<br/><small>4项检查</small>"]
    P6 --> OUTPUT["📄 完整 PRD"]

    style INPUT fill:#e1f5fe,stroke:#0277bd
    style P1 fill:#e8f5e9,stroke:#43a047
    style P2 fill:#e8f5e9,stroke:#43a047
    style P3 fill:#e8f5e9,stroke:#43a047
    style P4 fill:#e8f5e9,stroke:#43a047
    style P5 fill:#e8f5e9,stroke:#43a047
    style P6 fill:#fce4ec,stroke:#e91e63
    style OUTPUT fill:#e1f5fe,stroke:#0277bd
```

**触发**: 说 `"帮我生成一个 macOS 语音输入 App 的 PRD"`

**覆盖平台**: macOS / iOS / Android / Web / CLI / Chrome Extension

### 4.2 prd-conversational：15问状态机

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#f3e5f5'}}}%%
stateDiagram-v2
    [*] --> Phase0: Q0: 确认想法
    Phase0 --> Phase1: Q1-4
    Phase1: 阶段1<br/>平台与基础
    Phase1 --> Phase2: Q5-9
    Phase2: 阶段2<br/>核心功能
    Phase2 --> Phase3: Q10-11
    Phase3: 阶段3<br/>技术偏好
    Phase3 --> Phase4: Q12-14
    Phase4: 阶段4<br/>质量要求
    Phase4 --> Confirmed: 全部回答
    Confirmed --> Export: 保存到文件
    Confirmed --> Preview: 终端预览
    Phase0 --> Resume: "继续对话"
    Phase1 --> Resume
    Phase2 --> Resume
    Phase3 --> Resume
    Phase4 --> Resume
    Resume --> [*]
    Confirmed --> [*]
    Export --> [*]
    Preview --> [*]
```

**15 个问题分 4 个阶段**:

| 阶段 | 问题数 | 主题 |
|------|--------|------|
| 0 | 1 | 意图确认 |
| 1 | 4 | 平台、版本、MVP 范围 |
| 2 | 5 | 核心功能 |
| 3 | 2 | 技术偏好 |
| 4 | 3 | 质量要求 |

**触发**: 说 `"开始对话式 PRD"`

### 4.3 prd-orchestrator：复杂度决策树

| 输入类型 | 特征 | 路由 |
|----------|------|------|
| **简单型** | < 100字，单一功能，常见平台 | 仅方案A |
| **已有PRD型** | 提供文本或文件路径 | 仅方案C |
| **复杂型** | > 200字，多功能，特殊平台 | B → A → C |
| **不确定型** | 描述模糊，功能不明确 | 方案B |

**触发**: 说 `"帮我生成PRD"`（通用入口，无需选择方案）

### 4.4 prd-qa：13维度质检评分卡

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#fce4ec'}}}%%
xychart-beta
    title "PRD 质量评分卡（13维度）"
    x-axis [ "占位符", "配置文件", "API准确性", "动画时长", "量化参数", "测试策略", "CI/CD语法", "无障碍规范", "平台一致性", "边界条件", "自检清单", "技术栈覆盖", "知识库复用" ]
    y-axis "评分" 0 --> 100
    bar [100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100]
```

| # | 维度 | 缺失时的自动操作 |
|---|------|----------------|
| 1 | 无占位符扫描 | 扫描 [TODO]/[TBD]/[FIXME] |
| 2 | 配置文件 | 自动注入 Info.plist / Entitlements |
| 3 | API 准确性 | 检测平台与 API 不匹配 |
| 4 | 动画时长矛盾 | 标记不一致的数值 |
| 5 | 量化参数完整性 | 确保延迟/内存/CPU/帧率值 |
| 6 | 测试策略完整性 | 自动注入测试金字塔模板 |
| 7 | CI/CD 语法检查 | 修正 `$${{ secrets }}` 笔误 |
| 8 | 无障碍规范检查 | VoiceOver / Dynamic Type |
| 9 | 平台一致性检查 | 验证技术栈与目标平台匹配 |
| 10 | 边界条件覆盖度 | 确保数量 >= 10 |
| 11 | 自检清单完整性 | 自动注入清单模板 |
| 12 | 技术栈完整性 | 核心 API 全覆盖检查 |
| 13 | 知识库复用检查 | 验证 `_shared/` 引用 |

**触发**: 说 `"审查 PRD"` 或在 A/B/C 输出后自动调用

### 4.5 其他技能

| 技能 | 触发关键词 | 核心输出 |
|------|-----------|----------|
| `prd-review-panel` | `"评审 PRD"` | 6维雷达图 + 聚合报告 |
| `prd-security-analysis` | 登录/支付/数据关键词 | STRIDE 威胁模型 + 合规映射 |
| `prd-performance-profile` | 实时/音视频/游戏关键词 | 性能测试计划 + 基准指标 |

---

## 5. 技能一览

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

## 6. 支持的平台

| 平台 | 安装方式 | 详情 |
|------|----------|------|
| Claude Code | `make install-claude` | 项目级 `.claude/skills/` |
| Cursor | `make install-cursor` | 项目级 `.cursor/skills/` |
| Windsurf | `make install-windsurf` | 项目级 `.windsurf/skills/` |
| OpenCode | `make install-opencode` | 全局 `~/.opencode/skills/prompt-lab` |
| VSCode | 手动安装 | 参考 `adapters/vscode/README_zh.md` |

---

## 7. 快速开始

### 方式一：交互式安装（推荐）
```bash
./install_zh.sh
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

---

## 8. 项目结构

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
├── install.sh                 # 安装脚本（英文）
├── install_zh.sh              # 安装脚本（中文）
└── README.md
```

---

## 9. 卸载

```bash
make uninstall
# 或运行 ./install_zh.sh 选择"卸载"
```

---

## 10. 本地保留目录

以下目录包含本地集成文件，**不会**上传到仓库：
- `tmp/` — 会话临时文件
- `baize-loop/` — 本地集成

---

## 11. 相关文档

- [Claude Code 适配器](adapters/claude-code/README_zh.md)
- [Cursor 适配器](adapters/cursor/README_zh.md)
- [Windsurf 适配器](adapters/windsurf/README_zh.md)
- [OpenCode 适配器](adapters/opencode/INSTALL_zh.md)
- [VSCode 适配器](adapters/vscode/README_zh.md)

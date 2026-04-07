# PRD Generator

[![GitHub](https://img.shields.io/badge/GitHub-timywel-181717?style=flat-square&logo=github)](https://github.com/timywel)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Claude%20Code%20%7C%20Cursor%20%7C%20Windsurf%20%7C%20OpenCode%20%7C%20VSCode-blue?style=flat-square)](https://github.com/timywel/prompt-lab)

**Author & Maintainer**: [timywel](https://github.com/timywel)

---

PRD Generator is an AI-native Product Requirements Document (PRD) generation system. It is not a simple template-filling tool, but a **smart collaboration network** composed of 8 specialized skills -- from a one-sentence idea to an executable PRD, in just a few rounds of conversation.

---

## 1. Architecture Overview

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#e1f5fe', 'primaryTextColor': '#0277bd', 'primaryBorderColor': '#0277bd', 'lineColor': '#546e7a', 'secondaryColor': '#f3e5f5', 'tertiaryColor': '#fff8e1'}}}%%
flowchart LR
    subgraph INPUT[" "]
        direction TB
        A["👤 User Input<br/><small>one-sentence idea</small>"]
    end

    subgraph ORCH[" "]
        direction TB
        B["Orchestrator<br/><small>Smart Routing</small>"]
    end

    subgraph CORE[" "]
        direction TB
        C1["Autofill"]
        C2["Conversational"]
        C3["Deep-Expand"]
    end

    subgraph QA[" "]
        direction TB
        D["PRD-QA<br/><small>Quality Gate</small>"]
    end

    subgraph REVIEW[" "]
        direction TB
        E["Review-Panel<br/><small>6-Dimensional Review</small>"]
    end

    subgraph OPTIONAL[" "]
        direction TB
        F1["Security-Analysis"] --> F2["Performance-Profile"]
    end

    subgraph OUTPUT[" "]
        direction TB
        G["📄 Final PRD Document"]
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

## 2. Project Capabilities

### Capability Radar

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#e1f5fe', 'axisLabelColor': '#37474f'}}}%%
xychart-beta
    title "PRD Generator Capability Coverage"
    x-axis [ "Multi-Entry", "Smart Routing", "Deep Expand", "Quality Gate", "Review", "Security", "Performance" ]
    y-axis "Coverage" 0 --> 100
    bar [95, 90, 85, 92, 88, 80, 75]
    line [95, 90, 85, 92, 88, 80, 75]
```

| Capability | Description |
|-----------|------|
| **Multi-Entry Access** | One-sentence idea to turnkey PRD; or multi-round conversation for incremental clarification |
| **Smart Routing** | Automatically analyzes requirement complexity and matches the optimal generation strategy |
| **Deep Expansion** | Architecture design / UI/UX / Engineering / Testing / Edge cases / Operations |
| **Quality Gate** | Automatically reviews common PRD defects and outputs a quality report after fixes |
| **Professional Review** | 6-dimensional review panel (Technical Architecture, Product Design, Engineering Implementation, Executability, UI/UX, Testing Strategy) |
| **Security Hardening** | Threat modeling / Privacy compliance / Data encryption / API authentication -- automatically triggered for login/payment/data scenarios |
| **Performance Profiling** | Performance test plan / Platform tooling guide / Baseline metrics / Regression detection -- automatically triggered for high-performance scenarios |

---

## 3. Workflow Deep Dive

### 3.1 Orchestrator Decision Tree

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#fff8e1'}}}%%
flowchart TB
    START(["👤 User Input<br/>e.g. '帮我生成PRD'"]) --> ANALYZE

    ANALYZE{Analyze<br/>Complexity?}
    ANALYZE -->|Simple<br/>< 100 chars| SOLUTION_A[Solution A<br/>prd-autofill]
    ANALYZE -->|Has Existing PRD| SOLUTION_C[Solution C<br/>prd-deep-expand]
    ANALYZE -->|Complex<br/>> 200 chars| SOLUTION_B[Solution B<br/>prd-conversational]
    ANALYZE -->|Vague<br/>Unclear| SOLUTION_B2[Solution B<br/>Requirement Discovery]

    SOLUTION_A --> QA[PRD-QA<br/>Quality Gate]
    SOLUTION_B --> SOLUTION_A2[Solution A<br/>Technical Details]
    SOLUTION_A2 --> SOLUTION_C2[Solution C<br/>Deep Expand]
    SOLUTION_C2 --> QA
    SOLUTION_B2 --> REVAL{Re-evaluate?}
    REVAL -->|Still vague| SOLUTION_B
    REVAL -->|Clear enough| SOLUTION_A
    SOLUTION_C --> QA

    QA -->|Pass| PANEL{Review<br/>Requested?}
    QA -->|Fail| FIX[Auto-Fix<br/>Issues]
    FIX --> QA

    PANEL -->|Yes| REVIEW[Review-Panel<br/>6-Dimensional]
    PANEL -->|No| FINAL[Final PRD]

    REVIEW -->|Security| SECURITY[Security-Analysis]
    REVIEW -->|Performance| PERFORMANCE[Performance-Profile]
    SECURITY --> FINAL2[Final PRD]
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

### 3.2 PRD Data Flow Through Skills

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#e1f5fe'}}}%%
flowchart LR
    subgraph S1["Solution A: prd-autofill"]
        D1["Draft PRD<br/><small>raw idea</small>"] --> T1["Technical Fill<br/><small>platform + APIs</small>"]
        T1 --> Q1["Quantified PRD<br/><small>metrics filled</small>"]
    end

    subgraph S2["Solution B: prd-conversational"]
        D2["Vague Input"] --> G1["Guided Q&A<br/><small>15 questions</small>"]
        G1 --> G2["Clarified Input<br/><small>user-confirmed</small>"]
    end

    subgraph S3["Solution C: prd-deep-expand"]
        P3["Preliminary PRD"] --> E1["6-Dim Expansion<br/><small>arch/UI/eng/test/edge/ops</small>"]
        E1 --> E2["Expanded PRD<br/><small>comprehensive</small>"]
    end

    subgraph QA["PRD-QA"]
        QUA["Raw Output"] --> QUB["13-Dim Audit<br/><small>issues found</small>"]
        QUB --> QUC["Auto-Fixed<br/><small>diff applied</small>"]
        QUC --> QUD["Quality Report<br/><small>scorecard</small>"]
    end

    subgraph RP["Review-Panel"]
        R1["PRD for Review"] --> R2["6-Dim Scoring<br/><small>radar chart</small>"]
        R2 --> R3["Aggregated Report<br/><small>final verdict</small>"]
    end

    subgraph SEC["Security-Analysis"]
        S1A["Security Keywords"] --> S1B["STRIDE Threat Model"]
        S1B --> S1C["Compliance Mapping"]
        S1C --> S1D["Security Chapter"]
    end

    subgraph PERF["Performance-Profile"]
        P1A["Performance Keywords"] --> P1B["Perf Test Plan"]
        P1B --> P1C["Platform Tools Guide"]
        P1C --> P1D["Benchmark Metrics"]
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

### 3.3 Skill Collaboration Map

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#e1f5fe'}}}%%
flowchart TB
    ORCH["Orchestrator<br/><small>Router</small>"] --> AUTOFILL["prd-autofill<br/><small>Auto-fill</small>"]
    ORCH --> CONV["prd-conversational<br/><small>Dialogue</small>"]
    ORCH --> DEEP["prd-deep-expand<br/><small>Deep Expand</small>"]

    CONV --> AUTOFILL
    AUTOFILL --> DEEP

    AUTOFILL --> QA["prd-qa<br/><small>QA Gate</small>"]
    CONV --> QA
    DEEP --> QA

    QA --> REVIEW["prd-review-panel<br/><small>Review</small>"]

    REVIEW -->|"security-relevant"| SEC["prd-security-analysis<br/><small>Security</small>"]
    REVIEW -->|"perf-relevant"| PERF["prd-performance-profile<br/><small>Performance</small>"]

    DEEP --> SHARED["_shared/<br/><small>Knowledge Base</small>"]
    QA --> SHARED

    SHARED --> PLAT["platform-configs/<br/><small>iOS/macOS configs</small>"]
    SHARED --> TEST["test-templates/<br/><small>Test pyramid</small>"]
    SHARED --> QA_CHK["qa-checks/<br/><small>Self-review</small>"]

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

## 4. Skill Deep Dives

### 4.1 prd-autofill: 6-Step Pipeline

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#e8f5e9'}}}%%
flowchart LR
    INPUT["💬 One-Sentence Idea"] --> P1["1. Intent Recognition<br/><small>platform + features</small>"]
    P1 --> P2["2. Knowledge Retrieval<br/><small>6 platform KBs</small>"]
    P2 --> P3["3. Technical Inference<br/><small>API selection</small>"]
    P3 --> P4["4. Quantification<br/><small>metrics + params</small>"]
    P4 --> P5["5. PRD Assembly<br/><small>template fill</small>"]
    P5 --> P6["6. Self-Verification<br/><small>4 checks</small>"]
    P6 --> OUTPUT["📄 Complete PRD"]

    style INPUT fill:#e1f5fe,stroke:#0277bd
    style P1 fill:#e8f5e9,stroke:#43a047
    style P2 fill:#e8f5e9,stroke:#43a047
    style P3 fill:#e8f5e9,stroke:#43a047
    style P4 fill:#e8f5e9,stroke:#43a047
    style P5 fill:#e8f5e9,stroke:#43a047
    style P6 fill:#fce4ec,stroke:#e91e63
    style OUTPUT fill:#e1f5fe,stroke:#0277bd
```

**Trigger**: Say `"帮我生成一个 macOS 语音输入 App 的 PRD"`

**Platforms**: macOS / iOS / Android / Web / CLI / Chrome Extension

### 4.2 prd-conversational: 15-Question State Machine

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#f3e5f5'}}}%%
stateDiagram-v2
    [*] --> Phase0: Q0: Confirm idea
    Phase0 --> Phase1: Q1-4
    Phase1: Phase 1<br/>Platform & Basics
    Phase1 --> Phase2: Q5-9
    Phase2: Phase 2<br/>Core Features
    Phase2 --> Phase3: Q10-11
    Phase3: Phase 3<br/>Tech Preferences
    Phase3 --> Phase4: Q12-14
    Phase4: Phase 4<br/>Quality Requirements
    Phase4 --> Confirmed: All answered
    Confirmed --> Export: Save to file
    Confirmed --> Preview: Terminal preview
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

**15 Questions across 4 Phases**:

| Phase | Questions | Topics |
|-------|-----------|--------|
| 0 | 1 | Intent confirmation |
| 1 | 4 | Platform, version, MVP scope |
| 2 | 5 | Core features |
| 3 | 2 | Tech preferences |
| 4 | 3 | Quality requirements |

**Trigger**: Say `"开始对话式 PRD"`

### 4.3 prd-orchestrator: Complexity Decision Tree

| Input Type | Characteristics | Route |
|------------|----------------|-------|
| **Simple** | < 100 chars, single feature, common platform | Solution A only |
| **Existing PRD** | Provides text or file path | Solution C only |
| **Complex** | > 200 chars, multiple features, special platform | B → A → C |
| **Uncertain** | Vague description, unclear functionality | Solution B |

**Trigger**: Say `"帮我生成PRD"` (universal entry, no skill selection needed)

### 4.4 prd-qa: 13-Dimensional Quality Scorecard

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#fce4ec'}}}%%
xychart-beta
    title "PRD Quality Scorecard (13 Dimensions)"
    x-axis [ "Placeholder", "Config Files", "API Accuracy", "Animation", "Quant Params", "Test Strategy", "CI/CD Syntax", "Accessibility", "Platform Match", "Edge Cases", "Self-Review", "Tech Stack", "KB Reuse" ]
    y-axis "Score" 0 --> 100
    bar [100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100]
```

| # | Dimension | Auto-Action if Missing |
|---|-----------|----------------------|
| 1 | No Placeholder | Scan [TODO]/[TBD]/[FIXME] |
| 2 | Config Files | Auto-inject Info.plist / Entitlements |
| 3 | API Accuracy | Detect platform/API mismatches |
| 4 | Animation Conflicts | Flag inconsistent duration values |
| 5 | Quant Params | Ensure delay/memory/CPU/framerate values |
| 6 | Test Strategy | Auto-inject test pyramid template |
| 7 | CI/CD Syntax | Fix `$${{ secrets }}` typos |
| 8 | Accessibility | VoiceOver / Dynamic Type / reduceMotion |
| 9 | Platform Consistency | Verify tech stack vs target |
| 10 | Edge Cases | Ensure count >= 10 |
| 11 | Self-Review Checklist | Auto-inject checklist template |
| 12 | Tech Stack Coverage | Full core API coverage check |
| 13 | Knowledge Base Reuse | Verify `_shared/` references |

**Trigger**: Say `"审查 PRD"` or auto-invoked after A/B/C output

### 4.5 Other Skills

| Skill | Trigger | Key Output |
|-------|---------|-----------|
| `prd-review-panel` | `"评审 PRD"` | 6-dim radar chart + aggregated report |
| `prd-security-analysis` | Login / Payment / Data keywords | STRIDE threat model + compliance map |
| `prd-performance-profile` | Real-time / Audio / Gaming keywords | Perf test plan + benchmark metrics |

---

## 5. Skills Overview

| Skill | Trigger Scenario | Core Value |
|------|----------|----------|
| `prd-autofill` | Quick start | One sentence in, detailed PRD out |
| `prd-conversational` | Vague requirements | Multi-round guidance, precise clarification |
| `prd-deep-expand` | Deep requirements | Full 6-dimensional expansion |
| `prd-orchestrator` | Universal entry | Smart analysis, automatic routing |
| `prd-qa` | Quality gate | Auto review + fix |
| `prd-review-panel` | Review stage | 6-dimensional comprehensive scoring |
| `prd-security-analysis` | Security-related | Threat modeling / Compliance / Encryption |
| `prd-performance-profile` | Performance-related | Test plan / Baseline metrics |

---

## 6. Supported Platforms

| Platform | Installation | Details |
|------|----------|----------|
| Claude Code | `make install-claude` | Project-level `.claude/skills/` |
| Cursor | `make install-cursor` | Project-level `.cursor/skills/` |
| Windsurf | `make install-windsurf` | Project-level `.windsurf/skills/` |
| OpenCode | `make install-opencode` | Global `~/.opencode/skills/prompt-lab` |
| VSCode | Manual install | See `adapters/vscode/README.md` |

---

## 7. Quick Start

### Method 1: Interactive Installation (Recommended)
```bash
./install.sh
```

### Method 2: Makefile Installation
```bash
# Install core platforms (Claude Code + Cursor + Windsurf)
make install

# Install all platforms
make install-all

# Install specific platform
make install-claude   # Claude Code
make install-cursor    # Cursor
make install-windsurf  # Windsurf
make install-opencode  # OpenCode (global)
```

---

## 8. Project Structure

```
prompt-lab/
├── skills/                    # Standardized skill source (shared across all platforms)
│   ├── _registry.yaml         # Skill registry
│   ├── _shared/               # Shared knowledge base
│   │   ├── platform-configs/  # iOS/macOS configuration templates
│   │   ├── qa-checks/         # Self-inspection checklists
│   │   └── test-templates/    # Test pyramid
│   └── prd-*/                 # 8 skill modules
├── adapters/                  # Platform adapters
│   ├── claude-code/          # Claude Code
│   ├── cursor/               # Cursor
│   ├── windsurf/             # Windsurf
│   ├── opencode/             # OpenCode
│   └── vscode/               # VSCode extension
├── docs/                      # Project documentation (PRD/Review/Standards)
├── Makefile                   # Cross-platform install/uninstall
├── install.sh                 # Interactive installation script
└── README.md
```

---

## 9. Uninstall

```bash
make uninstall
# Or run ./install.sh and select "Uninstall"
```

---

## 10. Locally Preserved Directories

The following directories contain local integration files and **will not** be uploaded to the repository:
- `tmp/` -- Session temporary files
- `baize-loop/` -- Local integration

---

## 11. Related Documentation

- [Claude Code Adapter](adapters/claude-code/README.md)
- [Cursor Adapter](adapters/cursor/README.md)
- [Windsurf Adapter](adapters/windsurf/README.md)
- [OpenCode Adapter](adapters/opencode/INSTALL.md)
- [VSCode Adapter](adapters/vscode/README.md)

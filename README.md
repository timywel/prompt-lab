# PRD Generator

[![GitHub](https://img.shields.io/badge/GitHub-timywel-181717?style=flat-square&logo=github)](https://github.com/timywel)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Claude%20Code%20%7C%20Cursor%20%7C%20Windsurf%20%7C%20OpenCode%20%7C%20VSCode-blue?style=flat-square)](https://github.com/timywel/prompt-lab)

**Author & Maintainer**: [timywel](https://github.com/timywel)

---

PRD Generator is an AI-native Product Requirements Document (PRD) generation system. It is not a simple template-filling tool, but a **smart collaboration network** composed of 8 specialized skills -- from a one-sentence idea to an executable PRD, in just a few rounds of conversation.

---

## 1. Architecture Overview

```
                    ┌─────────────────────────────────────────────────┐
                    │                  USER INPUT                     │
                    │       (e.g. "帮我生成一个三国斗地主PRD")          │
                    └──────────────────────┬────────────────────────┘
                                           │
                                           ▼
                    ┌─────────────────────────────────────────────────┐
                    │            PRD-DISPATCHER                       │
                    │    (Analyze + Confirm Route)                    │
                    └──────────────────────┬────────────────────────┘
                                           │
                                           ▼
                    ┌─────────────────────────────────────────────────┐
                    │              ORCHESTRATOR                       │
                    │          (Smart Routing)                       │
                    └──────────────────────┬────────────────────────┘
                                           │
                    ┌──────────────────────┼──────────────────────────┐
                    │                      │                          │
        ┌───────────▼──────────┐ ┌────────▼────────┐ ┌──────────────▼──────────┐
        │    prd-autofill       │ │prd-conversational│ │   prd-deep-expand       │
        │   (Auto-fill)         │ │ (Dialogue)        │ │  (Deep Expansion)       │
        └───────────┬───────────┘ └────────┬────────┘ └──────────────┬──────────┘
                    │                        │                          │
                    └─────────────────────────┼──────────────────────────┘
                                             │
                                             ▼
                    ┌─────────────────────────────────────────────────┐
                    │                PRD-QA                           │
                    │          (Quality Gate)                         │
                    └──────────────────────┬────────────────────────┘
                                           │
                    ┌───────────────────────┼─────────────────────────┐
                    │                       │                          │
        ┌───────────▼──────────┐ ┌────────▼────────┐ ┌──────────────▼──────────┐
        │   prd-review-panel    │ │prd-security-    │ │  prd-performance-        │
        │  (6-Dim Review)       │ │   analysis       │ │     profile               │
        └───────────────────────┘ └─────────────────┘ └─────────────────────────┘
                                           │
                                           ▼
                    ┌─────────────────────────────────────────────────┐
                    │              FINAL PRD DOCUMENT                  │
                    └─────────────────────────────────────────────────┘
```

**Color legend**: Orange = Router/Dispatcher  |  Green = Core Gen  |  Pink = QA  |  Purple = Review  |  Cyan = Analysis

---

## 2. Project Capabilities

### Capability Coverage

```
Multi-Entry     ████████████░ 95%
Smart-Routing   ██████████░░░ 90%
Deep-Expand     █████████░░░░ 85%
Quality-Gate    ██████████░░░ 92%
Review-Panel    █████████░░░░ 88%
Security        ████████░░░░░ 80%
Performance     ███████░░░░░░ 75%
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

```
                              ┌─────────────────┐
                              │   USER INPUT    │
                              │ e.g. "帮我生成PRD" │
                              └────────┬────────┘
                                       │
                              ┌────────▼────────┐
                              │   ANALYZE        │
                              │  Complexity?     │
                              └───┬─────┬─────┬──┘
                                  │     │     │
               ┌──────────────┐  │     │  ┌──────────────────┐
               │    Simple    │  │     │  │    Vague        │
               │ <100 chars   │  │     │  │  Unclear func.  │
               └───┬──────────┘  │     │  └───┬────────────┘
                   │              │     │      │
          ┌────────▼──────┐      │     │ ┌───▼────────────┐
          │  Solution A   │      │     │ │  Solution B    │
          │ prd-autofill  │      │     │ │prd-conversat.  │
          └───────┬───────┘      │     │ └───────┬────────┘
                  │              │     │         │
          ┌───────▼──────────────┴─────┴─────────┴──────┐
          │              PRD-QA                          │
          │          (Quality Gate)                       │
          └───┬────────────────┬─────────────────────┬──┘
              │                │                     │
      ┌───────▼───────┐ ┌──────▼──────┐ ┌──────────▼──────────┐
      │    Pass?      │ │   Fail →    │ │  Review Requested?  │
      │   /    \      │ │  Auto-Fix  │ │      /         \     │
      │  Yes   No     │ └──────┬──────┘ │   Yes        No      │
      └──┬──────┬─────┘        │        └──┬─────────┬───────┘
         │      │               │           │         │
         │      │               │    ┌─────▼────┐  ┌──▼────────┐
         │      │               │    │Review-   │  │  Final    │
         │      │               │    │Panel      │  │   PRD     │
         │      │               │    └─────┬────┘  └───────────┘
         │      │               │          │
         │      │               │   ┌──────┴──────────────┐
         │      │               │   │Security? Performance?│
         │      │               │   │  → Auto-trigger    │
         │      │               │   └──────────┬──────────┘
         │      │               │              │
         └──────▼───────────────┴──────────────▼─────→ Final PRD
```

**Routing table**:

| Input Type | Characteristics | Route |
|------------|----------------|-------|
| **Simple** | < 100 chars, single feature, common platform | Solution A only |
| **Existing PRD** | Provides text or file path | Solution C only |
| **Complex** | > 200 chars, multiple features, special platform | B → A → C |
| **Uncertain** | Vague description, unclear functionality | Solution B |

---

### 3.2 PRD Data Flow Through Skills

```
 ┌──────────────────────────────────────────────────────────────────────────────┐
 │                          PRDs FLOW THROUGH SKILLS                          │
 └──────────────────────────────────────────────────────────────────────────────┘

  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
  │  Solution A │     │  Solution B │     │  Solution C │     │   PRD-QA    │
  │ prd-autofill│     │prd-conversat.│     │prd-deep-expand│   │  QA Gate   │
  ├─────────────┤     ├─────────────┤     ├─────────────┤     ├─────────────┤
  │ Draft PRD   │────▶│ Vague Input │────▶│Preliminary  │────▶│ Raw Output │
  │ (raw idea)  │     │ (guided Q&A)│     │    PRD      │     │             │
  │             │     │      │      │     │             │     │     │      │
  │     │       │     │      ▼      │     │     │       │     │     ▼      │
  │     ▼       │     │  Clarified  │     │     ▼       │     │ 13-Dim     │
  │  Tech Fill  │     │   Input     │     │ 6-Dim      │     │  Audit     │
  │     │       │     │      │      │     │  Expand     │     │ (issues)   │
  │     ▼       │     │      │      │     │     │       │     │     │      │
  │  Quantified │     └──────┼──────┘     │     ▼       │     │     ▼      │
  │    PRD      │            │            │  Expanded   │     │ Auto-Fixed │
  └──────┬──────┘            │            │    PRD      │     │     │      │
         │                   │            └──────┬──────┘     │     ▼      │
         │                   │                   │             │ Quality    │
         │                   │                   │             │ Report     │
         └───────────────────┼───────────────────┘             └─────┬─────┘
                             │                                       │
                             ▼                                       ▼
                   ┌─────────────────┐                    ┌─────────────────┐
                   │ prd-review-panel│                    │  Final PRD      │
                   │  6-Dim Scoring  │                    │  (Validated)     │
                   └────────┬────────┘                    └─────────────────┘
                            │
              ┌─────────────┼─────────────┐
              ▼             ▼             ▼
     ┌─────────────┐ ┌─────────────┐ ┌─────────────────┐
     │   Security  │ │Performance  │ │  Aggregated    │
     │  Analysis   │ │  Profile    │ │    Report      │
     └─────────────┘ └─────────────┘ └─────────────────┘
```

---

### 3.3 Skill Collaboration Map

```
 ┌──────────────────────────────────────────────────────────────────────────────┐
 │                        SKILL COLLABORATION MAP                               │
 └──────────────────────────────────────────────────────────────────────────────┘

                    ┌──────────────────┐
                    │   Dispatcher     │  ◄── Universal entry point (all PRD requests)
                    │   (Router)       │
                    └────────┬─────────┘
                             │
                    ┌────────▼─────────┐
                    │  Orchestrator   │  ◄── Chained execution (A→B→C)
                    │  (Coordinator)   │
                    └────────┬─────────┘
                             │
         ┌───────────────────┼───────────────────┐
         │                   │                   │
         ▼                   ▼                   ▼
  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
  │prd-autofill │    │prd-conversat.│    │prd-deep-expand│
  │ (Auto-fill) │    │ (Dialogue)   │    │(Deep Expand) │
  └──────┬──────┘    └──────┬───────┘    └──────┬──────┘
         │                   │                   │
         │                   └─────────┬─────────┘
         │                             │
         └─────────────┬───────────────┘
                       │
                       ▼
              ┌─────────────────┐
              │    PRD-QA       │  ◄── Quality gate (auto-invoked)
              │  (13 Dimensions) │
              └────────┬────────┘
                       │
                       ▼
              ┌─────────────────┐
              │ prd-review-panel│  ◄── 6-dimensional review
              └────────┬────────┘
                       │
              ┌────────┴────────┐
              ▼                 ▼
     ┌──────────────┐    ┌──────────────┐
     │prd-security- │    │prd-perform- │
     │  analysis    │    │ance-profile │
     └──────────────┘    └──────────────┘
              │                 │
              └────────┬────────┘
                       ▼
              ┌──────────────┐
              │   _shared/  │  ◄── Knowledge base (all skills access)
              │  (KB)        │
              └──────┬───────┘
                     │
       ┌─────────────┼─────────────┐
       ▼             ▼             ▼
┌────────────┐ ┌────────────┐ ┌────────────┐
│ platform-  │ │   test-    │ │  qa-       │
│ configs/   │ │ templates/ │ │ checks/    │
└────────────┘ └────────────┘ └────────────┘
```

---

## 4. Skill Deep Dives

### 4.1 prd-autofill: 6-Step Pipeline

```
  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
  │     💬       │    │      1       │    │      2       │    │      3       │
  │    INPUT    │───▶│   Intent    │───▶│  Knowledge   │───▶│  Technical   │
  │(one sentence│    │ Recognition │    │  Retrieval   │    │  Inference   │
  │    idea)     │    │  platform   │    │ 6 platform   │    │  API select  │
  └──────────────┘    └──────┬───────┘    └──────┬───────┘    └──────┬───────┘
                              │                        │                 │
                              │                        ▼                 │
                              │               ┌──────────────┐         │
                              │               │      4        │         │
                              │               │ Quantification│         │
                              │               │metrics + params│        │
                              │               └──────┬───────┘         │
                              │                      │                  │
                              │                      ▼                  │
                              │               ┌──────────────┐         │
                              │               │      5        │         │
                              │               │ PRD Assembly │         │
                              │               │  template    │         │
                              │               │    fill      │         │
                              │               └──────┬───────┘         │
                              │                      │                  │
                              │                      ▼                  │
                              │               ┌──────────────┐         │
                              └──────────────▶│      6        │────────┘
                                              │ Self-Verify  │
                                              │4 checks     │
                                              └──────┬───────┘
                                                     │
                                                     ▼
                                              ┌──────────────┐
                                              │     📄        │
                                              │    OUTPUT    │
                                              │(Complete PRD)│
                                              └──────────────┘
```

**Trigger**: Say `"帮我生成一个 macOS 语音输入 App 的 PRD"`

**Platforms**: macOS / iOS / Android / Web / CLI / Chrome Extension

---

### 4.2 prd-conversational: 15-Question State Machine

```
 ┌──────────────────────────────────────────────────────────────────────────────┐
 │                  CONVERSATIONAL PRD STATE MACHINE                            │
 │                                                                              │
 │    ┌───────┐    Q1-4     ┌────────┐    Q5-9     ┌────────┐    Q10-11   ┌────────┐   Q12-14   ┌───────────┐
 │    │Phase 0│ ───────▶  │ Phase 1 │ ───────▶  │ Phase 2│ ───────▶  │ Phase 3│ ───────▶ │  Phase 4  │
 │    │Intent │            │Platform │            │  Core  │            │  Tech  │            │  Quality  │
 │    │Confirm│            │& Basics │            │Features│            │ Prefs  │            │  Reqs     │
 │    └───┬────┘            └────┬────┘            └────┬────┘            └────┬────┘            └─────┬─────┘
 │        │ Q0                   │ 1-4                  │ 5-9                │ 10-11               │ 12-14
 │        │                      │                      │                     │                     │
 │        ▼                      ▼                      ▼                     ▼                     ▼
 │    ┌────────┐            ┌────────┐            ┌────────┐           ┌────────┐          ┌───────────┐
 │    │ Resume │            │ Resume │            │ Resume │           │ Resume │          │ Confirmed │
 │    │"继续对话"│◀─────────│"继续对话"│◀─────────│"继续对话"│◀─────────│"继续对话"│          │(all 15 Q) │
 │    └───┬────┘            └────┬────┘            └────┬────┘           └────┬────┘          └─────┬─────┘
 │        │                      │                      │                     │                     │
 └────────┼──────────────────────┼──────────────────────┼─────────────────────┼─────────────────────┘
          │                      │                      │                     │
          ▼                      ▼                      ▼                     ▼
    ┌─────────────────────────────────────────────────────────────────────────────────────┐
    │                              EXPORT / PREVIEW                                        │
    │                     Save to file  or  Terminal preview                               │
    └─────────────────────────────────────────────────────────────────────────────────────┘

  Question breakdown:
  ┌───────┬──────────────────────────────────────────────────────────────┐
  │ Phase │  Questions                                                   │
  ├───────┼──────────────────────────────────────────────────────────────┤
  │   0   │  Q0: Confirm and clarify the initial idea                  │
  │   1   │  Q1-4: Platform, version, MVP scope, app category           │
  │   2   │  Q5-9: Core features, user interactions, data needs        │
  │   3   │  Q10-11: Tech stack preferences, performance requirements  │
  │   4   │  Q12-14: Accessibility, testing, launch timeline            │
  └───────┴──────────────────────────────────────────────────────────────┘
```

**Trigger**: Say `"开始对话式 PRD"`

---

### 4.3 prd-dispatcher: Complexity Analysis & Routing Confirmation

```
 ┌──────────────────────────────────────────────────────────────────────────────┐
 │                      PRD DISPATCHER - ROUTING CONFIRMATION                  │
 └──────────────────────────────────────────────────────────────────────────────┘

  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
  │     💬       │    │      1       │    │      2       │    │      3       │
  │    INPUT    │───▶│   Analyze    │───▶│   Confirm    │───▶│   Delegate   │
  │"帮我生成PRD" │    │  Complexity  │    │    Route     │    │   Skill     │
  └──────────────┘    └──────┬───────┘    └──────┬───────┘    └──────┬───────┘
                               │                      │                  │
                               ▼                      ▼                  ▼
                     ┌──────────────┐        ┌──────────────┐    ┌──────────────┐
                     │   4 Types    │        │  Options:   │    │ prd-autofill │
                     │ Simple/Exist. │        │  A / B / C  │    │prd-convers. │
                     │ Complex/Uncert.      │  [User picks]│    │prd-deep-expand│
                     └──────────────┘        └──────────────┘    └──────────────┘

  Routing table:

  | Type       | Characteristics                        | Route              |
  |------------|---------------------------------------|--------------------|
  | **Simple** | < 100 chars, single feature           | prd-autofill       |
  | **Existing** | User provides text or file path     | prd-deep-expand    |
  | **Complex** | > 200 chars, multiple features        | prd-conversational |
  | **Uncertain** | Vague description                  | prd-conversational |

  **Critical**: Never auto-decide. Always confirm routing with user first.
```

**Trigger**: Say `"帮我生成PRD"` or `"生成PRD"` (captures all PRD requests)

---

### 4.4 prd-orchestrator: Chained Execution

| Input Type | Characteristics | Route |
|------------|----------------|-------|
| **Simple** | < 100 chars, single feature, common platform | Solution A only |
| **Existing PRD** | Provides text or file path | Solution C only |
| **Complex** | > 200 chars, multiple features, special platform | B → A → C |
| **Uncertain** | Vague description, unclear functionality | Solution B |

**Trigger**: Say `"帮我生成PRD"` (universal entry, no skill selection needed)

---

### 4.4 prd-qa: 13-Dimensional Quality Scorecard

```
 ┌──────────────────────────────────────────────────────────────────────────────┐
 │                      PRD QUALITY GATE - 13 DIMENSIONS                      │
 └──────────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────┐  Phase 1: SCAN       ┌─────────────────┐  Phase 2: FILL
  │   ① Placeholder │ ─────────────────▶  │  ④ Animation    │ ────────────▶
  │     Scan        │     ② Config       │    Conflicts    │    ⑤ Quant
  │ [TODO]/[TBD]   │      Files          │ (duration vals) │     Params
  └─────────────────┘ ─────────────────▶  └─────────────────┘ ────────────▶
          │                  │                      │                    │
          │                  ▼                      │                    ▼
  ┌─────────────────┐  ┌─────────────────┐          │            ┌─────────────────┐
  │   ③ API        │  │   ⑥ Test       │          │            │   ⑦ CI/CD      │
  │   Accuracy     │  │   Strategy      │          │            │   Syntax        │
  │ (platform/API  │  │(test pyramid    │          │            │($${{secrets}}   │
  │   mismatch)    │  │  template)      │          │            │   fix)          │
  └────────┬────────┘  └────────┬────────┘          │            └────────┬────────┘
           │                     │                   │                     │
           │                     │                   │                     │
           ▼                     ▼                   ▼                     ▼
  ┌──────────────────────────────────────────────────────────────────────────────┐
  │                     Phase 3: VALIDATE                                         │
  │  ⑧ Accessibility   ⑨ Platform    ⑩ Edge Cases   ⑪ Self-Review              │
  │  VoiceOver/        Consistency    Coverage       Checklist                    │
  │  Dynamic Type       Tech stack     ≥10 items     Auto-inject                 │
  └──────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
  ┌──────────────────────────────────────────────────────────────────────────────┐
  │                     Phase 4: REPORT                                           │
  │       ⑫ Tech Stack Coverage         ⑬ Knowledge Base Reuse                   │
  │       Full core API check            Verify _shared/ refs                     │
  └──────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
                              ┌──────────────┐
                              │ QUALITY      │
                              │ REPORT       │
                              │(score + diffs│
                              │+ issues)     │
                              └──────────────┘
```

**Trigger**: Say `"审查 PRD"` or auto-invoked after A/B/C output

---

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
| `prd-dispatcher` | Universal entry | Analyzes complexity, confirms routing with user |
| `prd-autofill` | Quick start | One sentence in, detailed PRD out |
| `prd-conversational` | Vague requirements | Multi-round guidance, precise clarification |
| `prd-deep-expand` | Deep requirements | Full 6-dimensional expansion |
| `prd-orchestrator` | Chained execution | Route A→B→C in sequence |
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

# PRD Generator

[![GitHub](https://img.shields.io/badge/GitHub-timywel-181717?style=flat-square&logo=github)](https://github.com/timywel)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Claude%20Code%20%7C%20Cursor%20%7C%20Windsurf%20%7C%20OpenCode%20%7C%20VSCode-blue?style=flat-square)](https://github.com/timywel/prompt-lab)

**Author & Maintainer**: [timywel](https://github.com/timywel)

---

PRD Generator is an AI-native Product Requirements Document (PRD) generation system. It is not a simple template-filling tool, but a **smart collaboration network** composed of 8 specialized skills -- from a one-sentence idea to an executable PRD, in just a few rounds of conversation.

## Project Capabilities

### Core Capability Matrix

| Capability | Description |
|-----------|------|
| **Multi-Entry Access** | One-sentence idea to turnkey PRD; or multi-round conversation for incremental clarification |
| **Smart Routing** | Automatically analyzes requirement complexity and matches the optimal generation strategy |
| **Deep Expansion** | Architecture design / UI/UX / Engineering / Testing / Edge cases / Operations |
| **Quality Gate** | Automatically reviews common PRD defects and outputs a quality report after fixes |
| **Professional Review** | 6-dimensional review panel (Technical Architecture, Product Design, Engineering Implementation, Executability, UI/UX, Testing Strategy) |
| **Security Hardening** | Threat modeling / Privacy compliance / Data encryption / API authentication -- automatically triggered for login/payment/data scenarios |
| **Performance Profiling** | Performance test plan / Platform tooling guide / Baseline metrics / Regression detection -- automatically triggered for high-performance scenarios |

### Workflow Diagram

```
User Input (One-sentence idea)
    │
    ▼
┌─────────────────┐
│  Orchestrator   │ ← Smart Routing: Analyze complexity
│  Coordinator    │
└────────┬────────┘
         │
    ┌────┴────┬──────────┬──────────┐
    ▼         ▼          ▼          ▼
Autofill  Conversational  Deep-Expand  (Combinations on demand)
    │         │             │
    └────┬────┴─────────────┘
         ▼
┌─────────────────┐
│   PRD-QA        │ ← Quality Gate: Review + Fix
│   QA & Fix      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Review-Panel   │ ← 6-Dimensional Review Panel
│  Review Panel   │
└────────┬────────┘
         │
    Optional trigger ▼
┌──────────────────┐  ┌──────────────────────┐
│ Security-Analysis │  │ Performance-Profile │
│ Security Analysis │  │ Performance Profile │
└──────────────────┘  └──────────────────────┘
         │
         ▼
   Final PRD Document
```

### Skills Overview

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

## Quick Start

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

## Supported Platforms

| Platform | Installation | Details |
|------|----------|----------|
| Claude Code | `make install-claude` | Project-level `.claude/skills/` |
| Cursor | `make install-cursor` | Project-level `.cursor/skills/` |
| Windsurf | `make install-windsurf` | Project-level `.windsurf/skills/` |
| OpenCode | `make install-opencode` | Global `~/.opencode/skills/prompt-lab` |
| VSCode | Manual install | See `adapters/vscode/README.md` |

## Project Structure

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

## Uninstall

```bash
make uninstall
# Or run ./install.sh and select "Uninstall"
```

## Locally Preserved Directories

The following directories contain local integration files and **will not** be uploaded to the repository:
- `tmp/` -- Session temporary files
- `baize-loop/` -- Local integration

## Related Documentation

- [Claude Code Adapter](adapters/claude-code/README.md)
- [Cursor Adapter](adapters/cursor/README.md)
- [Windsurf Adapter](adapters/windsurf/README.md)
- [OpenCode Adapter](adapters/opencode/INSTALL.md)
- [VSCode Adapter](adapters/vscode/README.md)

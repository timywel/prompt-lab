# prd-autofill: Fully Automatic PRD Generator

## Overview

One-sentence idea → Complete, executable PRD document.

## Usage

In Claude Code, when you want to generate a PRD, simply describe your idea:

```
帮我生成一个 macOS 菜单栏语音输入 App 的 PRD
```

The system will automatically:
1. **Intent Recognition** — Detects platform, features, interaction patterns, and constraints
2. **Knowledge Retrieval** — Fetches specs from 6 major platform knowledge bases
3. **Technical Inference** — Selects specific technical implementation approaches
4. **Quantitative Fill** — Supplements performance/UI/compatibility parameters
5. **PRD Assembly** — Generates complete document following standard template
6. **Self-Validation** — 4 checks ensure no placeholders or ambiguity

Output location: `docs/prd/<app-name>-prd.md`

## Supported Platforms

- ✅ macOS Desktop Applications (Swift/AppKit/SwiftUI, CGEventTap, NSPanel, etc.)
- ✅ iOS Apps (Swift/UIKit, AVFoundation, Speech, Vision, etc.)
- ✅ Android Apps (Kotlin/Compose, ML Kit, Firebase, etc.)
- ✅ Web Applications (React/Vue, Web Speech API, WebRTC, etc.)
- ✅ CLI Tools (Go/Rust/Python, cobra/clap, etc.)
- ✅ Chrome Extensions (Manifest V3, content scripts, etc.)

## Core Capabilities

| Capability | Description |
|-------------|-------------|
| Intent Recognition | Infers platform, features, interaction, and constraints from a single sentence |
| Technology Selection | Voice/persistence/networking/text injection/input method handling |
| Quantitative Parameters | Auto-fills defaults for performance/UI/compatibility |
| Negative Test Cases | Common + platform-specific pitfalls guide |
| Self-Validation | 4 checks: placeholders, quantification, consistency, executability |

## Version History

- 1.0.0: Initial version, supports 6 major platforms, covers intent recognition, platform knowledge base, technology selection, quantitative parameters, negative test cases, standard PRD template, and self-check mechanism

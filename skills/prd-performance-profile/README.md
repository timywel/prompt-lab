# PRD Performance Profile Skill

## Overview

prd-performance-profile is a skill extension that automatically generates performance profiling chapters for PRD documents. When a PRD involves real-time systems, audio/video, gaming, or high-performance requirements, this skill automatically activates to supplement a complete performance test plan, platform profiling tool guide, and regression detection configuration.

## Basic Information

- **Name**: prd-performance-profile
- **Version**: 1.0.0
- **Compatibility**: Claude Code
- **Author**: timywel

## Trigger Keywords

- `prd-performance-profile`
- `性能剖析PRD`
- `PRD性能`
- `性能分析`
- `性能测试`
- Real-time / Real-time / Streaming
- Audio/video / Voice / Video playback
- Gaming / Game
- High-performance / Latency-sensitive
- Framerate / FPS / GPU

## Generated Chapter Content

1. **Performance Critical Path Identification Matrix** — Scans PRD features, evaluates performance sensitivity of each module
2. **Performance Test Plan** — 6 major test dimensions: startup, response latency, memory, CPU, framerate, package size
3. **Platform Performance Profiling Tool Guide** — macOS (Instruments), iOS (Instruments), Android (Profiler), Web (Lighthouse)
4. **Performance Regression Detection Configuration** — CI integration plan and baseline management strategy
5. **Performance Optimization Strategy Library** — Cross-platform bottleneck types and optimization solutions reference table

## Directory Structure

```
prd-performance-profile/
├── SKILL.md                              # Skill definition main file
├── README.md                             # This file
└── references/                           # Platform performance tool detailed references
    ├── macos-performance-guide.md        # macOS Instruments complete guide
    ├── ios-performance-guide.md          # iOS Instruments + MetricKit guide
    ├── android-performance-guide.md      # Android Profiler + Systrace + Perfetto guide
    └── web-performance-guide.md          # Lighthouse + DevTools + RUM guide
```

## Integration Notes

This skill is orchestrated by prd-orchestrator. When the PRD document is analyzed by prd-orchestrator and performance-related keywords are detected, the orchestrator invokes this skill to generate the performance profiling chapter, which is then merged into the end of the PRD document.

In the Agent context, the tool hints point to this skill's SKILL.md as the complete reference, and the references files provide platform-specific deep-dive operational guides.

## Activation Conditions

- **Auto-activation**: When prd-orchestrator detects trigger keywords
- **Manual activation**: User sends `/prd-performance-profile` or "生成性能剖析章节" (generate performance profiling chapter)
- **Prerequisite**: Requires analyzed PRD content (provided by prd-orchestrator)

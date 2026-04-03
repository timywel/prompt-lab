# PRD Performance Profile Skill

## 概述

prd-performance-profile 是为 PRD 文档自动生成性能剖析章节的技能扩展。当 PRD 涉及实时系统、音视频、游戏或高性能需求时，该技能自动激活，补充完整的性能测试计划、平台剖析工具指南和回归检测配置。

## 基本信息

- **名称**: prd-performance-profile
- **版本**: 1.0.0
- **兼容性**: Claude Code
- **作者**: Claude Code Agent

## 触发关键词

- `prd-performance-profile`
- `性能剖析PRD`
- `PRD性能`
- `性能分析`
- `性能测试`
- 实时 / Real-time / 流式
- 音视频 / 语音 / 视频播放
- 游戏 / Game
- 高性能 / Latency-sensitive
- 帧率 / FPS / GPU

## 生成的章节内容

1. **性能关键路径识别矩阵** — 扫描 PRD 功能，评估每个模块的性能敏感度
2. **性能测试计划** — 6 大测试维度：启动、响应延迟、内存、CPU、帧率、包体积
3. **平台性能剖析工具指南** — macOS (Instruments)、iOS (Instruments)、Android (Profiler)、Web (Lighthouse)
4. **性能回归检测配置** — CI 集成方案和基准管理策略
5. **性能优化策略库** — 跨平台的瓶颈类型与优化方案对照表

## 目录结构

```
prd-performance-profile/
├── SKILL.md                              # 技能定义主文件
├── README.md                             # 本文件
└── references/                           # 平台性能工具详细参考
    ├── macos-performance-guide.md        # macOS Instruments 完整指南
    ├── ios-performance-guide.md          # iOS Instruments + MetricKit 指南
    ├── android-performance-guide.md      # Android Profiler + Systrace + Perfetto 指南
    └── web-performance-guide.md          # Lighthouse + DevTools + RUM 指南
```

## 集成说明

该技能由 prd-orchestrator 协调调用。当 PRD 文档经过 prd-orchestrator 分析后，如果检测到性能相关关键词，orchestrator 会调用本技能生成性能剖析章节，并将其合并到 PRD 文档的末尾。

在 Agent 上下文中，工具提示指向本技能的 SKILL.md 作为完整参考，各 references 文件提供平台特定的深度操作指南。

## 激活条件

- **自动激活**: prd-orchestrator 检测到触发关键词时
- **手动激活**: 用户发送 `/prd-performance-profile` 或 "生成性能剖析章节"
- **前置条件**: 需要有已分析的 PRD 内容（由 prd-orchestrator 提供）

# prd-autofill: 全自动 PRD 生成器

## 功能

一句话想法 → 完整可执行的 PRD 文档。

## 使用方法

在 Claude Code 中，当你想生成 PRD 时，直接描述你的想法：

```
帮我生成一个 macOS 菜单栏语音输入 App 的 PRD
```

系统会自动：
1. **意图识别** — 检测平台、功能、交互模式、约束条件
2. **知识检索** — 从6大平台知识库中获取规范
3. **技术推断** — 选择具体的技术实现方案
4. **量化填充** — 补充性能/UI/兼容性参数
5. **PRD 组装** — 按标准模板生成完整文档
6. **自检验证** — 4项检查确保无占位符和歧义

输出位置：`docs/prd/<app-name>-prd.md`

## 覆盖的平台

- ✅ macOS 桌面应用（Swift/AppKit/SwiftUI, CGEventTap, NSPanel 等）
- ✅ iOS App（Swift/UIKit, AVFoundation, Speech, Vision 等）
- ✅ Android App（Kotlin/Compose, ML Kit, Firebase 等）
- ✅ Web 应用（React/Vue, Web Speech API, WebRTC 等）
- ✅ CLI 工具（Go/Rust/Python, cobra/clap 等）
- ✅ Chrome Extension（Manifest V3, content scripts 等）

## 核心能力

| 能力 | 说明 |
|------|------|
| 意图识别 | 从一句话推断平台、功能、交互、约束 |
| 技术选型 | 语音/持久化/网络/文本注入/输入法处理 |
| 量化参数 | 性能/UI/兼容性的默认值自动填充 |
| 反面案例 | 通用+平台特定的避坑指南 |
| 自检验证 | 占位符/量化/一致性/可执行性4项检查 |

## 版本历史

- 1.0.0: 初始版本，支持6大平台，覆盖意图识别、平台知识库、技术选型、量化参数、反面案例、标准PRD模板、自检机制

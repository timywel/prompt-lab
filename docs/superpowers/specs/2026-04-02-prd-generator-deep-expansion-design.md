# 方案C设计文档：深度扩展型 PRD 生成器

## 状态
已接受

## 上下文
需要设计一个 PRD 生成器 agent/skill，用户已有初步PRD（如粗略的功能列表或半成品的规格说明），系统从架构设计、UI/UX精确化、工程化、边界条件等多个维度进行深度扩展，输出完整的可执行PRD。

---

## 1. 核心设计理念

### 1.1 与前两种方案的关系

| 维度 | 方案A（AutoFill） | 方案B（Conversational） | 方案C（Deep Expansion） |
|------|------------------|------------------------|------------------------|
| **输入** | 一句话想法 | 多轮对话答案 | 初步PRD |
| **输出** | 完整PRD | 用户确认的PRD | 深度扩展PRD |
| **核心能力** | 知识库补全 | 需求挖掘 | 深度扩展 |
| **用户参与** | 无 | 高 | 中（可选确认） |
| **适用阶段** | 概念期 | 需求期 | 规划期/设计期 |

### 1.2 核心原则

1. **保持原意**：所有扩展都在用户提供的输入基础上进行，不做大幅重构
2. **多维度覆盖**：架构、UI/UX、工程化、测试、安全、运维 六个维度缺一不可
3. **双向扩展**：既有"正面扩展"（补充遗漏），也有"反面扩展"（识别风险）
4. **可选确认**：用户可以选择性地确认每个扩展方向，也可以一键跳过全部

---

## 2. 多维度扩展框架

### 2.1 六维度扩展模型

```
用户输入的初步PRD
    │
    ├── 维度1: 架构设计扩展
    │       ├─ 技术栈细化
    │       ├─ 模块划分
    │       ├─ 数据流设计
    │       └─ 依赖关系
    │
    ├── 维度2: UI/UX 精确化扩展
    │       ├─ 布局规范（具体px值）
    │       ├─ 组件规范（样式、状态）
    │       ├─ 动画规范（时长、曲线）
    │       ├─ 交互细节（手势、反馈）
    │       └─ 无障碍规范
    │
    ├── 维度3: 工程化扩展
    │       ├─ 构建系统
    │       ├─ 依赖管理
    │       ├─ CI/CD 流程
    │       ├─ 部署策略
    │       └─ 监控告警
    │
    ├── 维度4: 测试策略扩展
    │       ├─ 单元测试要求
    │       ├─ UI/集成测试
    │       ├─ 性能测试指标
    │       └─ 安全测试
    │
    ├── 维度5: 边界条件扩展
    │       ├─ 异常处理
    │       ├─ 网络边界（离线/弱网）
    │       ├─ 输入边界（大文本、极端值）
    │       ├─ 并发边界
    │       └─ 安全边界
    │
    └── 维度6: 运维支持扩展
            ├─ 日志规范
            ├─ 配置管理
            ├─ 升级策略
            └─ 数据迁移
```

---

## 3. 各维度详细设计

### 3.1 维度1: 架构设计扩展

#### 3.1.1 技术栈细化

对于用户描述的每个功能，推断并添加具体的技术实现路径：

| 功能描述 | → 推断技术栈 |
|---------|------------|
| "语音输入" | macOS: Speech Framework (SFSpeechRecognizer); iOS: Speech + AVFoundation; Android: SpeechRecognizer |
| "本地存储" | macOS: UserDefaults / SQLite.swift; iOS: UserDefaults / CoreData / SQLite |
| "全局快捷键" | macOS: CGEvent tap / HotKey; iOS: 无法实现（App Extension有限制） |
| "菜单栏应用" | macOS: NSStatusItem + LSUIElement; Electron: Tray API |
| "浮窗" | macOS: NSPanel (nonactivatingPanel); iOS: UIPresentationController |
| "AI集成" | OpenAI API / Claude API / 本地模型 (LLaMA.cpp) |

#### 3.1.2 模块划分

将功能分解为独立模块，每个模块遵循：
- **单一职责**：一个模块只做一件事
- **清晰边界**：模块之间通过接口通信
- **可独立测试**：可以单独编译和测试

示例模块划分（macOS语音输入App）：
```
VoiceInput/
├── App/
│   ├── AppDelegate.swift          # 应用入口、菜单栏设置
│   └── main.swift                # 手动入口（非@main）
├── Core/
│   ├── AudioEngine/               # 音频录制与RMS计算
│   ├── SpeechRecognizer/          # 流式语音识别
│   ├── LLMRefiner/                # LLM文本优化
│   └── TextInjector/              # 文本注入（剪贴板+模拟粘贴）
├── UI/
│   ├── FloatingWindow/            # 胶囊浮窗（NSPanel）
│   ├── WaveformView/              # 波形动画组件
│   └── StatusMenu/                # 菜单栏菜单
├── InputMethod/
│   └── InputSourceSwitcher/        # CJK输入法检测与切换
├── Settings/
│   └── UserPreferences/           # UserDefaults 封装
└── Utils/
    ├── AccessibilityPermission/   # 辅助功能权限
    └── ClipboardManager/           # 剪贴板管理
```

### 3.2 维度2: UI/UX 精确化扩展

#### 3.2.1 布局规范

将抽象描述转换为具体数值：

| 抽象描述 | → 精确化参数 |
|---------|-------------|
| "底部居中的浮窗" | `y = screenHeight - 120px`, `x = (screenWidth - capsuleWidth) / 2` |
| "胶囊形状" | `height = 56px`, `cornerRadius = 28px` |
| "波形在左、文字在右" | waveform: 44×32px, leftPadding: 12px; text: rightPadding: 20px |
| "弹性宽度" | `minWidth = 160px`, `maxWidth = 560px` |
| "水平布局" | 波形与文字之间: 12px间距 |

#### 3.2.2 组件规范

为每个UI组件定义完整规范：

**波形动画组件（NSPanel内）**：
```yaml
WaveformView:
  size: 44×32px
  bars: 5个垂直条形
  bar_weights: [0.5, 0.8, 1.0, 0.75, 0.55]  # 从左到右
  bar_width: 4px
  bar_spacing: 3px
  max_height: 32px
  min_height: 4px
  envelope:
    attack: 40%   # RMS上升时的响应速度
    release: 15%  # RMS下降时的衰减速度
  jitter: ±4% random per bar per frame
  fps: 60
```

**胶囊浮窗（NSPanel）**：
```yaml
FloatingCapsule:
  material: NSVisualEffectView.Material.hudWindow
  height: 56px
  corner_radius: 28px
  horizontal_padding: 0  # 无额外水平padding
  animation:
    entry: spring(damping: 0.7, duration: 0.35s)
    text_width: ease_in_out(duration: 0.25s)
    exit: scale(to: 0.8, opacity: 0, duration: 0.22s)
  window_level: .floating
  collection_behavior: [.canJoinAllSpaces, .nonactivatingPanel]
```

#### 3.2.3 动画规范

| 动画类型 | 时长 | 缓动曲线 | 触发条件 |
|---------|------|---------|---------|
| 浮窗出现 | 0.35s | spring(damping: 0.7) | 开始录音 |
| 浮窗文字宽度变化 | 0.25s | ease-in-out | 实时转写文本增长 |
| 波形响应 | 每帧更新 | 即时跟随RMS | 音频RMS变化 |
| 浮窗消失 | 0.22s | scale(0.8) + fade | 结束录音 |

### 3.3 维度3: 工程化扩展

#### 3.3.1 构建系统

| 平台 | 构建工具 | 依赖管理 | 输出 |
|------|---------|---------|------|
| macOS/iOS | XcodeGen + Swift PM | Swift Package Manager | .app bundle |
| macOS CLI | Swift Package Manager | SPM | 可执行文件 |
| Android | Gradle | Gradle / Maven | APK / AAB |
| Web | Vite / Next.js | npm | dist/ |
| Electron | electron-builder | npm | .app / .exe |

#### 3.3.2 Makefile 模板（macOS App）

```makefile
.PHONY: build run install clean test lint

APP_NAME = VoiceInput
BUNDLE_ID = com.example.VoiceInput
SIGNING_IDENTITY = "-"
SPM_PACKAGES = --package-path .

build:
	xcodebuild -project $(APP_NAME).xcodeproj -scheme $(APP_NAME) \
		-configuration Release build SPM_PACKAGES

run:
	open -a $(APP_NAME).app

install:
	mkdir -p ~/Library/Application\ Support/$(APP_NAME)
	cp -r $(APP_NAME).app ~/Library/Application\ Support/
	ln -sf ~/Library/Application\ Support/$(APP_NAME)/$(APP_NAME).app \
		~/Library/LaunchAgents/

clean:
	xcodebuild clean
	rm -rf build/
	rm -rf .build/
```

#### 3.3.3 CI/CD 流程

```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│  Push    │───▶│  Lint    │───▶│  Build   │───▶│  Test    │
│  PR      │    │  & Scan  │    │  (PR)    │    │  (PR)    │
└──────────┘    └──────────┘    └──────────┘    └──────────┘
                                                          │
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│  Merge   │───▶│  Build   │───▶│  Code    │───▶│  Release │
│  Main    │    │  (Main)  │    │  Sign    │    │  / Deploy│
└──────────┘    └──────────┘    └──────────┘    └──────────┘
```

### 3.4 维度4: 测试策略扩展

#### 3.4.1 测试金字塔

```
        ┌─────────┐
        │  E2E    │  ← 少量关键路径
        │  Tests  │
       ┌┴─────────┴┐
       │ Integration│  ← API契约、模块交互
       │   Tests   │
      ┌┴───────────┴┐
      │  Unit Tests │  ← 每个模块的核心逻辑
      │             │
      └─────────────┘
```

#### 3.4.2 平台特定测试

**macOS App 测试覆盖要求**：
```swift
// 必须覆盖的测试场景
- AudioEngine: 正常录音 / 无麦克风权限 / 音频中断
- SpeechRecognizer: 正常识别 / 网络不可用 / 无语音权限
- TextInjector: 普通输入框 / CJK输入法 / 无焦点窗口
- LLMRefiner: 正常响应 / 超时 / API错误 / 空输入
- FloatingWindow: 出现动画 / 消失动画 / 多屏幕适配
- InputSourceSwitcher: 检测CJK输入法 / 切换到ASCII / 恢复
```

### 3.5 维度5: 边界条件扩展

#### 3.5.1 边界条件识别矩阵

对于每个功能模块，识别以下边界条件：

| 边界类型 | 示例 |
|---------|------|
| **输入边界** | 空输入、超长文本（>10万字）、特殊字符、emoji |
| **时序边界** | 快速连续操作、长时间运行、后台切换 |
| **资源边界** | 内存不足、磁盘满、网络不可用 |
| **并发边界** | 多线程访问同一资源、竞态条件 |
| **环境边界** | 深色/浅色模式、Dynamic Type、VoiceOver |
| **安全边界** | 输入注入、XSS、权限绕过 |

#### 3.5.2 反面案例生成

为每个功能模块生成"避坑指南"：

```markdown
### 功能: 文本注入

**不要做:**
- ❌ 不要直接发送键盘事件（容易被安全软件拦截）
- ❌ 不要假设剪贴板当前为空（可能覆盖用户数据）
- ❌ 不要在粘贴前不切换输入法（CJK输入法会拦截Cmd+V）

**应该做:**
- ✅ 保存原有剪贴板内容，注入后恢复
- ✅ 检测当前输入法，CJK输入法切换到ASCII后再粘贴
- ✅ 使用CGEvent模拟按键，CGEventTap注入Fn按下事件
```

### 3.6 维度6: 运维支持扩展

#### 3.6.1 日志规范

```swift
// 统一日志格式
// [TIMESTAMP] [LEVEL] [MODULE] [Message] [Context]

// 示例:
// [2026-04-02T14:28:59.123Z] [INFO] [SpeechRecognizer] "Recording started" ["duration": "unbounded", "language": "zh-CN"]
// [2026-04-02T14:29:05.456Z] [WARN] [AudioEngine] "Low RMS level detected" ["rms": 0.02, "threshold": 0.05]
// [2026-04-02T14:29:10.789Z] [ERROR] [LLMRefiner] "API request failed" ["error": "timeout", "retry": 1]
```

日志级别策略：
- **DEBUG**: 开发环境，详细流程日志
- **INFO**: 生产环境，关键操作日志（录音开始/结束、注入成功）
- **WARN**: 生产环境，可恢复的错误（网络重试）
- **ERROR**: 生产环境，不可恢复的错误（需要告警）

---

## 4. 扩展执行策略

### 4.1 执行顺序

```
用户输入初步PRD
    ↓
1. 初步分析（识别PRD的结构和完整性）
    ↓
2. 维度选择（用户可选：全部 / 指定维度 / 快速模式）
    ↓
3. 逐维度扩展（每个维度独立扩展，可并行）
    ↓
4. 冲突检测（检查维度之间的矛盾）
    ↓
5. 合并与格式化
    ↓
6. 可选：用户确认循环
    ↓
最终 PRD 输出
```

### 4.2 快速模式 vs 完整模式

| 模式 | 维度覆盖 | 输出时长 | 适用场景 |
|------|---------|---------|---------|
| 快速模式 | 架构 + UI/UX + 工程化 | ~5分钟 | 时间紧迫 |
| 完整模式 | 全部6个维度 | ~15-20分钟 | 重要项目 |
| 确认模式 | 全部6个维度 + 用户确认 | ~30分钟 | 关键项目 |

### 4.3 冲突检测

维度扩展时可能产生冲突：
- UI要求动画流畅 → 但性能要求内存<20MB → 矛盾
- 使用第三方库 → 但要求完全离线 → 矛盾
- 支持VoiceOver → 但使用自定义波形UI → 需要添加无障碍描述

冲突通过警告形式呈现，让用户选择优先级。

---

## 5. 与前两种方案的协作

```
方案B（交互式）
    ↓ 用户选择"深度扩展"
    ↓
方案C（深度扩展）
    ↓ 或者
方案A（全自动）──▶ 方案C（深度扩展）
```

三个方案可以串联使用：
1. 方案B快速收集需求
2. 方案A补充技术细节
3. 方案C进行深度扩展

---

## 6. 后续计划

设计确认后，进入实现阶段。


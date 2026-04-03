# 方案A：全自动补全型 PRD 生成器实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 构建一个 Claude Code Skill，用户输入一句话想法，自动补全所有技术细节，输出可直接投喂给大模型执行的完整 PRD 文档。

**Architecture:** 核心是一个精心设计的 Skill prompt，包含意图识别规则、平台知识库（6大平台）、技术选型规则库、量化参数生成器、反面案例库和标准 PRD 模板。技能以 YAML 注册文件 + Markdown 内容文件的形态存在，输出格式为 Markdown 文档。

**Tech Stack:** Claude Code Skill (YAML + Markdown prompt), 无需外部依赖

---

## 文件结构

```
.claude/
├── skills/
│   ├── _registry.yaml                          # 技能注册表
│   └── prd-autofill/
│       ├── _definition.yaml                     # 技能元信息
│       └── _content.md                          # 技能主体（意图识别 + 知识库 + 模板 + 自检）
```

---

## Task 1: 创建技能目录和注册表

**Files:**
- Create: `.claude/skills/_registry.yaml`
- Create: `.claude/skills/prd-autofill/_definition.yaml`
- Create: `.claude/skills/prd-autofill/_content.md`

### Step 1: 创建 `_registry.yaml` 注册表

如果文件不存在，创建技能注册表；如果已存在，在其中添加 prd-autofill 条目。

**判断方法：** 先读取 `.claude/skills/_registry.yaml`，如果文件不存在或为空，则创建完整注册表；如果已存在，检查是否已有其他技能条目，如有则追加 prd-autofill 条目。

注册表格式如下：

```yaml
skills:
  - name: prd-autofill
    path: prd-autofill
    description: "全自动 PRD 生成器：输入一句话想法，自动补全技术细节，输出可执行 PRD"
    trigger: prd
    version: "1.0.0"
```

### Step 2: 创建 `_definition.yaml`

```yaml
name: prd-autofill
version: "1.0.0"
description: "全自动 PRD 生成器：输入一句话想法，自动补全技术细节，输出可执行 PRD"
triggers:
  - prd
  - 生成PRD
  - 产品需求文档
author: Claude Code Agent
```

### Step 3: 创建 `_content.md`

先创建包含完整 PRD 模板的骨架文件（知识库和意图识别规则在 Task 2-4 中逐步填入）：

```markdown
# PRD 自动填充生成器

用户输入一句话想法，自动补全所有技术细节，输出可直接投喂给大模型执行的完整 PRD 文档。

## 使用方法

当用户请求生成 PRD 时，调用本技能。按照以下流程执行：

1. 意图识别（见下方规则）
2. 知识库检索（见各平台规范）
3. PRD 组装（使用标准模板）
4. 自检验证（占位符 + 量化 + 一致性 + 可执行性检查）
5. 输出到文件或直接显示

---

## 意图识别规则

（将在 Task 2 中填入完整的意图识别逻辑）
```

### Step 4: 提交

```bash
git add .claude/skills/
git commit -m "feat(skill): 创建 prd-autofill 技能骨架和注册表"
```

---

## Task 2: 实现意图识别层 + 平台知识库

**Files:**
- Modify: `.claude/skills/prd-autofill/_content.md`

### Step 1: 替换意图识别章节

找到 `_content.md` 中的 `## 意图识别规则` 章节，用以下内容替换：

````markdown
## 意图识别规则

### 平台检测优先级

按以下关键词从用户输入中识别平台：

| 平台 | 关键词 | 检测正则 |
|------|--------|---------|
| macOS 桌面应用 | "mac", "macOS", "menu bar", "menu-bar", "dock", "app" | `\b(mac|macOS|menu[- ]?bar|dock)\b` |
| iOS App | "ios", "iOS", "iPhone", "iPad", "app store" | `\b(ios|iOS|iPhone|iPad)\b` |
| Android | "android", "Android", "apk" | `\bandroid\b` |
| Web 应用 | "web", "website", "网页", "浏览器", "frontend", "frontend" | `\b(web|website|frontend)\b` |
| 后端/API | "backend", "后端", "api", "API", "server" | `\b(backend|后端|api|API|server)\b` |
| 跨平台 | "flutter", "react native", "electron", "跨平台" | `\b(flutter|react[- ]?native|electron|跨平台)\b` |
| CLI 工具 | "cli", "命令行", "terminal", "终端", "command line" | `\b(cli|command[- ]?line|terminal|终端|命令行)\b` |
| Chrome Extension | "chrome", "extension", "插件", "browser extension" | `\b(chrome|extension|插件|browser)\b` |

**注意**：如果用户未明确指定平台但提到了具体功能（如"语音输入"），根据功能推断最可能的目标平台：
- 语音输入/全局快捷键/menu bar → macOS
- 相机拍照/AR → iOS/Android
- 网页爬虫/数据展示 → Web

### 功能类型识别

识别以下功能关键词，映射到技术方案：

| 功能关键词 | 推断功能类型 | 推断技术方案 |
|-----------|------------|------------|
| 语音, 录音, 说话, 麦克风 | 语音输入 | Speech Framework (macOS/iOS) / Web Speech API / Vosk |
| 图像, 拍照, 扫描, OCR | 图像处理 | AVFoundation / Vision Framework / OpenCV |
| 菜单栏, menu bar, tray | 菜单栏应用 | NSStatusItem / Electron Tray |
| 全局, global, 快捷键, hotkey | 全局热键 | CGEvent tap (macOS) / GlobalShortcuts (Electron) |
| 浮窗, floating, overlay | 浮窗/覆盖层 | NSPanel / Electron BrowserWindow |
| 翻译, translate | 翻译功能 | MLKit / Apple Neural Engine / OpenAI API |
| AI, LLM, 智能, GPT, Claude | AI 集成 | OpenAI API / Claude API / 本地模型 |
| 通知, push | 推送通知 | APNs / FCM |
| 登录, 注册, auth | 用户认证 | OAuth / JWT / Firebase Auth |
| 支付, purchase, 内购 | 支付集成 | IAP / Stripe / 支付宝/微信 |
| 离线, offline | 离线能力 | Service Worker / 本地数据库 |
| 实时, 直播, 流, streaming | 实时通信 | WebSocket / WebRTC |
| 地图, GPS, 定位 | 位置服务 | CoreLocation / Google Maps |
| 蓝牙, BLE | 蓝牙通信 | CoreBluetooth |
| 备份, 同步, 云 | 云同步 | Firebase / CloudKit / 自建后端 |

### 交互模式识别

| 交互关键词 | 交互模式 |
|-----------|---------|
| 按住, hold, release | 按住触发/释放结束 |
| 语音, 说话 | 语音交互 |
| 手势, swipe, pinch | 手势交互 |
| 键盘, 快捷键 | 键盘驱动 |
| 鼠标, 点击 | 点击驱动 |
| 自动化, auto | 后台自动化 |

### 约束条件识别

| 约束关键词 | 约束类型 |
|-----------|---------|
| 快速, 实时, <100ms | 性能约束 |
| 离线, 无网络 | 网络约束 |
| 保密, 安全, 不上传 | 安全约束 |
| 小体积, <10MB | 体积约束 |
| 省电, 低功耗 | 能耗约束 |
| 兼容, 支持老版本 | 兼容性约束 |
| 开源, open source | 许可证约束 |

---

## 平台知识库

（将在 Task 3 中填入完整的平台知识库内容）
````

### Step 2: 提交

```bash
git add .claude/skills/prd-autofill/_content.md
git commit -m "feat(skill): 实现意图识别层和平台检测规则"
```

---

## Task 3: 实现平台知识库（6大平台）

**Files:**
- Modify: `.claude/skills/prd-autofill/_content.md`

### Step 1: 在平台知识库章节填入以下内容

找到 `## 平台知识库` 章节，用以下完整内容替换：

````markdown
## 平台知识库

### 3.1 macOS 桌面应用

**语言推荐**: Swift（首选）, Objective-C, Python (scripting only)

**UI 框架选择**:
- SwiftUI（macOS 12+，现代声明式）
- AppKit（macOS 全版本，稳定强大）
- 混合：AppKit 做容器 + SwiftUI 做视图

**必需权限 / Entitlements**:
```xml
<key>com.apple.security.device.microphone</key>
<true/>
<key>com.apple.security.app-sandbox</key>
<true/>
<key>com.apple.security.automation.apple-events</key>
<true/>
```
> 注意：启用 App Sandbox 后，全局 CGEvent tap 需要关闭沙盒或使用 Accessibility API 申请辅助功能权限

**常见系统集成 API**:
- `CGEventTap` — 全局键盘/鼠标事件监听
- `NSEvent.addGlobalMonitorForEvents` — 全局事件监控（需辅助功能权限）
- `NSStatusItem` — 菜单栏图标
- `NSWorkspace` — App 切换、窗口管理
- `TISInputSource` — 输入法切换
- `SFSpeechRecognizer` — 语音识别
- `AVAudioEngine` — 音频录制与 RMS 分析
- `NSPanel` — 无边框浮窗（nonactivatingPanel）
- `NSVisualEffectView` — 毛玻璃效果

**构建工具**: XcodeGen + Swift Package Manager

**分发要求**:
- LSUIElement = true → 无 Dock 图标，菜单栏应用
- 代码签名（Development / Distribution）
- 公证 (Notarization) — macOS 10.15+ 必须

**特殊模式**:
- LSUIElement: Info.plist 中设置 `LSUIElement = YES`
- App Sandbox: entitlements 文件
- Hardened Runtime: 允许受限 API 访问

### 3.2 iOS App

**语言推荐**: Swift（首选）, Objective-C

**UI 框架选择**:
- SwiftUI（iOS 14+，推荐）
- UIKit（iOS 全版本，完整控制）
- SpriteKit / SceneKit（游戏/3D）

**必需权限 (Info.plist)**:
```xml
NSMicrophoneUsageDescription — 麦克风
NSCameraUsageDescription — 相机
NSPhotoLibraryUsageDescription — 照片库
NSLocationWhenInUseUsageDescription — 位置
NSFaceIDUsageDescription — Face ID
```

**常见系统集成 API**:
- AVFoundation — 音频/视频录制
- Speech Framework — 语音识别
- Vision Framework — 图像分析/OCR
- Core ML — 机器学习
- ARKit — AR 功能
- CoreBluetooth — 蓝牙
- CoreLocation — GPS

**构建工具**: Xcode + Swift Package Manager / CocoaPods

**App Store 要求**:
- 应用图标（1024×1024）
- 截图（多尺寸）
- 隐私政策 URL
- 分级（Age Rating）

### 3.3 Android App

**语言推荐**: Kotlin（首选）, Java

**UI 框架选择**:
- Jetpack Compose（推荐，现代声明式）
- XML + View（传统）

**必需权限 (AndroidManifest.xml)**:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
```

**常见系统集成 API**:
- SpeechRecognizer — 语音识别
- ML Kit — 翻译/OCR/图像标签
- Firebase — 认证/数据库/推送
- CameraX — 相机
- Room — 本地数据库

**构建工具**: Gradle + Android Gradle Plugin

**发布要求**:
- 签名密钥（debug / release）
- APK / AAB 格式
- Google Play Console 上传

### 3.4 Web 应用

**前端框架**:
- React（生态最全）
- Vue（上手简单）
- Svelte（Bundle 最小）
- Next.js / Nuxt.js（全栈框架）

**UI 组件库**:
- macOS 风格: Ionica（开源）/ MacOS UI
- iOS 风格: UIKit Svelte / iOS-Components
- Material: Material Design / Ant Design
- Tailwind CSS（样式工具）

**常见 Web API**:
- Web Speech API — 语音识别/合成
- MediaDevices API — 麦克风/摄像头
- WebSocket — 实时通信
- Service Worker — 离线/PWA
- WebRTC — 点对点通信
- Clipboard API — 剪贴板

**后端选项**:
- Node.js + Express / Fastify
- Python + FastAPI / Django
- Go + Gin
- Serverless: Vercel / Cloudflare Workers

**数据库选项**:
- PostgreSQL（关系型）
- MongoDB（文档型）
- Redis（缓存/实时）
- Supabase / Firebase（后端即服务）

**构建工具**: Vite / Webpack / esbuild

**部署**: Vercel / Netlify / Cloudflare Pages / 自建

### 3.5 CLI 工具

**语言推荐**: Go（跨平台编译简单）/ Rust（性能极致）/ Python（快速脚本）/ Swift（macOS 原生）

**常用库**:
- Go: cobra / urfave/cli（命令行框架）
- Rust: clap（命令行解析）
- Python: click / argparse

**安装方式**:
- Homebrew: `brew install`
- npm global: `npm install -g`
- 直接下载二进制

**构建工具**:
- Go: `go build`
- Rust: `cargo build --release`
- Swift: `swift build`

### 3.6 Chrome Extension

**Manifest V3**（2023年后必需）

**核心文件**:
- `manifest.json` — 扩展配置
- `background.js` — 后台脚本
- `content.js` — 注入到网页的脚本
- `popup.html/js` — 弹窗 UI
- `options.html/js` — 设置页面

**常见 API**:
- `chrome.runtime` — 消息通信
- `chrome.storage` — 存储
- `chrome.tabs` — 标签页管理
- `chrome.tabs.executeScript` — 注入脚本
- `chrome.commands` — 快捷键

**权限示例**:
```json
{
  "permissions": ["storage", "tabs", "activeTab"],
  "host_permissions": ["<all_urls>"]
}
```
````

### Step 2: 提交

```bash
git add .claude/skills/prd-autofill/_content.md
git commit -m "feat(skill): 实现6大平台知识库（macOS/iOS/Android/Web/CLI/ChromeExt）"
```

---

## Task 4: 实现技术选型规则库 + 量化参数生成器 + 反面案例库

**Files:**
- Modify: `.claude/skills/prd-autofill/_content.md`

### Step 1: 添加技术选型规则库章节

在 `_content.md` 末尾添加以下内容：

````markdown
---

## 技术选型规则库

### 语音输入技术选型

| 场景 | macOS | iOS | Android | Web |
|------|-------|-----|---------|-----|
| 流式语音识别 | `SFSpeechRecognizer` + `AVAudioEngine` | `SFSpeechRecognizer` + `AVAudioEngine` | `SpeechRecognizer` | `webkitSpeechRecognition` |
| 离线语音识别 | Vosk (via Swift Package) | Vosk / ONNX | Vosk | 不支持 |
| LLM 语音优化 | OpenAI Whisper API / Claude API | 同左 | 同左 | 同左 |
| 麦克风权限 | `NSMicrophoneUsageDescription` | 同上 | `RECORD_AUDIO` | `getUserMedia` |

### 数据持久化技术选型

| 场景 | 推荐方案 | 备选 |
|------|---------|------|
| 简单配置/状态 | UserDefaults | SharedPreferences |
| 结构化数据 < 1MB | SQLite.swift | Realm / CoreData |
| 大规模数据 | PostgreSQL + 后端 | Firebase Firestore |
| 离线优先 | SQLite + 云端同步 | Realm + Sync |

### 网络通信技术选型

| 场景 | 推荐方案 | 说明 |
|------|---------|------|
| REST API 调用 | URLSession (Swift) / Fetch (JS) | 标准方案 |
| WebSocket 实时 | URLSessionWebSocketTask (macOS 10.15+) | 原生支持 |
| 流式响应 | AsyncSequence / SSE | 长连接场景 |
| 文件上传/下载 | URLSession downloadTask | 大文件支持 |
| API 鉴权 | Bearer Token / API Key | 根据后端要求 |

### 文本注入技术选型（桌面应用）

| 平台 | 方案 | 说明 |
|------|------|------|
| macOS | 剪贴板 + `CGEvent` 模拟 Cmd+V | 需辅助功能权限 |
| macOS | `NSPasteboard` + Accessibility | 备用方案 |
| Electron | `clipboard.writeText` + `robotjs` | 跨平台 |
| iOS | 无法实现（沙盒限制） | 可用 Share Extension |
| Android | AccessibilityService + InputMethodManager | 需特殊权限 |

### 输入法处理策略（CJK输入）

当检测到目标 App 使用 CJK（中日韩）输入法时：
1. 注入前：保存剪贴板内容
2. 注入前：切换到 ASCII 输入源（如 ABC / US Keyboard）
3. 执行粘贴（Cmd+V / Ctrl+V）
4. 注入后：恢复原始输入源
5. 注入后：恢复剪贴板内容

macOS 实现：使用 `TISInputSource` API 遍历可用的输入源，找到 `kTISCategoryKeyboardInputSource` 类别中 ID 为 `com.apple.keylayout.ABC` 或 `com.apple.keylayout.US` 的源并切换。

---

## 量化参数生成器

### 性能指标默认值

根据功能类型，自动填充以下性能指标（如用户未指定）：

| 指标类型 | 默认值 | 说明 |
|---------|-------|------|
| 启动时间 | < 2s | 从点击图标到可交互 |
| 首次响应 | < 500ms | 用户操作到视觉反馈 |
| 语音识别延迟 | < 300ms | 说话结束到文字出现 |
| API 响应超时 | 10s | 外部 API 调用 |
| 内存占用（移动） | < 100MB | 正常运行峰值 |
| 内存占用（桌面） | < 200MB | 正常运行峰值 |
| 包体积（iOS） | < 50MB | App Store 上传 |
| 包体积（macOS） | < 100MB | 直接分发 |
| 电池影响 | < 5%/小时 | 后台持续运行 |

### UI 量化默认值

| 组件类型 | 参数 |
|---------|------|
| 按钮高度 | macOS: 22px, iOS: 44px (tap target), Android: 48dp |
| 图标尺寸 | 16×16 (toolbar), 24×24 (content), 32×32 (list) |
| 圆角 | 按钮: 8px, 卡片: 12px, 浮窗: 16-28px |
| 间距基数 | 8px（所有间距为此值的倍数） |
| 浮窗高度 | 菜单项: 36px, 通知: 56px, 模态: 动态 |
| 动画时长 | 微交互: 150ms, 视图切换: 300ms, 复杂动画: 500ms |
| 动画缓动 | 标准: ease-in-out, 弹簧效果: spring(damping: 0.7) |

### 兼容性默认值

| 平台 | 默认最低版本 |
|------|------------|
| macOS | macOS 12 (Monterey) |
| iOS | iOS 16 |
| Android | API 24 (Android 7.0), Target: API 34 |
| Web | 最近2个 Chrome/Firefox/Safari 版本 |
| Chrome Extension | Manifest V3, Chrome 88+ |

---

## 反面案例库

### 通用反面案例

| 功能 | 错误做法 | 正确做法 |
|------|---------|---------|
| 动画 | hardcoded 假动画，数据和动画脱节 | 用真实 RMS 驱动波形，音频参数映射到视觉参数 |
| 网络请求 | 假设网络总是可用 | 优雅降级：离线模式 + 重试机制 + 用户提示 |
| 异步操作 | 在主线程执行耗时操作 | 使用 GCD / async-await / Worker |
| 权限 | 不处理权限拒绝或未请求 | 清晰解释为什么需要权限，提供替代方案 |
| 敏感数据 | 日志中打印敏感信息 | 使用模糊化日志，敏感字段打码 |
| 剪贴板 | 不保存原有剪贴板内容 | 先保存，注入后恢复 |
| CJK 输入法 | 直接粘贴，不切换输入法 | 检测输入法类型，必要时切换到 ASCII 后再粘贴 |
| 全局热键 | 冲突检测缺失 | 注册前检查是否已被占用，冲突时提示用户 |

### macOS 特定反面案例

- ❌ **不要**在 App Sandbox 开启时尝试使用 `CGEventTap`（会被拒绝），申请 Accessibility 权限或关闭沙盒
- ❌ **不要**使用 `NSTimer` 驱动波形动画（不精确），使用 `CADisplayLink` 或 `CVDisplayLink`
- ❌ **不要**假设只有一种输入法，中文用户可能用搜狗/百度/系统拼音
- ❌ **不要**在非激活 Panel 中处理键盘事件（`NSPanel` 的 `makeFirstResponder` 行为不同）
- ❌ **不要**在后台持续录音而不释放麦克风资源（会导致其他 App 无法使用麦克风）

### iOS 特定反面案例

- ❌ **不要**使用私有 API（App Store 会拒绝）
- ❌ **不要**在后台持续录音（系统会强制终止，需要申请 `audio` background mode）
- ❌ **不要**假设设备有刘海屏，提供 safe area 适配
- ❌ **不要**忽略 `Info.plist` 中的 usage description，权限请求前必须填写

### Web 特定反面案例

- ❌ **不要**假设 `getUserMedia` 在所有浏览器都支持（必须检查 Feature Detection）
- ❌ **不要**在生产环境使用 `console.log` 输出敏感信息
- ❌ **不要**将 API Key 直接写在前端代码中（使用后端代理或环境变量）
- ❌ **不要**忽略 CORS 策略，API 调用必须处理跨域
- ❌ **不要**使用 `alert()` 作为用户通知（阻塞 UI），使用 toast/notification
````

### Step 2: 提交

```bash
git add .claude/skills/prd-autofill/_content.md
git commit -m "feat(skill): 实现技术选型规则库+量化参数生成器+反面案例库"
```

---

## Task 5: 实现标准 PRD 模板 + 自检机制 + 协调层

**Files:**
- Modify: `.claude/skills/prd-autofill/_content.md`

### Step 1: 在文件开头替换骨架内容

找到 `_content.md` 顶部的骨架内容，用以下完整内容替换：

````markdown
# PRD 自动填充生成器

用户输入一句话想法，自动补全所有技术细节，输出可直接投喂给大模型执行的完整 PRD 文档。

## 工作流程

当用户请求生成 PRD 时，按照以下步骤执行：

1. **接收输入** — 读取用户的想法描述
2. **意图识别** — 根据 `## 意图识别规则` 识别平台、功能、交互、约束
3. **知识检索** — 根据识别结果，从 `## 平台知识库` 获取对应平台的规范
4. **技术推断** — 根据 `## 技术选型规则库` 为每个功能选择技术方案
5. **量化填充** — 使用 `## 量化参数生成器` 中的默认值填充性能/UI参数
6. **反面补充** — 根据 `## 反面案例库` 为每个功能添加避坑指南
7. **PRD 组装** — 按照下方 `## 标准 PRD 模板` 组装文档
8. **自检验证** — 运行 `## 自检机制` 检查
9. **输出** — 保存到文件（`docs/prd/<app-name>-prd.md`）或直接输出

---

## 标准 PRD 模板

所有生成的 PRD 必须严格遵循以下格式：

```markdown
# [App名称] PRD

> 由 PRD 自动填充生成器 生成
> 生成时间: [YYYY-MM-DD]
> 目标平台: [识别出的平台]
> 技术栈: [推断的技术栈]

---

## 1. 项目概述

- **项目类型**: [平台类型，如 macOS 桌面应用]
- **目标平台**: [最低版本要求]
- **核心功能**: [用户描述的核心功能]
- **技术栈**: [语言 + 主要框架 + 构建工具]
- **构建工具**: [具体构建命令]

## 2. 功能模块

### 2.1 [功能名称]

**描述**: [用户描述 + 推断的完整描述]

**技术实现**:
- **核心 API**: [具体 API 名称和用途]
- **输入/触发**: [具体触发方式，如"按住 Fn 键"]
- **处理流程**: [步骤化的处理逻辑]
- **输出结果**: [具体的输出形式]

**量化参数**:
- 响应时间: < [数值]ms
- 资源占用: < [数值]MB
- [其他可量化指标]

**UI/UX 规范**（如有界面）:
- 窗口/组件尺寸: [具体 px 值]
- 布局: [具体位置和间距]
- 视觉: [颜色/字体/风格]
- 动画: [时长 + 缓动曲线]

**反面案例**:
- ❌ [不要做的具体事情] — [原因]

**边界条件**:
- [异常情况]: [处理方式]
- [边界输入]: [处理方式]

### 2.2 [下一个功能模块...]

---

## 3. 系统集成

- **权限需求**: [具体权限列表和用途]
- **系统 API**: [具体使用的系统 API]
- **特殊行为**: [LSUIElement / 后台运行 / Accessibility 等]

## 4. 工程化要求

- **构建方式**: [具体构建命令]
- **依赖管理**: [具体的包管理器]
- **测试要求**: [测试覆盖要求]
- **发布要求**: [签名/打包/分发方式]

## 5. 参考反面案例

[汇总所有功能模块的反面案例]

---

## 6. 边界条件汇总

[汇总所有边界条件和异常处理]
```

---

## 自检机制

生成 PRD 后，必须通过以下 4 项检查。任何一项失败都需要修复：

### 检查1: 占位符扫描
搜索以下模式，如果存在则必须替换为具体内容：
- `[TODO]` / `[TBD]` / `[待定]` / `[未填写]`
- `[具体 API 名称]` → 必须填入真实 API 名称
- `[具体数值]` → 必须填入估算的数值
- `[]`（空括号）→ 必须填入内容或删除该项

### 检查2: 量化检查
确认以下字段都有具体数值：
- 性能指标（响应时间、内存占用、包体积）
- UI 参数（尺寸、间距、动画时长）
- 版本要求（最低版本号）

如果用户未指定，使用 `## 量化参数生成器` 中的默认值。

### 检查3: 一致性检查
- 所有功能模块使用的技术栈必须一致（不要混用 Swift 和 Python，除非有明确理由）
- 所有权限需求必须与功能对应（不能要求麦克风权限却不使用麦克风）
- 动画参数不能相互矛盾（如声明 "无动画" 又描述动画效果）

### 检查4: 可执行性检查
逐个阅读每个功能模块的"技术实现"章节，问自己：
- 大模型看到这个描述，是否还需要问"这个功能具体怎么实现"？
- 如果需要追问 → 补充更多细节
- 具体标准：每个功能必须包含**核心 API 名称** + **具体触发方式** + **步骤化的处理流程**

---

## 协调层执行伪代码

当用户说 "帮我生成一个 [想法] 的 PRD"，按以下伪代码执行：

```
1. input = 用户输入的想法
2. intent = recognizeIntent(input)
   // 返回 { platform, features[], interactions[], constraints[] }
3. kb = loadPlatformKB(intent.platform)
4. techRules = loadTechRules()
5. quantDefaults = loadQuantDefaults()
6. antiPatterns = loadAntiPatterns()
7. modules = []
8. for feature in intent.features:
   - tech = matchTechRules(feature, kb, techRules)
   - quant = generateQuant(feature, quantDefaults)
   - anti = matchAntiPatterns(feature, antiPatterns)
   - module = assembleModule(feature, tech, quant, anti)
   - modules.append(module)
10. prd = assemblePRD(intent, modules, kb)
11. issues = selfCheck(prd)
12. if issues.length > 0:
    - prd = fixIssues(prd, issues)
    - goto 11
13. output(prd)
```
````

### Step 2: 提交

```bash
git add .claude/skills/prd-autofill/_content.md
git commit -m "feat(skill): 实现标准PRD模板+自检机制+协调层"
```

---

## Task 6: 端到端测试 — 用参考 prompt 验证输出

**Files:**
- Create: `.claude/skills/prd-autofill/_test.md` （测试用例和预期输出）
- Modify: `.claude/skills/prd-autofill/_content.md` （根据测试结果修复）

### Step 1: 创建测试用例文档

```markdown
# prd-autofill Skill 测试用例

## 测试用例 1: macOS 语音输入 App（参考 prompt 还原）

**输入**:
```
帮我生成一个 macOS 菜单栏语音输入 App 的 PRD，按住 Fn 录音，松开注入文字，支持中文，默认中文识别。
```

**预期输出应包含**:
- [ ] 平台: macOS 桌面应用
- [ ] 核心功能: 全局 Fn 键监听 + 流式语音识别 + 文本注入
- [ ] 具体 API: SFSpeechRecognizer, AVAudioEngine, CGEvent tap, NSPanel, TISInputSource
- [ ] 量化参数: 56px 浮窗高度, 28px 圆角, 波形动画参数
- [ ] CJK 输入法处理机制（剪贴板+输入源切换）
- [ ] LLM 集成说明
- [ ] LSUIElement 模式
- [ ] SPM + Makefile 构建方式
- [ ] 无占位符 [TODO]/[TBD]
- [ ] 有具体的动画参数（0.35s 弹簧动画等）
- [ ] 有反面案例

**验证方法**: 运行技能，用参考 prompt 输入，检查输出是否包含以上所有要素。

## 测试用例 2: 模糊输入 → 自动推断

**输入**:
```
做一个语音输入的东西
```

**预期**: 自动检测为语音输入 → 推断为 macOS（最可能）→ 补充菜单栏 App 形态 → 生成完整 PRD

**预期输出应包含**:
- [ ] 平台推断: macOS（或询问用户确认）
- [ ] 技术方案: 语音识别框架
- [ ] 核心功能: 录音 → 识别 → 注入
- [ ] 所有量化参数都有具体数值

## 测试用例 3: iOS 拍照翻译 App

**输入**:
```
做一个 iOS 拍照翻译 App
```

**预期输出应包含**:
- [ ] 平台: iOS App
- [ ] 具体 API: AVFoundation, Vision Framework / ML Kit, CameraX
- [ ] 权限: NSMicrophoneUsageDescription, NSCameraUsageDescription
- [ ] UI: 相机取景框 + 翻译结果覆盖层
- [ ] 量化: 启动时间 < 2s, 翻译延迟 < 1s
```

### Step 2: 手动验证（基于测试用例执行）

使用 `/skill prd-autofill` 命令激活技能（如果 Claude Code 支持直接激活），或直接在对话中模拟技能行为：

1. **读取技能内容**: 读取 `.claude/skills/prd-autofill/_content.md`
2. **执行工作流程**: 按照技能中的工作流程处理参考 prompt
3. **输出结果**: 生成 `docs/prd/macos-voice-input-prd.md`
4. **对照检查**: 对比预期要素列表

### Step 3: 根据测试结果修复

如果测试发现以下问题，修复对应章节：
- 缺少具体 API → 检查意图识别和技术选型规则
- 量化参数不足 → 补充量化参数生成器
- 有占位符残留 → 使用自检机制修复
- 输出格式不一致 → 检查 PRD 模板

### Step 4: 提交

```bash
git add .claude/skills/prd-autofill/
git add docs/prd/
git commit -m "test(skill): 端到端测试并修复发现的问题"
```

---

## Task 7: 最终整合 + 文档

**Files:**
- Create: `.claude/skills/prd-autofill/README.md` — 使用说明
- Modify: `_content.md` — 最终格式调整

### Step 1: 创建 README.md

```markdown
# prd-autofill: 全自动 PRD 生成器

## 功能

一句话想法 → 完整可执行的 PRD 文档。

## 使用方法

在 Claude Code 中，当你想生成 PRD 时，可以：
1. 直接描述你的想法（如"做一个 macOS 菜单栏语音输入 App"）
2. 或激活技能后描述想法

系统会自动：
- 识别目标平台和技术栈
- 补充平台知识库中的规范
- 生成量化参数和反面案例
- 输出结构化的 PRD 文档

## 输出位置

PRD 文档默认保存到 `docs/prd/<app-name>-prd.md`

## 覆盖的平台

- ✅ macOS 桌面应用
- ✅ iOS App
- ✅ Android App
- ✅ Web 应用
- ✅ CLI 工具
- ✅ Chrome Extension

## 测试

参见 `_test.md` 中的测试用例。
```

### Step 2: 最终提交

```bash
git add .claude/skills/prd-autofill/
git commit -m "feat: 完成 prd-autofill 技能实现

- 意图识别层（平台/功能/交互/约束检测）
- 6大平台知识库（macOS/iOS/Android/Web/CLI/ChromeExt）
- 技术选型规则库（语音/持久化/网络/文本注入/输入法）
- 量化参数生成器（性能/UI/兼容性默认值）
- 反面案例库（通用+平台特定）
- 标准PRD模板（7章节结构）
- 4项自检机制（占位符/量化/一致性/可执行性）
- 端到端测试用例"
```

---

## 自我审查清单

完成实现后，逐项检查：

- [ ] **Spec 覆盖**: 设计文档的每个要点都有对应的实现
  - [ ] 意图识别层 → Task 2 ✅
  - [ ] 平台知识库 → Task 3 ✅
  - [ ] 技术选型规则库 → Task 4 ✅
  - [ ] 量化参数生成器 → Task 4 ✅
  - [ ] 反面案例库 → Task 4 ✅
  - [ ] 标准 PRD 模板 → Task 5 ✅
  - [ ] 自检机制 → Task 5 ✅
  - [ ] 端到端测试 → Task 6 ✅

- [ ] **占位符扫描**: 搜索 `[TODO]` / `[TBD]` / `[待定]` — 应无结果
- [ ] **一致性检查**: 所有 `## 标题` 层级正确，markdown 格式有效
- [ ] **注册表验证**: `.claude/skills/_registry.yaml` 包含 prd-autofill 条目


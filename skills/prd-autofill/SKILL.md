---
name: prd-autofill
description: "全自动 PRD 生成器：输入一句话想法，自动补全技术细节，输出可执行 PRD"
version: "1.0.0"
compatibility: "Claude Code"
metadata:
  triggers:
    - prd
    - 生成PRD
    - 产品需求文档
  author: timywel
---

# PRD 自动填充生成器

用户输入一句话想法，自动补全所有技术细节，输出可直接投喂给大模型执行的完整 PRD 文档。

## 使用方法

当用户请求生成 PRD 时，调用本技能。按照以下流程执行：

1. **意图识别** — 根据 `## 意图识别规则` 识别平台、功能、交互、约束
2. **知识检索** — 根据识别结果，从 `## 平台知识库` 获取对应平台的规范
3. **技术推断** — 根据 `## 技术选型规则库` 为每个功能选择技术方案
4. **量化填充** — 使用 `## 量化参数生成器` 中的默认值填充性能/UI参数
5. **反面补充** — 根据 `## 反面案例库` 为每个功能添加避坑指南
6. **PRD 组装** — 按照下方 `## 标准 PRD 模板` 组装文档
7. **自检验证** — 运行 `## 自检机制` 检查（占位符/量化/一致性/可执行性）
8. **输出** — 保存到文件（`docs/prd/<app-name>-prd.md`）或直接输出

---

## 意图识别规则

### 平台检测优先级

按以下关键词从用户输入中识别平台：

| 平台 | 关键词 | 检测正则 |
|------|--------|---------|
| macOS 桌面应用 | "mac", "macOS", "menu bar", "menu-bar", "dock", "app" | `\b(mac|macOS|menu[- ]?bar|dock)\b` |
| iOS App | "ios", "iOS", "iPhone", "iPad", "app store" | `\b(ios|iOS|iPhone|iPad)\b` |
| Android | "android", "Android", "apk" | `\bandroid\b` |
| Web 应用 | "web", "website", "网页", "浏览器", "frontend" | `\b(web|website|frontend)\b` |
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
- macOS 风格: Ionica（开源）/ Macos UI
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

## 6. 边界条件汇总

[汇总所有边界条件和异常处理]

## 7. 一键升级

本PRD已包含核心功能模块、技术实现和量化参数。如需更深入的工程化内容，可通过以下方式升级：

### 自动升级到完整版

说"深度扩展这个PRD"，本PRD将作为初步PRD输入，自动进行六维度深度扩展。

### 手动升级章节

如只需补充特定章节，可参考以下路径：
- **架构设计** → 复制方案C第3章内容
- **YAML组件规范** → 复制方案C第4章的WaveformView/FloatingWindow YAML
- **测试场景** → 复制方案C第6章的25项具体测试场景
- **CI/CD流水线** → 复制方案C第5章的完整GitHub Actions YAML
- **运维支持** → 复制方案C第8章的日志规范和升级策略

### 质量保证

完整版PRD包含：
- ✅ 14项自检清单全部通过
- ✅ 无占位符，无矛盾冲突
- ✅ 量化参数一致性交叉验证
- ✅ 5个潜在冲突识别与解决方案
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

补充说明：完整自检请参考 `../_shared/qa-checks/self-review-checklist.md` 中的 13 项逐条检查清单。

---

## 深度扩展参考

当用户需要更深入的 PRD 时，以下章节对应方案C（prd-deep-expand）的完整版本：

| 本方案章节 | 简化程度 | 完整版本参考 |
|-----------|---------|------------|
| 架构设计 | 简化依赖矩阵 | 方案C 第3章：完整dot数据流图 + 11模块接口契约 |
| 测试策略 | 框架性描述 | 方案C 第6章：25项具体测试场景 + 10项性能指标 |
| UI/UX规范 | 文字描述 | 方案C 第4章：YAML组件规范（WaveformView/FloatingWindow）|
| 边界条件 | 15条概述 | 方案C 第7章：26条边界矩阵 + 6类分类 |
| 工程化 | 命令级描述 | 方案C 第5章：12-target Makefile + 完整CI/CD YAML |

### 快速升级到完整版

用户可以在方案A生成后说"深度扩展这个PRD"直接调用 prd-deep-expand skill，自动读取方案A的输出作为初步PRD进行六维度扩展。

### 共享知识库

本方案引用的以下共享资源可提供额外支持：
- `_shared/platform-configs/macos-infoplist.yaml` — 完整的Info.plist XML模板
- `_shared/platform-configs/macos-entitlements.yaml` — 完整的Entitlements XML模板
- `_shared/test-templates/test-pyramid-template.md` — 完整的测试金字塔模板
- `_shared/qa-checks/self-review-checklist.md` — 14项自检清单

### 与方案B/C的协作

```
方案B（对话挖掘需求）→ 方案A（快速生成PRD）→ 方案C（深度扩展）
     ↓                      ↓                        ↓
 14个问题               961行简化版              1619行完整版
                    +一键升级路径              +六维度覆盖
```

---

## 测试策略

生成的 PRD 应包含完整的测试策略章节，引用 test-pyramid-template.md 的三层金字塔模型。

### 测试金字塔

```yaml
TestPyramid:
  E2E:
    ratio: "10%"
    覆盖场景: "关键用户路径（录音→识别→注入）"
  Integration:
    ratio: "30%"
    覆盖场景: "模块间交互（AudioEngine → SpeechRecognizer）"
  Unit:
    ratio: "60%"
    覆盖场景: "每个模块的核心逻辑"
```

### 平台特定测试场景

| 模块 | 单元测试（每模块 3-5 个用例） | 集成测试 | E2E 测试 |
|------|-----------------------------|---------|---------|
| App/入口 | 启动参数解析 / 参数校验 / 环境检测 | 多平台启动流程 | 完整启动到就绪路径 |
| Core/Audio | 正常录音 / 无麦克风权限 / 音频中断 / 静音检测 | AudioEngine → SpeechRecognizer 数据流 | 按住热键 → 录音 → 识别 → 注入 |
| Core/Speech | 正常识别 / 网络不可用 / 无语音权限 / 空音频 | SpeechRecognizer → LLMRefiner 调用链 | 语音输入 → 文本注入目标应用 |
| Core/LLM | 正常响应 / 超时 / API 错误 / 空输入 / 限流处理 | LLMRefiner → FloatingWindow 输出 | 长文本 → LLM 优化 → 注入 |
| UI/Floating | 出现动画 / 消失动画 / 多屏幕适配 / 窗口层级 | FloatingWindow → WaveformView 联动 | 浮窗显示 → 波形动画 → 隐藏 |
| InputMethod | 检测 CJK 输入法 / 切换到 ASCII / 恢复原输入法 | InputSourceSwitcher → TextInjector 协同 | 切换输入法 → 注入 → 恢复输入法 |
| Settings | 配置读写 / 默认值填充 / 迁移逻辑 | Settings → Core 各模块配置注入 | 修改设置 → 验证生效 |
| Utils | 日志写入 / 权限请求 / 剪贴板存取 | 跨模块工具调用 | 工具函数全链路 |

> 注意：具体测试用例数量和覆盖范围应根据用户选择的"测试要求"（Q14）进行调整。MVP 场景可简化为仅保留 E2E 关键路径测试。

---

## 架构设计

生成的 PRD 应包含简化的模块划分章节，每个模块应有明确的职责定义和依赖关系。

### 模块划分（6 个子目录）

```
[AppName]/
├── App/                    # 应用入口和生命周期
│   ├── main.swift          # 应用入口
│   ├── AppDelegate.swift   # 生命周期管理
│   └── AppState.swift      # 全局状态管理
├── Core/                   # 核心业务逻辑（按功能域划分）
│   ├── Audio/              # 音频采集（AVAudioEngine / Web Audio API）
│   ├── Speech/             # 语音识别（SFSpeechRecognizer / Web Speech API）
│   ├── LLM/                # LLM 优化（OpenAI / Claude / 本地模型）
│   └── Text/               # 文本处理和注入
├── UI/                     # 视图层（所有 UI 组件）
│   ├── FloatingWindow/     # 浮窗/覆盖层（macOS: NSPanel / iOS: UIPresentationController）
│   ├── WaveformView/        # 波形动画组件
│   └── StatusMenu/         # 菜单栏/状态栏组件
├── InputMethod/            # 系统集成层（输入法相关）
│   ├── InputSourceSwitcher.swift   # 输入法切换（TISInputSource）
│   └── TextInjector.swift          # 文本注入（CGEvent / Accessibility）
├── Settings/               # 配置管理层
│   ├── UserPreferences.swift      # 配置读写（UserDefaults）
│   └── SettingsView.swift          # 设置界面
└── Utils/                  # 工具层（跨模块复用）
    ├── Logger.swift              # 日志工具
    ├── PermissionManager.swift   # 权限请求和管理
    └── ClipboardManager.swift    # 剪贴板管理
```

### 模块依赖关系

| 模块 | 直接依赖 | 被依赖 |
|------|---------|-------|
| App | Core, UI, Settings | - |
| Core/Audio | Utils/PermissionManager | UI/WaveformView, Core/Speech |
| Core/Speech | Core/Audio | UI/FloatingWindow, Core/LLM |
| Core/LLM | Utils/Logger | UI/FloatingWindow |
| Core/Text | InputMethod/TextInjector | - |
| UI/FloatingWindow | Core/Audio, Core/Speech | - |
| UI/WaveformView | Core/Audio | - |
| InputMethod/TextInjector | InputMethod/InputSourceSwitcher | - |
| InputMethod/InputSourceSwitcher | Utils/ClipboardManager | - |
| Settings | App/AppState | App |

### 依赖原则

- **禁止反向依赖**：下层模块不得依赖上层模块（如 Core 不得依赖 UI）
- **单向依赖传递**：如需跨层访问，通过接口/协议解耦
- **Utils 层零依赖**：Utils 模块不得依赖任何其他业务模块
- **数据流单向**：用户输入 → Core 处理 → UI 展示，禁止 UI 层直接修改 Core 数据

> 注意：对于非 macOS/iOS 平台，模块名称和路径应替换为对应平台的等价实现（如 Core/Audio → AudioEngine）。

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
13. 如果用户请求或文档行数 < 600：
    - 提示："是否需要深度扩展？"
    - 如果用户同意 → 建议调用 prd-deep-expand
14. output(prd)
```

### 升级提示规则

在 `output(prd)` 执行前，如果满足以下任一条件，应提示用户考虑升级：
- 用户原始请求中包含"详细"、"完整"、"深度"等关键词
- 生成的 PRD 文档行数 < 600 行
- 功能模块数 >= 5 个但测试策略/工程化内容较为简略
- 架构设计中模块依赖关系描述不够具体

提示话术建议：
> "本PRD已完成核心功能模块设计（约 [X] 行）。如需更深入的工程化内容（完整数据流图、YAML组件规范、详细测试矩阵、CI/CD流水线等），请说'深度扩展这个PRD'，我将调用 prd-deep-expand skill 进行六维度扩展。"

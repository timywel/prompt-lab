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

## 标准 PRD 模板

（将在后续任务中填入完整的 PRD 模板）

---

## 自检机制

（将在后续任务中填入完整的自检机制）

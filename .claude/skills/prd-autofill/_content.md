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

（将在后续任务中填入完整的平台知识库）

---

## 标准 PRD 模板

（将在后续任务中填入完整的 PRD 模板）

---

## 自检机制

（将在后续任务中填入完整的自检机制）

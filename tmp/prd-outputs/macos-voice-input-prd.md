# macOS 菜单栏语音输入 App PRD

> 由 PRD 自动填充生成器 生成
> 生成时间: 2026-04-03
> 目标平台: macOS 桌面应用
> 技术栈: Swift + SwiftUI + AppKit 混合架构

---

## 1. 项目概述

- **项目类型**: macOS 菜单栏桌面应用（LSUIElement）
- **目标平台**: macOS 12 (Monterey) 及以上
- **核心功能**: 按住 Fn 键录音，松开后自动将语音转为文字并注入到当前焦点应用
- **技术栈**: Swift（主要语言）+ SwiftUI（浮窗视图）+ AppKit（系统集成）+ CGEventTap（全局事件）+ SFSpeechRecognizer（语音识别）+ AVAudioEngine（音频录制）
- **构建工具**: XcodeGen (project.yml) + Swift Package Manager
- **分发方式**: 代码签名 + 公证（Notarization），绕过 App Store 直接分发

## 2. 功能模块

### 2.1 Fn 键全局监听

**描述**: 在系统全局范围内监听 Fn 键的按下和释放事件，无需应用获得焦点。用户在任意应用中均可使用 Fn 键触发录音。

**技术实现**:
- **核心 API**: `CGEventTap`（`CGEvent.tapCreate`）配合 `kCGHIDEventTap` 位置；备选方案为 `NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged)`
- **输入/触发**: Fn 键按下（`keyCode = 63`）开始录音，Fn 键释放结束录音
- **处理流程**:
  1. 应用启动时，在后台线程创建 `CGEventTap`
  2. 注册 `CGEventCallback` 回调函数，监听 `kCGEventKeyDown` 和 `kCGEventKeyUp`，过滤 `keyCode == 63`（Fn 键）
  3. 首次使用时请求 Accessibility 权限（`AXIsProcessTrusted()`），若未授权则弹出系统偏好设置引导
  4. 检测到 Fn 按下时，发送通知触发录音模块
  5. 检测到 Fn 释放时，发送通知触发识别与注入流程
- **输出结果**: 发送 `NotificationCenter` 通知（`didPressFnKey`、`didReleaseFnKey`）给录音模块

**量化参数**:
- Fn 键按下到浮窗出现: < 100ms
- CGEventTap 事件传递延迟: < 10ms
- 内存占用: < 30MB（事件监听模块）
- CPU 占用（空闲时）: < 0.1%

**UI/UX 规范**:
- 无独立窗口，通过浮窗（见 2.3）提供视觉反馈
- 菜单栏仅保留状态图标（SF Symbol: `mic.fill`）

**反面案例**:
- ❌ 不要假设只有 Fn 键可用 — 用户可能自定义了 F1-F12 为功能键，此时 Fn 键映射不同，应提供配置项允许用户选择任意功能键或快捷键组合（如 Cmd+Shift+V）
- ❌ 不要使用 `NSEvent.addGlobalMonitorForEvents` 作为唯一方案 — 该方案在应用切换时可能漏事件，`CGEventTap` 更可靠
- ❌ 不要忽略 Fn 键与其他修饰键的组合 — Fn+Shift、Fn+Control 等场景需正确处理

**边界条件**:
- Accessibility 权限被拒绝: 弹出系统偏好设置引导，说明为何需要该权限，提供替代快捷键方案
- Fn 键被系统或其他应用占用: 检测到注册失败时，提示用户释放该按键绑定，并提供备用键配置
- 快速连续按放（tap）: 按下后 < 200ms 即释放时，忽略该操作，不触发录音

---

### 2.2 流式语音识别

**描述**: 使用 macOS 原生 Speech Framework，在 Fn 键按住期间持续录音并实时识别语音，支持中文（普通话）作为默认语言。松开 Fn 键后等待一小段时间（500ms）以容纳用户说完最后的句子，然后输出识别结果。

**技术实现**:
- **核心 API**: `SFSpeechRecognizer`（流式识别）+ `AVAudioEngine`（音频录制与 RMS 分析）
- **输入/触发**: 收到 `didPressFnKey` 通知后启动
- **处理流程**:
  1. 请求麦克风权限（`AVAudioSession` + `SFSpeechRecognizer.requestAuthorization`）
  2. 配置 `SFSpeechAudioBufferRecognitionRequest` 为实时模式（`shouldReportPartialResults = true`）
  3. 配置 `AVAudioEngine` 输入节点，安装 tap 监听 PCM 音频数据
  4. 将 `AVAudioPCMBuffer` 追加到 `SFSpeechAudioBufferRecognitionRequest`
  5. 启动 `recognitionTask`，实时回调 `resultHandler` 接收部分结果
  6. 收到 `didReleaseFnKey` 通知后，等待 500ms 缓冲时间（防止用户最后几个字未完成），然后调用 `endAudioSampleBuffer()` 结束录音
  7. 等待最终识别结果
  8. 将最终文字通过 `NotificationCenter`（`recognitionResult`）发送给注入模块
- **输出结果**: 字符串（识别后的文字），通过通知传递

**量化参数**:
- 启动录音到首次识别回调: < 300ms
- 单句语音识别延迟（从说话结束到文字出现）: < 500ms
- 内存占用（识别模块峰值）: < 120MB
- 音频采样率: 16kHz（Speech Framework 推荐）
- 缓冲区大小: 2048 samples

**反面案例**:
- ❌ 不要使用 `NSTimer` 驱动任何音频处理逻辑 — 不精确，应使用 `AVAudioEngine` 的 tap 回调
- ❌ 不要假设网络始终可用 — 应优先使用 `SFSpeechRecognizer` 的离线识别（`requiresOnDeviceRecognition = false` 且检测网络可用时），同时处理离线降级
- ❌ 不要在后台持续占用麦克风资源 — 录音结束后立即释放 `AVAudioEngine`，不要保持任何持久的音频会话
- ❌ 不要在主线程执行音频录制和识别回调 — 所有 `SFSpeechRecognizer` 回调在后台队列执行，注意线程安全地更新 UI

**边界条件**:
- 麦克风权限被拒绝: 弹出权限请求说明，若用户拒绝则降级为显示"请授权麦克风权限"提示
- 无语音输入（静音）: 识别结果为空字符串时，浮窗显示短暂提示"未检测到语音"后消失，不执行注入
- 识别结果包含大量语气词: 在后处理阶段（注入前）做简单清理（去除句首/句尾的语气词如"嗯"、"啊"、"呃"，使用正则替换）
- 网络不可用: 使用离线识别模式（`SFSpeechRecognizer` 默认离线识别中文，macOS 12+），若离线不可用则提示用户检查网络
- 录音时间过长（> 60s）: 自动停止录音并输出已识别内容，防止资源持续占用

---

### 2.3 录音状态浮窗

**描述**: 录音期间在屏幕底部居中显示一个半透明毛玻璃浮窗，展示实时波形动画和录音状态。

**技术实现**:
- **核心 API**: `NSPanel`（无边框浮窗）+ `NSVisualEffectView`（毛玻璃）+ `CADisplayLink`（波形动画驱动）
- **输入/触发**: 收到 `didPressFnKey` 通知后显示，收到 `didReleaseFnKey` 后切换为处理状态，注入完成后自动消失
- **处理流程**:
  1. 创建 `NSPanel`（`styleMask: [.borderless, .nonactivatingPanel]`），设为屏幕底部居中
  2. 覆盖 `canBecomeKey` 和 `canBecomeMain` 返回 `false`，确保不抢夺焦点
  3. 添加 `NSVisualEffectView` 作为背景（`material: .hudWindow`, `blendingMode: .behindWindow`）
  4. 在浮窗内添加波形视图（自定义 `NSView`，使用 Core Graphics 绘制柱状波形）
  5. 录音期间，`AVAudioEngine` 的 RMS 值通过通知发送到浮窗控制器
  6. 浮窗控制器使用 `CADisplayLink` 每帧更新波形视图（将 RMS 映射到柱状高度，范围 4-32px）
  7. 浮窗显示 500ms 淡入动画（`NSAnimationContext`），消失时 300ms 淡出
- **输出结果**: 视觉反馈，不产生数据

**量化参数**:
- 浮窗尺寸: 宽度 200px × 高度 56px
- 圆角: 28px（四角全圆角）
- 波形区域: 44px × 32px，12 个柱状条，每条宽度 2px，间距 1px
- 毛玻璃背景透明度: 0.75
- 浮窗距屏幕底部: 120px
- 动画时长: 淡入 300ms (ease-in-out)，淡出 300ms (ease-in-out)
- CADisplayLink 帧率: 与屏幕刷新率同步（60Hz / 120Hz ProMotion）

**UI/UX 规范**:
- 颜色: 波形柱为白色（`#FFFFFF`，透明度 0.9），背景为系统毛玻璃效果
- 字体: 无文字（纯视觉反馈），状态由波形动画传达
- 动画: RMS 驱动的实时波形，柱状高度在 4-32px 之间映射，过渡平滑（使用 `CGFloat` 插值）

**反面案例**:
- ❌ 不要在浮窗中使用假数据驱动的硬编码动画 — 必须用真实的 `AVAudioEngine` RMS 值驱动波形，与音频数据完全同步
- ❌ 不要让浮窗成为 key window — 使用 `nonactivatingPanel` 确保不干扰用户的输入焦点
- ❌ 不要在非激活 Panel 中错误地处理键盘事件 — 浮窗不需要响应任何键盘事件，其设计就是透明穿透

**边界条件**:
- 多显示器环境: 浮窗始终显示在包含当前鼠标位置的屏幕上（`NSScreen.screens` 检测 `NSEvent.mouseLocation` 所在屏幕）
- Retina 显示器: 使用 `backingScaleFactor` 确保波形绘制清晰
- 浮窗显示时被用户切换应用: 浮窗保持在原位置，不受应用切换影响（`NSPanel` 的 `level` 设为 `.floating`）

---

### 2.4 文本注入

**描述**: 将识别后的文字注入到当前焦点应用的光标位置。处理 CJK（中文/日文/韩文）输入法的兼容性问题。

**技术实现**:
- **核心 API**: `NSPasteboard`（剪贴板）+ `CGEvent`（模拟按键）+ `TISInputSource`（输入法切换）
- **输入/触发**: 收到 `recognitionResult` 通知后执行
- **处理流程**:
  1. 获取当前焦点应用（`NSWorkspace.shared.frontmostApplication`）
  2. 将识别文字写入 `NSPasteboard.general`
  3. 检测当前输入法是否为 CJK 类型（遍历 `TISInputSource` 的 `kTISCategoryKeyboardInputSource`，检查 `TISInputSourceID` 是否包含 "com.apple.assistant.siri" 以外的 CJK 布局 ID，如 "com.sogou.inputmethod.sogouPinyin"、"com.apple.keylayout.Pinyin-Simplified" 等；简化为检测 `TISCopyCurrentKeyboardInputSource()` 返回的 `TISInputSource` 的本地化名称是否包含中日韩字符）
  4. 如果是 CJK 输入法：
     a. 保存当前剪贴板内容到临时变量
     b. 使用 `TISInputSource` 切换到 ASCII 输入源（`com.apple.keylayout.ABC` 或 `com.apple.keylayout.US`）
     c. 执行模拟 Cmd+V（`CGEvent.post(tap: .cghidEventTap)`，构造 `keyDown` + `keyUp` 事件，`keyCode = 9`，修饰符 `cmd`）
     d. 恢复原始输入法（`TISSelectInputSource`）
     e. 恢复原始剪贴板内容（延迟 500ms 执行，避免被目标应用覆盖）
  5. 如果不是 CJK 输入法：直接执行模拟 Cmd+V
  6. 注入完成后发送 `injectionComplete` 通知，触发浮窗消失
- **输出结果**: 文字出现在目标应用的文本输入框中

**量化参数**:
- 注入延迟（从识别完成到文字出现在目标应用）: < 200ms
- 模拟按键间隔: keyDown 到 keyUp = 10ms
- Cmd+V 模拟总耗时: < 50ms

**反面案例**:
- ❌ 不要不保存原有剪贴板内容就写入 — 必须先保存，注入后恢复，防止用户剪贴板数据丢失
- ❌ 不要直接粘贴不检测输入法 — CJK 用户使用输入法时直接粘贴会导致文字进入输入法候选框而非直接注入
- ❌ 不要假设只有搜狗/百度/系统拼音三种 CJK 输入法 — 检测逻辑应覆盖所有 CJK 输入法，通过 `TISInputSource` 的 `Category` 和 `InputSourceID` 通用判断
- ❌ 不要在切换输入法时阻塞主线程 — `TISSelectInputSource` 是同步调用，但切换操作极快（< 50ms），可以接受
- ❌ 不要忽略目标应用可能是纯浏览器的场景 — 浏览器中也可能有 CJK 输入法，检测逻辑不应依赖 `NSWorkspace.frontmostApplication` 的 bundle ID 黑名单

**边界条件**:
- 目标应用不支持粘贴（如密码输入框、终端的某些模式）: 注入后检测文字是否真的出现（通过比较剪贴板内容前后），若未出现则尝试备用方案：在浮窗中显示识别结果，让用户手动复制
- 当前焦点不在文本输入框（焦点在菜单栏、 Dock 等）: 检测 `NSApp.keyWindow` 是否存在 `firstResponder`，若不存在则弹出通知"请将光标放在文本输入框中"
- 剪贴板写入失败（极少见）: 降级为键盘逐字模拟注入（`CGEvent` 模拟每个字符的 `keyDown`/`keyUp`），字符集映射使用 `CGEventKeyboardSetUnicodeString`
- 注入过程中用户快速切换应用: 使用 `[NSPasteboard generalPasteboard].clearContents()` 后的原子操作确保剪贴板状态一致

---

### 2.5 中文语言支持与配置

**描述**: 默认使用中文（普通话）进行语音识别，并在设置中允许用户切换语言偏好。

**技术实现**:
- **核心 API**: `SFSpeechRecognizer`（`locale` 属性）+ `UserDefaults`（偏好设置存储）
- **输入/触发**: 设置面板或首次启动时的语言选择
- **处理流程**:
  1. 应用启动时，从 `UserDefaults.standard` 读取 `speechLanguage` 键（默认为 `"zh-CN"`）
  2. 创建 `SFSpeechRecognizer(locale: Locale(identifier: languageCode))` 实例
  3. 验证该语言识别器是否可用（`SFSpeechRecognizer.isAvailable`）
  4. 若不可用（如系统不支持该语言），回退到 `"zh-CN"` 并提示用户
  5. 支持的语言列表: 中文（简体/繁体）、英文、日文、韩文
  6. 设置面板使用 SwiftUI `List` + `Picker` 实现语言选择
- **输出结果**: 存储在 `UserDefaults` 中的语言偏好

**量化参数**:
- 语言切换后下次录音生效: 无需重启，下次录音即生效
- 设置面板打开时间: < 500ms

**边界条件**:
- 系统不支持某语言: `isAvailable` 返回 `false`，自动降级到 `zh-CN` 并提示
- 语言切换时正在录音: 忽略语言切换请求，录音结束后生效

---

### 2.6 菜单栏状态与设置面板

**描述**: 菜单栏常驻图标，点击弹出设置面板，包含语言选择、快捷键配置、开机启动开关等选项。

**技术实现**:
- **核心 API**: `NSStatusItem`（菜单栏图标）+ SwiftUI（设置面板）
- **输入/触发**: 点击菜单栏图标
- **处理流程**:
  1. 在 `applicationDidFinishLaunching` 中创建 `NSStatusItem`（`button.image = NSImage(systemSymbolName: "mic.fill", accessibilityDescription: "VoiceInput")`）
  2. 设置左键点击事件，显示 SwiftUI `Popover`（macOS 12+ 支持 `init(attachmentAnchor:)` 方式锚定在 status item 上）
  3. 设置面板内容: 语言选择器、快捷键配置按钮、开机启动（`SMLoginItemSetEnabled`）、关于信息
  4. 右键点击显示上下文菜单，包含"设置"和"退出"两项
- **输出结果**: SwiftUI 视图显示

**UI/UX 规范**:
- 设置面板宽度: 320px
- 面板高度: 根据内容动态（最小 200px）
- 字体: SF Pro Text, 13pt（正文），16pt（标题）
- 颜色: 跟随系统外观（通过 SwiftUI `Color` 和 `preferredColorScheme`）

**边界条件**:
- 菜单栏图标在高对比度模式下: 使用 `NSImage.SymbolConfiguration` 配置 `hierarchicalColor` 适配

---

## 3. 系统集成

- **权限需求**:
  - 麦克风权限（`NSMicrophoneUsageDescription`）: "需要使用麦克风进行语音输入"
  - Accessibility 权限（运行时请求）: "需要此权限来监听 Fn 键事件"
- **系统 API**:
  - `CGEventTap` — 全局 Fn 键监听
  - `SFSpeechRecognizer` — 流式语音识别
  - `AVAudioEngine` — 音频录制与 RMS 分析
  - `NSPanel` + `NSVisualEffectView` — 毛玻璃浮窗
  - `CADisplayLink` — 波形动画帧驱动
  - `TISInputSource` — 输入法检测与切换
  - `NSPasteboard` + `CGEvent` — 文本注入（模拟 Cmd+V）
  - `NSStatusItem` — 菜单栏图标
  - `SMLoginItemSetEnabled` — 开机启动
- **特殊行为**:
  - `LSUIElement = YES` — 无 Dock 图标，纯菜单栏应用
  - App Sandbox: 关闭（`NO`）— CGEventTap 需要 Accessibility 权限，App Sandbox 与 Accessibility 不兼容，必须关闭沙盒
  - Hardened Runtime: 开启 — 允许 `com.apple.security.automation.apple-events`
  - 公证（Notarization）: 必须执行 — macOS 10.15+ 分发自签名应用需公证
  - LLM 集成: 可选功能（默认关闭）。如启用，可使用 OpenAI Whisper API 替代本地 `SFSpeechRecognizer` 进行识别精度优化（需用户在设置中填入 API Key）。配置文件路径: `~/.config/VoiceInput/llm-config.json`，包含字段: `{ "provider": "openai", "apiKey": "...", "model": "whisper-1" }`

## 4. 工程化要求

- **构建方式**:
  - XcodeGen: `xcodegen generate`（从 `project.yml` 生成 `.xcodeproj`）
  - Swift Package Manager: `swift build`（或 Xcode 中自动解析）
  - 打包: `xcodebuild -scheme VoiceInput -configuration Release archive`
- **依赖管理**:
  - Swift Package Manager（无外部 C/C++ 依赖，推荐）
  - 主要包: 无（完全使用 Apple 系统框架）
  - 可选包（LLM 增强）: `swift-openai`（第三方，OpenAI Whisper 集成）
- **测试要求**:
  - 单元测试: `XCTest`，覆盖率目标 > 60%，重点覆盖 Fn 键事件分发、识别结果清理、剪贴板保存/恢复逻辑
  - UI 测试: `XCUITest`，覆盖录音流程、设置面板交互
  - 集成测试: 手动测试覆盖主流 CJK 输入法（搜狗拼音、百度输入法、系统拼音、繁体注音）的注入兼容性
- **发布要求**:
  - 代码签名: Developer ID Application（`codesign --sign "Developer ID Application: ..."`）
  - 公证: `xcrun notarytool submit VoiceInput.zip --apple-id "..." --team-id "..." --password "..."`
  - 分发: 提供 `.zip` 下载，安装后引导用户授权 Accessibility 权限

## 5. 参考反面案例

### 通用反面案例

| 功能 | 错误做法 | 正确做法 |
|------|---------|---------|
| 波形动画 | hardcoded 假动画，数据和动画脱节 | 用真实 RMS 驱动波形，音频参数映射到视觉参数 |
| 网络请求 | 假设网络总是可用 | 优雅降级：离线模式 + 重试机制 + 用户提示 |
| 异步操作 | 在主线程执行耗时操作 | 使用 GCD / async-await / Worker |
| 权限 | 不处理权限拒绝或未请求 | 清晰解释为什么需要权限，提供替代方案 |
| 敏感数据 | 日志中打印敏感信息 | 使用模糊化日志，敏感字段打码 |
| 剪贴板 | 不保存原有剪贴板内容 | 先保存，注入后恢复 |
| CJK 输入法 | 直接粘贴，不切换输入法 | 检测输入法类型，必要时切换到 ASCII 后再粘贴 |
| 全局热键 | 冲突检测缺失 | 注册前检查是否已被占用，冲突时提示用户 |

### macOS 特定反面案例

- ❌ **不要**在 App Sandbox 开启时尝试使用 `CGEventTap` — 会被拒绝，必须关闭沙盒或申请 Accessibility 权限
- ❌ **不要**使用 `NSTimer` 驱动波形动画 — 不精确，使用 `CADisplayLink` 或 `CVDisplayLink`
- ❌ **不要**假设只有一种输入法 — 中文用户可能用搜狗/百度/系统拼音/繁体注音，需通用检测
- ❌ **不要**在非激活 Panel 中处理键盘事件 — `NSPanel` 的 `makeFirstResponder` 行为不同，本场景浮窗不需响应键盘
- ❌ **不要**在后台持续录音而不释放麦克风资源 — 会导致其他 App 无法使用麦克风，录音结束后立即释放
- ❌ **不要**在非文本输入框场景下执行注入 — 注入前验证焦点是否在可输入文本的控件上

## 6. 边界条件汇总

| 边界条件 | 处理方式 |
|---------|---------|
| Accessibility 权限被拒绝 | 弹出系统偏好设置引导，说明为何需要该权限，提供替代快捷键方案 |
| Fn 键被系统或其他应用占用 | 检测到注册失败时，提示用户释放该按键绑定，并提供备用键配置 |
| 快速连续按放（tap < 200ms） | 忽略该操作，不触发录音 |
| 麦克风权限被拒绝 | 弹出权限请求说明，若用户拒绝则降级为显示"请授权麦克风权限"提示 |
| 无语音输入（静音） | 识别结果为空字符串时，浮窗显示短暂提示"未检测到语音"后消失，不执行注入 |
| 录音时间过长（> 60s） | 自动停止录音并输出已识别内容，防止资源持续占用 |
| 识别结果包含语气词 | 在注入前做简单清理（去除句首/句尾的语气词如"嗯"、"啊"、"呃"，使用正则替换） |
| 网络不可用 | 使用离线识别模式（`SFSpeechRecognizer` 默认离线识别中文，macOS 12+） |
| 目标应用不支持粘贴 | 注入后检测文字是否出现，若未出现则在浮窗中显示识别结果，让用户手动复制 |
| 焦点不在文本输入框 | 检测 `NSApp.keyWindow.firstResponder`，若不存在则弹出通知"请将光标放在文本输入框中" |
| 剪贴板写入失败 | 降级为键盘逐字模拟注入（`CGEvent` 模拟每个字符的 keyDown/keyUp） |
| 多显示器环境 | 浮窗始终显示在包含当前鼠标位置的屏幕上 |
| 语言识别器不可用 | `isAvailable` 返回 `false` 时自动降级到 `zh-CN` 并提示用户 |
| 语言切换时正在录音 | 忽略语言切换请求，录音结束后生效 |

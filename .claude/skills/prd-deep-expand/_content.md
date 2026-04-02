# PRD 深度扩展生成器

用户已有初步 PRD（如粗略的功能列表或半成品规格），从六个维度进行深度扩展，输出完整的可执行 PRD。

## 技能激活

当用户说以下任意一句时激活本技能：
- "深度扩展 PRD"
- "扩展这个 PRD"
- "深化需求文档"
- "PRD 深度扩展"
- "六维度扩展"

激活后：
1. 请求用户提供初步 PRD（可以是 Markdown 文本或文件路径）
2. 读取并分析初步 PRD 的结构
3. 识别已有的内容（已覆盖哪些维度）
4. 识别缺失的内容（需要扩展哪些维度）
5. 展示分析结果，询问扩展模式
6. 开始逐维度扩展
7. 冲突检测
8. 合并输出

---

## 扩展流程

### 第一步: 接收初步 PRD

用户提供初步 PRD 后，分析其结构：

```
📋 初步 PRD 分析

已包含的内容：
✅ [列举已有的章节/模块]

缺失/需要扩展的内容：
⚠️ [列举缺失的维度]

建议的扩展顺序：
1. 维度1: 架构设计扩展
2. 维度2: UI/UX 精确化扩展
3. ...
```

### 第二步: 选择扩展模式

```
请选择扩展模式：

A. ⚡ 快速模式（架构 + UI/UX + 工程化，约5分钟）
   — 适合时间紧迫的场景

B. 🔬 完整模式（全部6个维度，约15分钟）
   — 适合重要项目

C. ✅ 确认模式（全部6个维度 + 每维度用户确认，约30分钟）
   — 适合关键项目

D. 🎯 指定维度（选择要扩展的维度）
   — 适合已有部分内容的PRD

请输入 A / B / C / D，或直接说"跳过选择，用完整模式"
```

### 第三步: 逐维度扩展

根据选择的模式，按以下顺序执行扩展：

| 维度 | 快速模式 | 完整模式 | 确认模式 |
|------|---------|---------|---------|
| 1. 架构设计 | ✅ | ✅ | ✅ |
| 2. UI/UX 精确化 | ✅ | ✅ | ✅ |
| 3. 工程化 | ✅ | ✅ | ✅ |
| 4. 测试策略 | ❌ | ✅ | ✅ |
| 5. 边界条件 | ❌ | ✅ | ✅ |
| 6. 运维支持 | ❌ | ✅ | ✅ |

每个维度扩展时：
- 展示该维度的扩展结果
- （确认模式）询问是否满意，是否需要调整
- 记录扩展结果到状态文件
- 自动进行冲突检测

## 六维度扩展规则

### 维度1: 架构设计扩展

#### 技术栈细化

对于初步 PRD 中描述的每个功能，自动推断并添加具体的技术实现路径：

| 功能关键词 | → macOS | → iOS | → Android | → Web |
|-----------|---------|-------|---------|-------|
| 语音/录音 | SFSpeechRecognizer + AVAudioEngine | 同左 | SpeechRecognizer | webkitSpeechRecognition |
| 全局快捷键 | CGEvent tap / NSEvent | 无法实现 | AccessibilityService | 浏览器快捷键限制 |
| 菜单栏应用 | NSStatusItem + LSUIElement | — | NotificationChannel | — |
| 浮窗/覆盖层 | NSPanel (nonactivatingPanel) | UIPresentationController | OverlayView | position: fixed |
| 文本注入 | CGEvent 模拟 Cmd+V | Share Extension | InputMethodService | document.execCommand |
| AI/LLM集成 | OpenAI API / Claude API | 同左 | 同左 | 同左 |
| 本地存储 | UserDefaults / SQLite.swift | UserDefaults / CoreData | Room / SharedPreferences | IndexedDB / localStorage |
| 网络请求 | URLSession | URLSession | Retrofit / OkHttp | fetch / axios |
| 推送通知 | UserNotifications | 同左 | FCM | Push API / Service Worker |
| 数据库 | SQLite.swift / CoreData | CoreData / SQLite | Room | PostgreSQL + API |

#### 模块划分规则

对于每个功能，自动推荐模块划分。规则：
- **UI 层**：所有视图/组件
- **业务逻辑层**：核心功能（音频/识别/注入）
- **数据层**：存储/网络/持久化
- **系统集成层**：权限/API/输入法
- **工具层**：辅助功能（日志/配置/权限管理）

示例（桌面语音输入App）：
```
VoiceInput/
├── App/              # 应用入口
├── Core/             # 核心业务（Audio/Speech/LLM/Text）
├── UI/               # 视图层（FloatingWindow/Waveform/StatusMenu）
├── InputMethod/      # 系统集成（输入法切换）
├── Settings/         # 配置管理
└── Utils/           # 工具（日志/权限/剪贴板）
```

#### 数据流设计

对于涉及多模块协作的功能，补充数据流图（dot格式）：

```dot
graph LR
    A[用户按下 Fn] --> B[CGEvent 监听]
    B --> C[AudioEngine 开始录音]
    C --> D[SFSpeech 实时识别]
    D --> E[RMS 驱动波形动画]
    E --> F[用户松开 Fn]
    F --> G[结束录音，等待结果]
    G --> H[TextInjector]
    H --> I[文本注入目标应用]
```

#### 依赖关系

识别模块间的依赖关系，补充依赖矩阵：

| 模块 | 依赖 | 被依赖 |
|------|------|-------|
| AudioEngine | AccessibilityPermission | SpeechRecognizer |
| SpeechRecognizer | AudioEngine, UserPreferences | LLMRefiner, FloatingWindow |
| TextInjector | InputSourceSwitcher, ClipboardManager | — |
| FloatingWindow | WaveformView | — |
| LLMRefiner | UserPreferences | — |

---

### 维度2: UI/UX 精确化扩展

#### 布局精确化

对于初步 PRD 中的 UI 描述，自动转换为具体数值：

| 抽象描述 | → 精确参数 |
|---------|-----------|
| "底部居中" | `y = screenHeight - floatingOffset`, `x = (screenWidth - width) / 2` |
| "胶囊形状" | `height = [具体px]`, `cornerRadius = height / 2` |
| "左图右文" | `leftRatio: 0.25`, `rightRatio: 0.75` |
| "弹性宽度" | `minWidth = [n]px`, `maxWidth = [m]px` |
| "8px间距" | 所有间距为 8 的倍数 |

#### 组件规范（YAML格式）

为每个 UI 组件生成 YAML 规范：

```yaml
ComponentName:
  type: "组件类型（浮窗/按钮/列表等）"
  size:
    width: "[具体值]px"
    height: "[具体值]px"
  layout:
    position: "[absolute/relative/flex]"
    alignment: "[center/left/right]"
    spacing: "[具体值]px"
  style:
    background: "[颜色/RGBA]"
    border_radius: "[具体值]px"
    shadow: "[有无]"
  material: "[平台特定材质，如 macOS: hudWindow, iOS: blur]"
  animation:
    trigger: "[触发条件]"
    duration: "[时长ms]"
    easing: "[缓动曲线]"
  states:
    default: "[默认状态]"
    active: "[激活状态]"
    disabled: "[禁用状态]"
```

#### 动画规范

| 动画类型 | macOS | iOS | Android | Web |
|---------|-------|-----|---------|-----|
| 出现动画 | NSView.animate(duration: 0.3) | UIView.animate(duration: 0.3) | ObjectAnimator | CSS transition |
| 消失动画 | 同上 + alpha 渐变 | 同上 | 同上 | CSS transition + opacity |
| 尺寸变化 | animator?.frame | UIView.animate | ViewPropertyAnimator | CSS transition |
| 加载动画 | CAAnimation | UIActivityIndicatorView | ProgressBar | CSS animation |

#### 无障碍规范

如果初步 PRD 提到以下场景，自动添加无障碍扩展：

| 场景 | → 添加的无障碍规范 |
|------|----------------|
| 视障用户 | VoiceOver (iOS) / NSAccessibility (macOS) / ARIA labels |
| 动态字体 | Dynamic Type (iOS) / NSAttributedString (macOS) |
| 高对比度 | prefersHighContrast / semantic colors |
| 键盘导航 | focus ring / tab order / keyboard shortcuts |
| 手势操作 | 额外提供按钮/菜单替代方案 |

---

### 维度3: 工程化扩展

#### 构建系统

根据平台补充具体构建命令：

| 平台 | 构建命令 | 依赖管理 |
|------|---------|---------|
| macOS Swift | `xcodebuild -project X.xcodeproj` | Swift Package Manager |
| macOS CLI | `swift build` | Swift Package Manager |
| iOS | `xcodebuild -project X.xcodeproj -scheme X` | SPM / CocoaPods |
| Android | `./gradlew assembleDebug` | Gradle / Maven |
| Web React | `npm run build` | npm / yarn |
| Web Vue | `npm run build` | npm |
| Electron | `electron-builder` | npm |
| Chrome Ext | `zip -r` 打包 | npm |

#### Makefile 模板（macOS App）

```makefile
.PHONY: build run install clean test lint

APP_NAME = VoiceInput
BUNDLE_ID = com.example.VoiceInput
SIGNING_IDENTITY = "-"
SPM_PACKAGES = --package-path .

build:
	xcodebuild -project $(APP_NAME).xcodeproj -scheme $(APP_NAME) \
		-configuration Release build $(SPM_PACKAGES)

run:
	open -a $(APP_NAME).app

install:
	mkdir -p ~/Library/Application\ Support/$(APP_NAME)
	cp -R $(APP_NAME).app ~/Library/Application\ Support/
	ln -sf ~/Library/Application\ Support/$(APP_NAME)/$(APP_NAME).app \
		~/Library/LaunchAgents/

clean:
	xcodebuild clean
	rm -rf build/
	rm -rf .build/
```

#### CI/CD 流程

为初步 PRD 补充 CI/CD 流程：

```yaml
CI/CD Pipeline:
  on_push:
    - lint: 运行代码规范检查
    - test: 运行单元测试 + 集成测试
    - build: 编译 Release 版本
    - security_scan: 依赖安全扫描
  on_merge:
    - build: Release 构建
    - sign: 代码签名
    - notarize: macOS 公证（如适用）
    - deploy: 部署到分发渠道
```

#### 部署策略

| 平台 | 部署方式 |
|------|---------|
| macOS App | 直接分发 / Homebrew / Mac App Store |
| iOS App | TestFlight / App Store |
| Android | Google Play / 直接分发 APK |
| Web | Vercel / Netlify / Cloudflare Pages |
| CLI | Homebrew / npm global / 二进制下载 |

---

## 冲突检测

### 冲突类型

扩展过程中可能产生以下冲突：

| 冲突类型 | 示例 | 处理方式 |
|---------|------|---------|
| **UI vs 性能** | 动画要求流畅 + 内存限制 < 20MB | 警告：建议降低动画复杂度或放宽内存限制 |
| **第三方 vs 离线** | 使用 Firebase + 要求完全离线 | 警告：Firebase 需要网络，建议改用本地方案 |
| **Accessibility vs 复杂UI** | VoiceOver + 自定义复杂波形 | 警告：需要为波形添加完整的 VoiceOver 描述 |
| **体积 vs 功能** | 包体积 < 10MB + 需要 MLKit | 警告：MLKit 可能超过体积限制，考虑拆分或延迟加载 |
| **电池 vs 实时** | 低功耗 + 实时流式处理 | 警告：实时处理会增加电量消耗 |

### 冲突检测规则

在每个维度扩展完成后，自动运行冲突检测：

1. 收集所有维度扩展结果中的量化参数
2. 检测矛盾：
   - 内存限制 vs 功能需求
   - 体积限制 vs 第三方库
   - 离线要求 vs 网络依赖
   - 无障碍要求 vs 复杂交互
   - 性能要求 vs 架构复杂度
3. 如发现冲突，展示警告：
   ```
   ⚠️ 发现潜在冲突：

   [1] UI 要求动画流畅，但性能要求内存 < 20MB
       — 当前动画方案需要 35MB 内存
       请选择：降低动画复杂度 / 放宽内存限制 / 接受警告继续

   [2] 要求完全离线，但使用了 Firebase
       请选择：替换为本地方案 / 改为部分离线 / 接受警告继续

   输入编号选择，或直接回车接受所有警告继续。
   ```
4. 用户选择后，相应调整扩展结果
5. 继续下一个维度

---

### 维度4: 测试策略扩展

#### 测试金字塔

根据功能类型，推荐测试金字塔：

```yaml
TestPyramid:
  E2E:
    ratio: "10%"
    覆盖场景: "关键用户路径（如录音→识别→注入）"
  Integration:
    ratio: "30%"
    覆盖场景: "模块间交互（如 AudioEngine → SpeechRecognizer）"
  Unit:
    ratio: "60%"
    覆盖场景: "每个模块的核心逻辑"

平台特定测试要求:
  macOS:
    - AudioEngine: "正常录音 / 无麦克风权限 / 音频中断"
    - SpeechRecognizer: "正常识别 / 网络不可用 / 无语音权限"
    - TextInjector: "普通输入框 / CJK输入法 / 无焦点窗口"
    - LLMRefiner: "正常响应 / 超时 / API错误 / 空输入"
    - FloatingWindow: "出现动画 / 消失动画 / 多屏幕适配"
    - InputSourceSwitcher: "检测CJK输入法 / 切换到ASCII / 恢复"
  iOS:
    - "CoreData: 保存/读取/迁移"
    - "AVAudioSession: 权限 / 中断处理"
    - "Speech: 识别准确性 / 离线模式"
  Web:
    - "Speech API: 浏览器支持 / 权限"
    - "Clipboard API: 跨域限制"
    - "Service Worker: 缓存策略"
```

#### 性能测试指标

根据量化参数，补充性能测试要求：

| 测试项 | 目标 | 测试方法 |
|-------|------|---------|
| 启动时间 | < 2s | XCTest / UI Test |
| 响应延迟 | < 500ms | 基准测试 |
| 内存占用 | < 100MB | Instruments / Memory Profiler |
| 包体积 | < 50MB | xcodebuild 输出大小 |
| 电池影响 | < 5%/小时 | Energy Log |

---

### 维度5: 边界条件扩展

#### 边界条件识别矩阵

对于初步 PRD 中的每个功能模块，自动识别以下边界条件：

| 边界类型 | 检测关键词 | 扩展内容 |
|---------|-----------|---------|
| **输入边界** | 用户输入/文字/数据 | 空输入、超长文本（>10万字）、特殊字符、emoji、多语言混合 |
| **时序边界** | 录音/实时/流 | 快速连续操作、长时间运行（>30min）、后台切换、App切换 |
| **资源边界** | 内存/存储/网络 | 内存不足、磁盘满、网络不可用、弱网、流量限制 |
| **并发边界** | 多线程/异步 | 多线程访问同一资源、竞态条件、死锁 |
| **环境边界** | 主题/无障碍 | 深色/浅色模式、Dynamic Type、VoiceOver、低对比度 |
| **安全边界** | 输入/数据 | 输入注入、敏感数据泄露、权限绕过 |

#### 反面案例生成

为初步 PRD 中的每个功能模块，生成"避坑指南"：

```markdown
### 功能: [功能名称]

**不要做:**
- ❌ [具体错误做法] — [原因]
- ❌ [具体错误做法] — [原因]

**应该做:**
- ✅ [正确做法]
- ✅ [正确做法]
```

示例扩展：
- ❌ 不要在主线程执行网络请求 — UI 会卡顿，用户体验差
- ✅ 使用 async/await 或 GCD 在后台线程执行网络请求
- ❌ 不要假设 getUserMedia 总是可用 — Safari 有额外限制
- ✅ 必须进行 Feature Detection，优雅处理不支持的情况

---

### 维度6: 运维支持扩展

#### 日志规范

为初步 PRD 补充统一日志格式：

```yaml
LogFormat:
  pattern: "[TIMESTAMP] [LEVEL] [MODULE] [Message] [Context]"
  示例: "[2026-04-03T10:00:00.000Z] [INFO] [AudioEngine] Recording started"

LogLevels:
  DEBUG:
    环境: "开发"
    内容: "详细流程、变量值、函数调用"
  INFO:
    环境: "生产"
    内容: "关键操作（录音开始/结束、注入成功）"
  WARN:
    环境: "生产"
    内容: "可恢复错误（网络重试）"
  ERROR:
    环境: "生产"
    内容: "不可恢复错误，需要告警"

PlatformLogging:
  macOS: "os.log / NSLog"
  iOS: "os.log"
  Android: "android.util.Log / Timber"
  Web: "console.log / pino"
```

#### 配置管理

| 配置类型 | 推荐方案 |
|---------|---------|
| 运行时配置 | UserDefaults (macOS/iOS) / SharedPreferences (Android) / localStorage (Web) |
| 敏感配置 | Keychain (macOS/iOS) / EncryptedSharedPreferences (Android) |
| 特性开关 | Firebase Remote Config / 自建后端 |
| 国际化 | .strings (Apple) / strings.xml (Android) / i18n (Web) |

#### 升级策略

| 策略 | 适用场景 | 实现方式 |
|------|---------|---------|
| 强制升级 | 安全漏洞修复 | 检测到旧版本禁止使用 |
| 建议升级 | 新功能发布 | 弹窗提示，用户可跳过 |
| 热更新 | 小改动 | Telerik / CodePush / Service Worker |
| 常规升级 | 大版本 | App Store / Google Play / 直接下载 |

#### 数据迁移

对于涉及本地数据存储的功能，补充迁移策略：

```yaml
DataMigration:
  触发条件: "版本号从 X 升级到 Y"
  策略:
    - "向前兼容：新版本能读取旧版本数据"
    - "向后兼容：降级后数据不丢失"
    - "迁移脚本：版本间有差异时运行迁移逻辑"
  示例:
    数据库升级: "CoreData 轻量迁移 / Room 自动迁移"
    配置文件: "JSON Schema 校验 + 默认值填充"
```

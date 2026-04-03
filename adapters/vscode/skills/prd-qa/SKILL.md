---
name: prd-qa
description: "PRD 质检与修复：自动审查 + 修复常见问题 + 质量报告"
version: "1.0.0"
compatibility: "Claude Code"
metadata:
  triggers:
    - prd-qa
    - 审查PRD
    - 检查PRD质量
  author: Claude Code Agent
---

# PRD-QA: PRD 质检与修复

自动审查 PRD 输出，修复常见问题，输出质量报告。

## 技能激活

当用户说以下任意一句时激活本技能：
- "审查 PRD"
- "检查 PRD"
- "检查 PRD 质量"
- "PRD 质量报告"
- "prd-qa"

或者，在方案 A / 方案 B / 方案 C（三个 PRD 生成器）输出之后，自动调用本技能进行质检。

激活后：
1. 接收 PRD 内容（文本或文件路径）
2. 读取 `_shared/` 中的知识库模板
3. 逐项执行 13 维度质检
4. 对可修复问题自动修复并记录
5. 对不可修复问题输出警告 + 建议
6. 生成质量报告
7. 询问用户：保存修复后的 PRD / 预览修改 / 仅查看报告

---

## 质检流程

```
输入: PRD（文本或文件路径）
  │
  ▼
1. 读取 PRD 内容
2. 读取 _shared/ 知识库模板（如有）
3. 执行 13 维度质检
4. 分类处理：
   ├─ 可自动修复 → 执行修复，记录 diff
   └─ 不可修复   → 输出警告 + 修复建议
5. 生成质量报告
6. 询问用户操作偏好
```

---

## 13 项质检维度

### 维度 1: 无占位符扫描

搜索以下占位符标记，标记为**错误**：

| 模式 | 示例 |
|------|------|
| `[TODO]` | 性能要求 [TODO] |
| `[TBD]` | 动画时长 [TBD] |
| `[待定]` | 内存限制 [待定] |
| `[FIXME]` | API 版本 [FIXME] |
| `_____` | （连续下划线超过 5 个） |
| `<具体内容>` | （尖括号包裹的抽象描述） |

**处理方式**: 标记为高危错误，无法自动修复，需用户手动填写具体值。

**本项目示例**（macOS 语音输入 PRD）：
- ✅ 已量化: "Fn 键按下到浮窗出现 < 100ms" — 无占位符
- ✅ 已量化: "单句语音识别延迟 < 500ms" — 无占位符
- ⚠️ 若出现 `[TODO: 补充动画时长]` → 标记为错误

---

### 维度 2: Info.plist / Entitlements 配置检查

检查 PRD 中是否包含以下配置文件描述：

| 平台 | 必需配置文件 |
|------|-------------|
| macOS App | Info.plist + Entitlements（com.apple.security.app-sandbox / com.apple.security.device.audio-input 等） |
| iOS App | Info.plist + Entitlements |
| Android | AndroidManifest.xml |
| Web | manifest.json / service-worker 注册 |

**处理方式**:
- 若 PRD 缺少对应平台配置文件章节，且 `_shared/platform-configs/` 中有对应模板，则**自动注入**模板内容
- 注入后在修复记录中注明

**本项目示例**（macOS 语音输入 PRD）：
- ✅ 已有 "分发方式: 代码签名 + 公证（Notarization）"
- ⚠️ 若缺少 Info.plist 配置（如 LSUIElement、NSMicrophoneUsageDescription），自动注入
- ⚠️ 若缺少 Entitlements（如 com.apple.security.device.audio-input），自动注入

**自动注入模板路径**: `_shared/platform-configs/macos-info-plist-template.md`

---

### 维度 3: API 准确性检查

检查 PRD 中引用的 API 是否与目标平台匹配。

#### 高危错误 — 平台与 API 不匹配

| API 名称 | 适用平台 | 错误场景 |
|---------|---------|---------|
| `CMPedometer` | **iOS 专用** | 出现在 macOS PRD → 标记为高危 |
| `NSEvent.globalMonitorForEvents` | macOS | 不可靠，应用切换时漏事件 |
| `CGEventTap` | macOS | 需配合 Accessibility 权限 |
| `SFSpeechRecognizer` | macOS/iOS | 需麦克风和语音识别权限 |
| `AVAudioEngine` | macOS/iOS | 需配置 Audio Session |
| `UITextField.becomeFirstResponder()` | iOS | macOS 对应 `window.makeFirstResponder()` |
| `AndroidViewModel` | Android | iOS/macOS PRD 中不应出现 |
| `CoreData` | macOS/iOS | Android PRD 中不应出现 |
| `SpeechRecognizer` (Android) | Android | iOS PRD 中不应出现 |
| `webkitSpeechRecognition` | Web | 非 Web 环境不应出现 |

**本项目示例**（macOS 语音输入 PRD）：
- ✅ 使用 `CGEventTap` — macOS 正确
- ✅ 使用 `SFSpeechRecognizer` + `AVAudioEngine` — macOS/iOS 通用，正确
- ✅ 使用 `NSPanel` (nonactivatingPanel) — macOS 正确
- ✅ 使用 `NSStatusItem` — macOS 正确
- ⚠️ 若 PRD 错误地写了 `CMPedometer` 用于计步功能替代方案 → 标记为高危错误，建议改为 "记录 Fn 键按压次数" 或其他 macOS 可用方案

**处理方式**: 无法自动修复（需用户决策替代方案），输出警告 + 建议。

---

### 维度 4: 动画时长矛盾检测

扫描 PRD 中所有动画时长数值，检测同一动画在多处出现不同数值。

**矛盾示例**:
```markdown
- 浮窗出现动画: 300ms
- 浮窗消失动画: 持续 500ms
- 波形动画: 每帧 300ms 更新
- 在另一处: 浮窗动画应持续 500ms  ← 矛盾！
```

**处理方式**: 无法自动修复（需用户确认正确数值），输出警告，格式如下：

```
⚠️ [维度4] 动画时长矛盾
动画名称: 浮窗出现/消失动画
位置A: "300ms"（第 X 行）
位置B: "500ms"（第 Y 行）
建议: 统一为 <your-choice>ms
```

**无矛盾判断标准**: 若同一动画名称只出现一次，或多次出现数值一致，则通过。

---

### 维度 5: 量化参数完整性

检查关键指标是否有具体数值（不得为 "快/慢/适量" 等模糊描述）。

**必须量化的参数类型**:

| 参数类别 | 检查项 |
|---------|--------|
| 性能延迟 | 启动时间、响应延迟、识别延迟 |
| 内存占用 | 空闲时内存、最大内存 |
| CPU 占用 | 空闲时 CPU、高负载 CPU |
| 帧率 | UI 渲染帧率、动画帧率 |
| 网络 | 超时时间、重试次数 |
| 存储 | 包体积、缓存大小 |
| 电池 | 功耗（mW）、每小时耗电百分比 |

**量化标准**:
- ❌ 不合格: "响应快"、"内存占用低"、"帧率高"
- ✅ 合格: "响应延迟 < 100ms"、"内存占用 < 30MB"、"帧率 60fps"

**处理方式**: 无法自动修复（需用户提供具体业务要求），标记为中危问题。

**本项目示例**（macOS 语音输入 PRD）：
- ✅ "Fn 键按下到浮窗出现 < 100ms"
- ✅ "CGEventTap 事件传递延迟 < 10ms"
- ✅ "内存占用 < 30MB"
- ✅ "CPU 占用（空闲时）< 0.1%"
- ✅ "启动录音到首次识别回调 < 300ms"
- ✅ "单句语音识别延迟 < 500ms"

---

### 维度 6: 测试策略完整性

检查 PRD 是否包含测试金字塔、具体测试场景和性能测试指标。

**检查项**:
1. 是否有测试金字塔结构（E2E / 集成 / 单元，比例是否合理）
2. 是否有平台特定测试场景
3. 是否有性能测试指标
4. 是否有错误/边界条件测试

**处理方式**:
- 若缺少测试金字塔章节，且 `_shared/test-templates/` 中有对应模板，则**自动注入**
- 注入后在修复记录中注明

**自动注入模板路径**: `_shared/test-templates/test-pyramid-template.md`

**本项目示例**（macOS 语音输入 PRD）应包含：
```yaml
测试金字塔:
  E2E: 10%  — 关键路径（Fn 录音 → 识别 → 注入）
  集成: 30% — 模块交互（AudioEngine → SpeechRecognizer → TextInjector）
  单元: 60% — 核心逻辑（每个模块独立测试）

平台特定测试:
  macOS:
    - AudioEngine: 正常录音 / 无麦克风权限 / 音频中断
    - SpeechRecognizer: 正常识别 / 网络不可用 / 无语音权限
    - TextInjector: 普通输入框 / CJK 输入法 / 无焦点窗口
    - CGEventTap: 权限被拒 / Fn 键被占用 / 快速连按
```

---

### 维度 7: CI/CD 语法检查

检查 CI/CD 相关描述中的常见笔误。

**检查项**:

| 问题类型 | 错误模式 | 正确写法 |
|---------|---------|---------|
| 双重 `$` 符号 | `$${{ secrets.API_KEY }}` | `${{ secrets.API_KEY }}` |
| YAML 语法 | 缩进不一致、缺少冒号、引号未闭合 | — |
| 布尔值拼写 | `True` / `False`（YAML 应为 `true` / `false`） | `true` / `false` |
| 数组格式 | `- item1\n-item2`（第二项缺缩进） | `- item1\n  - item2` |
| 环境变量 | `${VAR_NAME}` 在字符串中未引号包裹 | `"${VAR_NAME}"` |
| 命令语法 | `xcodebuild -project` 缺少 `-scheme` | `xcodebuild -project X.xcodeproj -scheme X` |

**处理方式**: 可自动修复（修正笔误），在修复记录中注明。

**本项目示例**（macOS 语音输入 PRD）：
- ✅ 使用 XcodeGen + SPM 构建，无 CI/CD YAML 笔误
- ⚠️ 若 CI/CD 流程中出现 `$${{ secrets }}` → 自动修正为 `${{ secrets }}`

---

### 维度 8: 无障碍规范检查

检查 PRD 是否包含以下无障碍规范：

| 规范项 | 适用平台 | 说明 |
|-------|---------|------|
| VoiceOver / NSAccessibility | macOS/iOS | 屏幕阅读器支持 |
| Dynamic Type / NSAttributedString | macOS/iOS | 动态字体支持 |
| prefersHighContrast | macOS/iOS/Web | 高对比度模式 |
| reduceMotion / prefersReducedMotion | macOS/iOS/Web | 减少动画偏好 |
| Keyboard Navigation / focus ring | macOS/iOS/Web | 键盘导航支持 |
| ARIA labels / roles | Web | 无障碍标签 |

**处理方式**: 若缺少无障碍章节，根据平台自动注入推荐规范。

**本项目示例**（macOS 语音输入 PRD）：
- ✅ 已有浮窗的 SF Symbol 图标，可添加 VoiceOver 描述
- ⚠️ 若缺少 prefersReducedMotion 检测 → 建议注入：当用户在系统偏好设置中开启 "减少动画" 时，浮窗出现/消失使用 alpha 渐变而非 scale 动画

---

### 维度 9: 平台一致性检查

检查所有 API 与目标平台的一致性（比维度 3 更广义的检查）。

**检查逻辑**:
1. 从 PRD 中提取所有技术栈关键词（如 "Swift"、"Kotlin"、"React"）
2. 验证是否与目标平台匹配：
   - macOS/iOS PRD 应主要使用 Swift/ObjC + Apple 框架
   - Android PRD 应主要使用 Kotlin/Java + Android SDK
   - Web PRD 应主要使用 JS/TS + Web API

**矛盾示例**:
- macOS PRD 提到 "ActivityManager" → 矛盾（Android API）
- iOS PRD 提到 "WPF" → 矛盾（Windows 框架）
- Web PRD 提到 "UIView.animate" → 矛盾（Apple API）

**处理方式**: 无法自动修复，输出警告。

---

### 维度 10: 边界条件覆盖度

检查 PRD 中边界条件数量是否 >= 10。

**边界条件类型**:

| 类别 | 示例 |
|------|------|
| 输入边界 | 空输入、超长文本（>10万字）、特殊字符、emoji、多语言混合 |
| 时序边界 | 快速连续操作、长时间运行（>30min）、后台切换、App 切换 |
| 资源边界 | 内存不足、磁盘满、网络不可用、弱网、流量限制 |
| 并发边界 | 多线程访问同一资源、竞态条件、死锁 |
| 环境边界 | 深色/浅色模式、Dynamic Type、VoiceOver、低对比度 |
| 安全边界 | 输入注入、敏感数据泄露、权限绕过 |
| 权限边界 | 麦克风被拒、语音识别被拒、Accessibility 被拒、输入法冲突 |

**计数方式**: 统计 PRD 中所有 "边界条件" 小节下的条目总数。

**处理方式**: 若数量 < 10，自动在边界条件章节末尾追加常见边界条件。

**本项目示例**（macOS 语音输入 PRD）：
- ✅ Fn 键被占用 / Accessibility 权限被拒 / 快速连续按放（< 200ms tap）
- ✅ 无麦克风权限 / 无语音识别权限 / 网络不可用（离线识别失败）
- ✅ 普通输入框 / CJK 输入法 / 无焦点窗口
- ✅ 浮窗在多屏幕边缘位置 / 系统深色/浅色模式
- ✅ CGEventTap 注册失败 / 录音中断（电话进入）
- ✅ LLM API 超时 / API 错误 / 空输入
- ✅ NSStatusItem 在不同 macOS 版本兼容性
- ✅ Fn 键与其他修饰键组合（Fn+Shift、Fn+Control）

---

### 维度 11: 自检清单完整性

检查 PRD 是否引用了自检清单。

**检查项**: PRD 中是否包含以下引用或等效内容：
- `../_shared/qa-checks/self-review-checklist.md`
- 或包含 "自检清单" / "Checklist" / "核对表" 章节

**处理方式**:
- 若缺少引用，自动注入自检清单章节
- 注入后在修复记录中注明

**自动注入模板路径**: `_shared/qa-checks/self-review-checklist.md`

---

### 维度 12: 技术栈完整性

检查 PRD 是否覆盖了核心 API（基于平台和功能类型推断）。

**核心 API 覆盖检查矩阵**:

| 功能模块 | macOS 必需 API | iOS 必需 API | Android 必需 API | Web 必需 API |
|---------|--------------|-------------|-----------------|-------------|
| 语音输入 | SFSpeechRecognizer, AVAudioEngine | 同左 | SpeechRecognizer | webkitSpeechRecognition |
| 全局热键 | CGEventTap | — | AccessibilityService | — |
| 菜单栏 | NSStatusItem | — | NotificationChannel | — |
| 浮窗 | NSPanel | UIWindow + UIPresentationController | OverlayView | position: fixed |
| 文本注入 | CGEvent (模拟输入) | UIPasteboard + Share Extension | InputMethodService | document.execCommand |
| 权限管理 | AXIsProcessTrusted | AVAudioSession | Runtime Permissions | getUserMedia API |
| 状态管理 | UserDefaults | UserDefaults | SharedPreferences | localStorage |
| 日志 | os.log | os.log | android.util.Log | console.log / pino |

**处理方式**: 若缺少某核心 API 的描述（即使只是提及），在中危问题中列出缺失项。

---

### 维度 13: 知识库复用检查

检查 PRD 是否引用了 `_shared/` 中的共享资源。

**检查项**: PRD 中是否包含以下引用模式：
- `../_shared/...`
- `_shared/platform-configs/`
- `_shared/test-templates/`
- `_shared/qa-checks/`
- 或显式声明 "引用了共享知识库"

**推荐实践**: 每次扩展维度后，应引用对应的共享模板（如测试金字塔、无障碍规范、平台配置）。

**处理方式**: 若 PRD 是纯新增内容且缺少共享资源引用，可视为 "符合知识库复用规范" 而通过（因为不是所有 PRD 都需要复用）。此维度主要起提醒作用，不产生错误/警告。

---

## 生成前评估模式

### 激活条件

当用户请求生成 PRD **之前**，或 `prd-orchestrator` 在选择方案之前，激活本评估。

### 评估流程

```
1. 接收用户输入（想法描述）
2. 分析输入复杂度
3. 检查知识库覆盖度
4. 预检测冲突
5. 生成评估报告
6. 输出生成建议
```

### 评估维度

#### 1. 输入复杂度分析

| 复杂度 | 特征 | 推荐方案 |
|--------|------|---------|
| L1 简单 | 一句话 + 单功能 + 常见平台 + <100字 | 方案A |
| L2 中等 | 多功能 + 特殊约束 + 100-300字 | 方案A → 方案C |
| L3 复杂 | 创新交互 + 新用户类型 + >300字 | 方案B → 方案A → 方案C |
| L4 专业 | 多平台 + 明确技术栈 + 详细约束 | 方案A（直接用详细知识库）|

#### 2. 知识库覆盖度检查

检查目标平台是否在知识库中有对应规范：

```
可覆盖平台: macOS/iOS/Android/Web/CLI/Chrome Extension
↓
目标平台 in [知识库]?
├── 是 → OK
└── 否 → 警告："[平台]不在知识库中，可能需要手动补充技术细节"
```

#### 3. 约束冲突预检测

检测用户描述中的自相矛盾：

| 冲突类型 | 检测模式 | 警告 |
|---------|---------|---------|
| 离线 + AI服务 | "离线"+"AI"+"LLM"+"网络" | 🔴 冲突：AI服务需要网络，离线AI需本地模型 |
| App Store + CGEventTap | "App Store"+"CGEvent" | 🔴 冲突：CGEventTap需要关闭沙盒，无法上架App Store |
| 小体积 + 复杂功能 | "<10MB"+"AI"+"离线地图" | 🟡 警告：功能复杂度可能超出体积限制 |
| 无障碍 + 炫酷动画 | "VoiceOver"+"复杂波形" | 🟡 警告：复杂动画可能影响VoiceOver体验 |
| 跨平台 + 平台特定API | "跨平台"+"CGEventTap" | 🔴 冲突：CGEventTap仅macOS支持 |

#### 4. 生成建议输出格式

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 PRD 可行性评估报告

输入复杂度: L2 中等
推荐方案: 方案A → 方案C

知识库覆盖:
✅ macOS 平台 — 完整覆盖
✅ 语音输入 — 完整覆盖
⚠️ LLM集成 — 基础覆盖，建议补充具体API

冲突检测:
🔴 发现 1 个冲突：
  [离线] + [AI/LLM] → AI服务需要网络连接
  建议：改为"支持离线基础功能，AI优化需联网"

🟡 发现 1 个警告：
  体积 < 10MB + 功能复杂度 → 可能超出限制
  建议：明确优先级，或放宽体积限制

生成建议:
1. 使用方案A生成初始PRD
2. 自动补充Info.plist/Entitlements模板
3. 使用方案C进行深度扩展
4. 最终通过PRD-QA质检
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 质量报告格式

```markdown
# PRD 质量报告

> 质检时间: [YYYY-MM-DD HH:mm:ss]
> 质检版本: v1.0
> 质检维度: 13 项全检

---

## 综合评分

**[8/10]** — 优秀

评分理由：
- 量化参数完整，所有性能指标均有具体数值
- 技术栈与平台匹配无误
- 边界条件覆盖充分（12 项）
- 缺少 Info.plist 配置章节（已自动注入）
- 缺少测试金字塔章节（已自动注入）

---

## 问题汇总

| # | 严重程度 | 维度 | 问题描述 | 位置 | 状态 |
|---|---------|------|---------|------|------|
| 1 | 🔴 高危 | API准确性 | `CMPedometer` 在 macOS PRD 中不可用 | 第 X 行 | 未修复 |
| 2 | 🟡 中危 | 测试策略 | 缺少测试金字塔 | 第 X 行 | 已注入模板 |
| 3 | 🟡 中危 | Info.plist | 缺少 LSUIElement 配置 | 第 X 行 | 已注入模板 |
| 4 | 🟡 中危 | 量化参数 | 动画时长未量化 | 第 X 行 | 需用户填写 |
| 5 | 🟢 低危 | CI/CD语法 | `$${{ secrets }}` 双重$符号 | 第 X 行 | 已修复 |
| 6 | 🟢 低危 | 自检清单 | 缺少自检清单引用 | 第 X 行 | 已注入 |

---

## 修复记录

### #2: 已注入测试金字塔模板
```diff
+ ## 6. 测试策略
+ > 已由 PRD-QA 自动注入（_shared/test-templates/test-pyramid-template.md）
+ ### 6.1 测试金字塔
+ - E2E: 10% — 关键用户路径
+ - 集成: 30% — 模块交互
+ - 单元: 60% — 核心逻辑
```

### #3: 已注入 Info.plist 配置
```diff
+ ## X. 平台配置
+ > 已由 PRD-QA 自动注入（_shared/platform-configs/macos-info-plist-template.md）
+ ### X.1 Info.plist 必需项
+ - LSUIElement: true（菜单栏应用）
+ - NSMicrophoneUsageDescription: "用于语音输入"
+ - NSSpeechRecognitionUsageDescription: "用于语音识别"
+ ### X.2 Entitlements
+ - com.apple.security.device.audio-input: true
```

### #5: 已修正 CI/CD 语法
```diff
- api_key: $${{ secrets.API_KEY }}
+ api_key: ${{ secrets.API_KEY }}
```

---

## 待用户确认

以下问题无法自动修复，需要您决策：

1. **🔴 [维度3] API 准确性 — CMPedometer 不适用于 macOS**
   - 位置: 第 X 行
   - 当前描述: "使用 CMPedometer 记录 Fn 键按压次数"
   - 建议方案:
     - A. 改为 "使用 UserDefaults 记录 Fn 键按压次数统计"
     - B. 删除该功能描述
     - C. 手动填写替代方案: _______________
   - 请回复 A / B / C

2. **🟡 [维度4] 动画时长矛盾 — 浮窗消失动画**
   - 位置A: 第 X 行（"300ms"）
   - 位置B: 第 Y 行（"500ms"）
   - 请确认正确数值: _______________
```

---

## 质量评分标准

| 评分 | 等级 | 说明 |
|------|------|------|
| 9-10 | 优秀 | 全部 13 维度通过，无占位符，量化完整 |
| 7-8 | 良好 | 少量中危问题，已全部自动修复 |
| 5-6 | 合格 | 有高危问题，需用户决策 |
| 3-4 | 较差 | 多处高危问题，缺少核心章节 |
| 1-2 | 不合格 | 占位符未清理，量化严重不足 |

---

## 输出选项

质检完成后，询问用户：

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 PRD 质检完成！

评分: [X/10] — [等级]
问题数: [N] 个（高危 [X] / 中危 [Y] / 低危 [Z]）
已自动修复: [M] 个

请选择下一步操作：
A. 💾 保存修复后的 PRD 到文件
B. 🔍 预览所有修复的 diff
C. 📋 仅查看质量报告
D. ✏️ 回答上方待确认问题（逐个处理）
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

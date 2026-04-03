# 测试金字塔模板

> 来源: expanded-macos-voice-input-prd.md / ios-accessible-navigation-prd.md
> 用途: 为跨平台应用提供可复用的测试策略模板

---

## 1. 测试分层架构

```
         ┌──────────────────────────────────────────────┐
         │              E2E 测试 (10%)                   │
         │         完整用户流程验证                       │
         │    目标: 验证关键路径完整性                    │
         ├──────────────────────────────────────────────┤
         │           集成测试 (30%)                       │
         │       模块间交互验证                            │
         │    目标: 验证组件协作正确性                    │
         ├──────────────────────────────────────────────┤
         │            单元测试 (60%)                      │
         │         核心逻辑隔离验证                       │
         │    目标: 验证每个函数/类的行为正确性           │
         └──────────────────────────────────────────────┘
```

### 比例说明

| 层级 | 占比 | 数量级 | 执行时间 | 维护成本 |
|------|------|--------|----------|----------|
| 单元测试 | 60% | 数十到数百个 | 秒级 | 低 |
| 集成测试 | 30% | 十余到数十个 | 秒到分钟级 | 中 |
| E2E 测试 | 10% | 数个到十余个 | 分钟级 | 高 |

---

## 2. 各层详细定义

### 2.1 单元测试层 (Unit Tests) — 60%

**测试目标**: 验证每个函数、类、模块的逻辑正确性，完全隔离外部依赖。

**覆盖场景**:

| 场景 | 输入 | 预期输出 | 边界条件 |
|------|------|----------|----------|
| 语音识别结果清理 | "嗯今天天气怎么样啊" | "今天天气怎么样" | 句首/句尾语气词、多余空格 |
| 剪贴板保存/恢复 | 任意字符串 + 注入后 | 原内容恢复 | 空字符串、超长内容 (10KB+) |
| Fn 键按下/释放事件分发 | keyCode=63 按下/释放 | 发出对应 Notification | 快速连续按放 (<200ms 忽略) |
| 位置偏移检测 | 当前位置与路线偏差距离 | 是否偏离 > {{THRESHOLD_METERS}}m | 0m、5m、20m、50m |
| 导航路线解析 | MKRoute 数据 | 提取 steps[], distance, expectedTravelTime | 单步路线、多步路线 |
| 音频 RMS 计算 | AVAudioEngine PCM buffer | RMS 值 (0.0 - 1.0) | 静音、峰值、持续噪声 |
| 输入法类型检测 | TISInputSource 列表 | 是否 CJK 输入法 | 搜狗/百度/系统拼音/注音 |
| 离线模式降级 | 网络状态从 connected 变为 disconnected | 切换到离线数据源 | 短暂抖动、长时间断网 |

**工具推荐**:

- **macOS**: XCTest + OCMock (模拟外部依赖)
- **iOS**: XCTest + OCMock / Cuckoo
- **Android**: JUnit 4/5 + Mockito
- **Web**: Jest / Vitest + Mock Service Worker

**覆盖率目标**: >= 80% (行覆盖率)

---

### 2.2 集成测试层 (Integration Tests) — 30%

**测试目标**: 验证多个模块/组件之间的交互正确性，使用真实依赖或高度可信的 Mock。

**覆盖场景**:

| 场景 | 涉及模块 | 验证点 |
|------|----------|--------|
| Fn 键录音到识别全流程 | CGEventTap → AVAudioEngine → SFSpeechRecognizer | 端到端延迟 < {{TOTAL_LATENCY_MS}}ms |
| 位置更新到语音播报全流程 | CLLocationManager → 路线计算 → AVSpeechSynthesizer | 语音合成延迟 < 200ms |
| 文本注入全流程 (非 CJK) | 识别结果 → NSPasteboard → CGEvent(Cmd+V) → 目标应用 | 文字正确出现在焦点应用 |
| 文本注入全流程 (CJK) | 识别结果 → TISInputSource 切换 → Cmd+V → 恢复输入法 → 恢复剪贴板 | 各步骤正确顺序执行 |
| 离线地图加载流程 | MKMapSnapshotter → 本地存储 → NWPathMonitor 检测断网 → 降级切换 | 离线数据可用时导航不中断 |
| 推送通知到语音播报流程 | APNs → UNUserNotificationCenter → 自定义语音 → AVSpeechSynthesizer | 通知触发语音，< 5s 到达 |

**工具推荐**:

- **macOS**: XCTest (集成测试 target) + 真实系统 API
- **iOS**: XCTest + 真实 CoreLocation/MapKit
- **Android**: Espresso (部分集成) + 真实系统 API
- **Web**: Playwright (E2E 兼用) / Vitest

**覆盖率目标**: >= 50% (跨模块交互路径)

---

### 2.3 E2E 测试层 (End-to-End Tests) — 10%

**测试目标**: 从用户视角验证完整功能路径，确保关键流程端到端可用。

**覆盖场景**:

| 场景 | 步骤 | 验证点 |
|------|------|--------|
| 语音输入完整流程 | 1. 按下 Fn → 2. 说话 → 3. 释放 Fn → 4. 等待识别 → 5. 文字注入目标应用 | 文字出现在目标应用，且与语音内容一致 |
| 导航完整流程 | 1. 语音输入目的地 → 2. 路线规划 → 3. 开始导航 → 4. 语音播报 → 5. 到达提醒 | 全流程语音化，无屏幕依赖 |
| CJK 输入法兼容测试 | 在各 CJK 输入法下 (搜狗/百度/系统拼音/注音) 执行语音输入 | 文字注入到输入法候选框外，直接进入文本框 |
| 离线导航流程 | 1. 预下载离线地图 → 2. 断开网络 → 3. 开始导航 → 4. 语音播报 | 离线模式下核心导航功能可用 |
| 多显示器环境浮窗测试 | 连接外接显示器，在不同屏幕触发 Fn 键 | 浮窗显示在鼠标所在屏幕 |
| VoiceOver 全流程测试 | 在 VoiceOver 开启状态下完成导航流程 | 所有 UI 元素均可朗读，焦点管理正确 |
| 推送通知测试 | 触发到达提醒推送 → 点击通知 → 进入导航详情 | 通知点击响应 < 100ms |

**工具推荐**:

- **macOS**: XCTest (XCUITest) + Accessibility Inspector
- **iOS**: XCUITest + Accessibility Inspector
- **Android**: Espresso + UIAutomator
- **Web**: Playwright + axe-core (无障碍)

**覆盖率目标**: 关键路径 100% 覆盖

---

## 3. 无障碍测试场景模板

> 来源: ios-accessible-navigation-prd.md 无障碍核心规范

### 3.1 VoiceOver / NVDA 兼容性测试

| 检查项 | 方法 | 预期结果 |
|--------|------|----------|
| 所有 UI 元素有 accessibilityLabel | 遍历视图层级，检查 accessibilityLabel 非空 | 0 个缺失项 |
| 地图元素可完整朗读 | 启用 VoiceOver，手指划过地图区域 | 所有 POI 和路线信息被朗读 |
| 焦点自动跟随语音 | 语音播报"前方左转"时 | 屏幕焦点自动移动到相关 UI 元素 |
| 自定义手势响应 | 双击地图中心 | 放大当前路段信息，VoiceOver 确认 |
| 动态内容更新 | 路线更新时 | VoiceOver 自动播报变更内容 |

### 3.2 Dynamic Type / 字体缩放测试

| 检查项 | 方法 | 预期结果 |
|--------|------|----------|
| 文本不溢出 | 设置系统字体为最大 (200%) | 所有文本在视口内，无截断 |
| 列表项高度适配 | Dynamic Type 开启 | 列表项最小高度 44pt，保持可点击 |
| 地图控件缩放 | 字体放大时 | 地图控件触摸目标仍 >= 44×44 pt |

### 3.3 高对比度模式测试

| 检查项 | 方法 | 预期结果 |
|--------|------|----------|
| 对比度达标 | 使用 Accessibility Inspector 检测 | 文字与背景对比度 >= 7:1 |
| 按钮边框清晰 | 开启高对比度模式 | 按钮有明确边框，无透明按钮 |
| 地图高对比度主题 | 导航模式下 | 深色道路线条/浅色背景 |

### 3.4 Haptic Feedback 测试

| 场景 | 预期震动 |
|------|----------|
| 转向提示 | UIImpactFeedbackGenerator (style: .medium) |
| 到达提醒 | UINotificationFeedbackGenerator (type: .success) |
| 路线偏移警告 | UIImpactFeedbackGenerator (style: .heavy) |
| 按钮点击 | UIImpactFeedbackGenerator (style: .light) |

---

## 4. 测试执行策略

### 4.1 CI/CD 集成

```yaml
# GitHub Actions 示例
test:
  runs-on: [macos-latest, ubuntu-latest]
  strategy:
    matrix:
      platform: [macOS, iOS]
  steps:
    - name: 单元测试
      run: xcodebuild test -scheme {{SCHEME}} -destination 'platform={{PLATFORM}}' XCTest_FILTER='*Tests'
    - name: 集成测试
      run: xcodebuild test -scheme {{SCHEME}}-Integration -destination 'platform={{PLATFORM}}'
    - name: 覆盖率报告
      uses: sl留下来的 action/coveralls-action@v1
```

### 4.2 测试数据准备

| 数据类型 | 来源 | 管理方式 |
|----------|------|----------|
| 模拟音频数据 | 预录制 WAV/M4A 文件 | fixtures/ 目录 |
| 模拟位置数据 | GPX 文件 | fixtures/ 目录 |
| 模拟路线数据 | JSON 文件 (MKRoute mock) | fixtures/ 目录 |
| 测试账号 | 独立测试账号 (Firebase) | 环境变量 |

### 4.3 测试环境隔离

- **开发环境**: 本地 Mock Server
- **CI 环境**: GitHub Actions / Xcode Cloud
- **QA 环境**: Firebase Test Lab (iOS/Android 多设备)
- **生产环境**: 真实 API (E2E 测试专用账号)

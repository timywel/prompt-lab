# PRD 自检清单

> 来源: 方案C的13项检查扩展
> 用途: PRD 编写完成后进行自我审查，确保文档完整性和质量

---

## 检查概览

| # | 检查项 | 快速判断 |
|---|--------|----------|
| 1 | 无占位符检查 | 全文无 TODO/TBD/待定/XXX |
| 2 | 量化参数完整性 | 每个功能模块有具体数值指标 |
| 3 | API 真实性检查 | 使用真实系统 API 名称 |
| 4 | 平台一致性检查 | 所有模块与目标平台匹配 |
| 5 | 边界条件覆盖度 | 核心路径的异常情况均已覆盖 |
| 6 | 测试策略完整性 | 单元/集成/E2E 各层有对应测试 |
| 7 | CI/CD 完整性 | 明确构建工具和 CI 流程 |
| 8 | 日志格式统一 | 日志输出格式规范一致 |
| 9 | 配置管理检查 | 配置文件模板完整 |
| 10 | 升级策略检查 | 跨版本升级路径明确 |
| 11 | 数据迁移策略 | 用户数据在版本间安全迁移 |
| 12 | Info.plist / Entitlements | 权限声明完整且准确 |
| 13 | 冲突识别检查 | 功能间潜在冲突已识别 |
| 14 | 技术准确性专项检查 | 特定 API 的平台可用性确认 |

---

## 1. 无占位符检查

**检查方法**: 全局搜索以下关键词，确保均为零匹配。

```
搜索关键词: TODO | TBD | 待定 | XXX | [TODO] | [TBD] | [占位] | PLACEHOLDER | {{PLACEHOLDER}}
```

**判断标准**:
- 0 个匹配项 → 通过
- 有匹配 → 必须全部替换为具体内容后方可提交

**常见遗漏点**:
- 描述中的"XX功能待实现"
- 量化参数中的"XX < XXXms"
- 代码示例中的注释"// TODO: 处理错误情况"

---

## 2. 量化参数完整性检查

**检查方法**: 逐模块检查，每个功能模块应包含以下量化参数：

| 参数类型 | 示例 | 说明 |
|----------|------|------|
| 时间延迟 | "响应时间 < 100ms" | 从输入到输出的时间 |
| 资源占用 | "内存占用 < 30MB" | 峰值和常态值 |
| 性能指标 | "CPU 占用 < 5%" | 各场景下测量 |
| 体积指标 | "离线包 < 50MB" | 包大小或存储占用 |
| 精度指标 | "水平误差 < 5m" | 定位精度等 |
| 比例/比率 | "识别准确率 > 95%" | 质量指标 |

**判断标准**:
- 每个核心功能模块有 >= 3 个量化参数 → 通过
- 少于 3 个 → 补充缺失参数或说明为何不需要

**示例 (来自 PRD)**:
```
Fn 键按下到浮窗出现: < 100ms
CGEventTap 事件传递延迟: < 10ms
内存占用: < 30MB（事件监听模块）
CPU 占用（空闲时）: < 0.1%
```

---

## 3. API 真实性检查

**检查方法**: 验证每个 API 名称为真实存在的系统 API。

| 平台 | API 名称示例 | 真实性来源 |
|------|-------------|-----------|
| macOS | CGEventTap, SFSpeechRecognizer, AVAudioEngine | Apple Developer Documentation |
| macOS | NSPanel, NSVisualEffectView, CADisplayLink | Apple Developer Documentation |
| macOS | TISInputSource, NSPasteboard, NSStatusItem | Apple Developer Documentation |
| iOS | CoreLocation, MapKit, AVSpeechSynthesizer | Apple Developer Documentation |
| iOS | CMPedometer, CoreMotion, UserNotifications | Apple Developer Documentation |
| iOS | CLLocationManager, MKMapView, SFSpeechRecognizer | Apple Developer Documentation |
| Android | FusedLocationProviderClient, AccessibilityService | Android Developer Documentation |
| Web | SpeechRecognition, SpeechSynthesis, Clipboard API | W3C / MDN |

**禁止写法**:
- ❌ "调用某个 API"
- ❌ "使用平台提供的语音识别功能"
- ❌ "通过系统接口获取"

**正确写法**:
- ✅ "使用 `SFSpeechRecognizer` 进行流式语音识别"
- ✅ "通过 `CLLocationManager.startUpdatingLocation()` 获取位置更新"

---

## 4. 平台一致性检查

**检查方法**: 验证 PRD 中声明的平台与所有模块技术实现一致。

| 检查项 | macOS | iOS | Android | Web |
|--------|-------|-----|---------|-----|
| UI 框架一致 | SwiftUI/NSPanel | SwiftUI/UIKit | Jetpack Compose | React/Vue |
| 权限声明一致 | NSMicrophoneUsageDescription | NSLocationWhenInUseUsageDescription | AndroidManifest permissions | Web Permissions API |
| 导航模式一致 | LSUIElement (无 Dock) | UIBackgroundModes | Foreground Service | Service Worker |
| 打包方式一致 | .app + 公证 | .ipa + App Store | .apk +AAB | PWA |

**常见不一致**:
- ❌ iOS PRD 中写了 `LSUIElement` (macOS 专属)
- ❌ macOS PRD 中写了 `UIBackgroundModes` (iOS 专属)
- ❌ Android PRD 中写了 `AVAudioEngine` (Apple 平台)

---

## 5. 边界条件覆盖度检查

**检查方法**: 每个核心功能模块的边界条件应覆盖以下类别：

| 类别 | 示例 |
|------|------|
| 权限相关 | 权限被拒绝、权限撤销、权限部分授予 |
| 网络相关 | 无网络、弱网络、网络切换、网络恢复 |
| 资源相关 | 存储空间不足、内存压力、电量低 |
| 输入相关 | 空输入、超长输入、特殊字符、边界值 |
| 环境相关 | 多显示器、屏幕旋转、深色/浅色模式 |
| 时序相关 | 快速连续操作、超时、并发冲突 |
| 数据相关 | 数据损坏、数据过期、数据不存在 |

**判断标准**:
- 每个核心模块有 >= 3 个边界条件 → 通过
- 边界条件有明确处理方式（非仅"提示用户"）→ 更优

**示例 (来自 PRD)**:
```
- 定位权限被拒绝: 提示用户开启权限，提供引导到设置的链接
- GPS 完全不可用（室内）: 切换到室内辅助定位模式，使用 WiFi 和蓝牙信标
- 位置漂移（卫星信号反射）: 使用 Kalman 滤波平滑位置数据
```

---

## 6. 测试策略完整性检查

**检查方法**: 验证每个功能模块在测试金字塔中有对应的测试覆盖。

| 测试类型 | 占比 | 覆盖要求 |
|----------|------|----------|
| 单元测试 | 60% | 核心算法、数据转换、状态管理 |
| 集成测试 | 30% | 模块间交互、API 调用 |
| E2E 测试 | 10% | 关键用户路径 |

**必须覆盖的测试场景**:
- 核心功能的 Happy Path
- 各边界条件
- 无障碍功能 (VoiceOver/Dynamic Type/高对比度)
- 性能关键路径 (延迟、内存、CPU)

**判断标准**:
- 有明确的测试分层策略 → 通过
- 有覆盖率目标 (如 >= 80%) → 更优
- 有 CI/CD 集成 → 更优

---

## 7. CI/CD 完整性检查

**检查项**:

| 阶段 | 检查内容 |
|------|----------|
| 构建 | 明确构建工具 (XcodeGen / Gradle / npm 等) |
| 依赖管理 | 明确依赖管理器 (SPM / CocoaPods / Gradle / npm) |
| 签名/打包 | 明确签名方式 (Developer ID / App Store / 自签名) |
| 公证/审核 | 明确分发方式 (App Store / TestFlight / 直接分发) |
| 测试自动化 | CI 中包含单元测试和集成测试 |
| Lint | 代码规范检查 (SwiftLint / ESLint 等) |
| 覆盖率 | 持续追踪测试覆盖率 |

**示例 (来自 PRD)**:
```yaml
# XcodeGen + SPM + GitHub Actions
构建: xcodegen generate && swift build
测试: xcodebuild test -scheme VoiceInput
签名: codesign --sign "Developer ID Application: ..."
公证: xcrun notarytool submit VoiceInput.zip
```

---

## 8. 日志格式统一检查

**检查方法**: 验证 PRD 中提及的日志输出格式一致。

| 检查项 | 要求 |
|--------|------|
| 日志级别 | 明确 ERROR / WARN / INFO / DEBUG 各级别使用场景 |
| 日志格式 | 统一模板，如 `[Timestamp] [Level] [Module] Message` |
| 敏感信息 | 明确哪些字段需要打码 (位置数据、用户输入等) |
| 脱敏规则 | 坐标模糊化、API Key 打码、用户 ID 脱敏 |

**禁止**:
- ❌ 在日志中打印明文密码、Token
- ❌ 在日志中打印精确位置历史
- ❌ 使用不一致的日志格式

---

## 9. 配置管理检查

**检查项**:

| 文件 | 检查内容 |
|------|----------|
| Info.plist | 所有 Privacy Usage Description 填写完整 |
| Entitlements | 所有必需权限声明完整 |
| 平台特定配置 | 如无摄像头则无 NSCameraUsageDescription |
| 权限说明文本 | 清晰描述用途，不能仅写"需要此权限" |

**来源参考**:
- macOS: `.claude/skills/_shared/platform-configs/macos-infoplist.yaml`
- iOS: `.claude/skills/_shared/platform-configs/ios-infoplist.yaml`

---

## 10. 升级策略检查

**检查项**:

| 场景 | 检查内容 |
|------|----------|
| 小版本升级 (x.y.z → x.y.z+1) | 向前兼容，数据格式不变 |
| 大版本升级 (x.y.z → x+1.0.0) | 数据迁移脚本，版本兼容性声明 |
| 降级兼容性 | 明确降级是否支持 |
| 跨平台数据 | 多端数据同步策略 |

---

## 11. 数据迁移策略检查

**检查项**:

| 数据类型 | 迁移方式 |
|----------|----------|
| 用户偏好设置 | JSON 配置文件版本化，迁移脚本 |
| 离线缓存数据 | 自动过期机制 + 清理脚本 |
| 历史导航记录 | 用户可导出/导入，数据脱敏 |
| 登录凭证 | Keychain/安全存储自动迁移 |

---

## 12. Info.plist / Entitlements 配置检查

**针对 macOS**:

| 配置项 | 要求 |
|--------|------|
| LSUIElement | 仅当应用为菜单栏/系统托盘应用时设为 YES |
| App Sandbox | CGEventTap 应用必须设为 NO |
| Hardened Runtime | 必须开启 (YES) |
| NSMicrophoneUsageDescription | 必须填写清晰描述 |
| NSSpeechRecognitionUsageDescription | 必须填写清晰描述 |
| Accessibility | 通过 AXIsProcessTrusted() 运行时请求，不在 Info.plist 中 |

**针对 iOS**:

| 配置项 | 要求 |
|--------|------|
| UIBackgroundModes | 必须包含 location (后台导航) 和 remote-notification (推送) |
| NSLocationWhenInUseUsageDescription | 必须填写 |
| NSLocationAlwaysAndWhenInUseUsageDescription | 必须填写 (后台定位) |
| NSSpeechRecognitionUsageDescription | 必须填写 (语音识别) |
| NSMicrophoneUsageDescription | 如使用麦克风则必须填写 |
| NSMotionUsageDescription | 如使用 CMPedometer 则必须填写 |
| NSCameraUsageDescription | 无摄像头功能则不填写 |

---

## 13. 冲突识别检查

**检查方法**: 识别功能间、API 间、平台间的潜在冲突。

| 冲突类型 | 示例 | 处理方式 |
|----------|------|----------|
| 功能冲突 | CGEventTap + App Sandbox | App Sandbox 必须关闭 |
| API 冲突 | AVAudioSession 音频会话管理 | 录音时切换到独立通道 |
| 权限冲突 | 后台定位 + 用户撤销权限 | 优雅降级到前台模式 |
| 场景冲突 | CJK 输入法 + 直接粘贴 | 切换输入法后再粘贴 |
| 资源冲突 | 后台 Service + 系统省电 | 使用 Foreground Service + 通知 |
| 数据冲突 | 多端离线修改同步 | 冲突解决策略 (最后写入/合并) |

---

## 14. 技术准确性专项检查

### 14.1 CMPedometer iOS 可用性

| 检查项 | 说明 |
|--------|------|
| 最低版本 | CMPedometer 仅 iOS 8+ 支持 |
| 隐私 | 需要 NSMotionUsageDescription |
| 准确性 | 依赖 M7/M9 协处理器 |
| 降级 | iOS 8 以下设备必须优雅降级，不能崩溃 |

**PRD 正确写法**:
```
结合 CoreMotion 的步态检测（CMPedometer）提升室内定位精度
边界条件: iOS 8 以下设备使用 Kalman 滤波替代
```

### 14.2 CGEventTap 与 App Sandbox

| 检查项 | 说明 |
|--------|------|
| 不兼容性 | CGEventTap 需要 Accessibility 权限，与 App Sandbox 互斥 |
| 解决方案 | App Sandbox 必须关闭 (NO) |
| 备选方案 | NSEvent.addGlobalMonitorForEvents (可靠性较低) |

### 14.3 SFSpeechRecognizer 离线识别

| 检查项 | 说明 |
|--------|------|
| 离线可用性 | macOS 12+ / iOS 13+ 支持离线中文识别 |
| 网络降级 | `requiresOnDeviceRecognition = false` 时检测网络可用性 |
| 降级策略 | 网络不可用时使用离线模式，若离线不可用则提示用户 |

### 14.4 UIBackgroundModes 必须在 Entitlements 和 Info.plist 中同时声明

| 检查项 | 说明 |
|--------|------|
| Info.plist | 必须声明 UIBackgroundModes 数组 |
| Entitlements | aps-environment 用于推送 |
| location 模式 | 必须配合 NSLocationAlwaysAndWhenInUseUsageDescription |
| 强制终止 | 未声明后台模式时系统会强制终止应用 |

### 14.5 APNs 推送环境区分

| 检查项 | 说明 |
|--------|------|
| 开发环境 | aps-environment = development |
| 生产环境 | aps-environment = production |
| 提审前 | 必须改为 production |
| 测试 | TestFlight 使用 development 和 production 均可 |

---

## 检查执行流程

```
1. [ ] 运行占位符搜索 (grep TODO/TBD/待定)
2. [ ] 逐模块检查量化参数完整性
3. [ ] 逐 API 验证真实性
4. [ ] 验证平台一致性
5. [ ] 检查边界条件覆盖度
6. [ ] 确认测试金字塔各层有覆盖
7. [ ] 确认 CI/CD 流程完整
8. [ ] 检查日志格式统一
9. [ ] 验证配置管理完整性
10. [ ] 确认升级和数据迁移策略
11. [ ] 逐项检查 Info.plist / Entitlements
12. [ ] 识别功能间潜在冲突
13. [ ] 执行技术准确性专项检查

总计: 14 项检查
通过标准: 14/14 项全部通过
```

---

## 检查结果记录

| 检查项 | 状态 | 发现的问题 | 修复方式 |
|--------|------|-----------|----------|
| 1. 无占位符 | ✅/❌ | | |
| 2. 量化参数 | ✅/❌ | | |
| 3. API 真实性 | ✅/❌ | | |
| 4. 平台一致性 | ✅/❌ | | |
| 5. 边界条件 | ✅/❌ | | |
| 6. 测试策略 | ✅/❌ | | |
| 7. CI/CD | ✅/❌ | | |
| 8. 日志格式 | ✅/❌ | | |
| 9. 配置管理 | ✅/❌ | | |
| 10. 升级策略 | ✅/❌ | | |
| 11. 数据迁移 | ✅/❌ | | |
| 12. Info.plist/Entitlements | ✅/❌ | | |
| 13. 冲突识别 | ✅/❌ | | |
| 14. 技术准确性 | ✅/❌ | | |

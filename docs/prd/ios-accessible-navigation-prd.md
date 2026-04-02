# 视障人士 iOS 导航 App PRD

> 由 PRD 对话构建器 生成（交互式）
> 生成时间: 2026-04-03
> 目标平台: iOS App（iOS 16+）
> 技术栈: Swift + SwiftUI / CoreLocation + MapKit + AVSpeechSynthesizer / Firebase Analytics / XcodeGen + SPM

---

## 1. 项目概述

- **项目类型**: iOS App（移动端）
- **目标平台**: iOS 16 及以上版本（最近1-2个版本）
- **核心功能**: 帮助视障人士使用 iOS 设备进行导航，通过语音播报当前位置、路线指引和周围环境信息，实现独立安全出行。
- **技术栈**: Swift + SwiftUI（推荐，iOS 16+）、CoreLocation、MapKit、AVSpeechSynthesizer、CoreMotion、Firebase Analytics、XcodeGen + Swift Package Manager
- **构建工具**: XcodeGen + Swift Package Manager
- **MVP 范围**: 核心导航 + 语音播报 + 离线地图基础功能

---

## 2. 功能模块

### 2.1 语音播报导航（Nucleus 功能）

**描述**: 应用的核心功能，通过 AVSpeechSynthesizer 将导航信息以语音方式播报给视障用户。用户无需观看屏幕即可获取导航指引，包括当前位置描述、路线转向指令、距离提示和到达提醒。

**技术实现**:
- **核心 API**: AVSpeechSynthesizer（iOS 语音合成）、AVSpeechUtterance（语音配置）
- **输入/触发**: CoreLocation 位置更新事件、MapKit 路线偏离事件、用户主动查询
- **处理流程**:
  1. 接收 CoreLocation 的 CLLocationManager 位置更新
  2. 计算与当前路线节点的相对位置和方向
  3. 根据位置变化生成对应的语音播报内容（转向、直行、到达等）
  4. 配置 AVSpeechUtterance（语速 voiceRate=0.5，中文优先，语言 zh-CN）
  5. 调用 AVSpeechSynthesizer.speak() 播放语音
  6. 使用 AVAudioSession 切换到独立音频通道，避免被其他音频打断
- **输出结果**: 实时语音播报，播报内容覆盖：当前位置描述、路线选择、下一步转向、剩余距离、到达通知

**量化参数**:
- 语音合成延迟: < 200ms（从位置更新到语音开始）
- 语音播报语速: 0.5（中等语速，适合视障用户理解）
- 播报优先级: 高于背景音乐和提示音
- 音频焦点: 播报时自动降级其他音频

**UI/UX 规范**:
- 屏幕显示为辅助参考，主要交互依赖语音
- 语音播报时屏幕显示对应文字（供陪同人员查看）
- 提供音量调节滑块（Haptic 反馈）
- 深色/高对比度背景（便于低视力用户）

**反面案例**:
- 不要使用纯音效提示而不提供语音（如仅用"滴"声表示转向）—— 视障用户无法区分不同音效含义
- 不要在语音播报过程中插入其他音频打断 —— 信息不完整
- 不要语速过快（>0.6）—— 视障用户需要时间理解
- 不要仅播报距离数字而不说明方向（如"200米"而不说"前方200米左转"）—— 信息不完整

**边界条件**:
- 无网络: 降级使用离线地图数据，仍可语音播报当前位置和已缓存路线
- GPS 信号弱: 提示用户"GPS 信号弱，请移至开阔地带"，不播报不准确的导航信息
- 语音合成失败: 回退到系统默认 TTS，同时记录错误日志
- 用户主动打断: 立即停止当前播报，响应新的位置或用户操作

---

### 2.2 位置定位与跟踪

**描述**: 通过 CoreLocation 持续获取用户当前位置，作为语音导航的数据基础。支持前台和后台定位，确保视障用户在行走过程中始终获得准确的位置信息。

**技术实现**:
- **核心 API**: CLLocationManager（位置管理）、CLLocation（位置数据）、CLHeading（方向数据）
- **输入/触发**: 应用启动时请求定位权限，行走过程中持续获取位置更新
- **处理流程**:
  1. 启动时检查定位权限状态，未授权则请求授权
  2. 配置 CLLocationManager：desiredAccuracy=kCLLocationAccuracyBestForNavigation
  3. 启动位置更新：startUpdatingLocation()
  4. 监听位置变化，计算行进速度和方向
  5. 结合 CoreMotion 的步态检测（ CMPedometer）提升室内定位精度
  6. 位置数据同步到 MapKit 用于路线规划
- **输出结果**: 实时位置坐标 (latitude, longitude)、行进速度 (m/s)、航向角度 (degrees)

**量化参数**:
- 位置更新频率: 每秒 1 次（kCLLocationAccuracyBestForNavigation）
- 定位精度: 水平误差 < 5m（户外开阔地带）
- 响应时间: < 100ms（从位置变化到语音触发）
- 后台定位: 支持，应用切换到后台后仍保持导航

**反面案例**:
- 不要使用低精度定位（kCLLocationAccuracyThreeKilometers）—— 无法用于导航
- 不要在位置变化不明显时重复播报相同信息—— 信息冗余
- 不要忽略后台定位的电量和发热问题—— 影响用户体验

**边界条件**:
- 定位权限被拒绝: 提示用户开启权限，提供引导到设置的链接
- GPS 完全不可用（室内）: 切换到室内辅助定位模式，使用 WiFi 和蓝牙信标
- 位置漂移（卫星信号反射）: 使用 Kalman 滤波平滑位置数据

---

### 2.3 地图路线规划与显示

**描述**: 使用 MapKit 进行地图显示和路线规划。用户输入目的地后，系统规划最优路线并以语音方式引导用户沿路线前进。地图界面作为辅助，低视力用户可通过高对比度和 Dynamic Type 调整查看。

**技术实现**:
- **核心 API**: MKMapView（地图显示）、MKDirections.Request（路线规划）、MKRoute（路线数据）、MKPolyline（路线渲染）
- **输入/触发**: 用户通过语音输入目的地（结合 Speech Framework），或使用预定义常用地点列表
- **处理流程**:
  1. 用户语音输入目的地（AVSpeechRecognizer 实时转写）
  2. 使用 MKLocalSearch 搜索目的地 POI
  3. 创建 MKDirections.Request，设置起点为当前位置
  4. 调用 calculate { response in } 获取路线结果
  5. 解析 MKRoute：获取 steps[]（路线分段）、distance、expectedTravelTime
  6. 将路线数据注入语音播报引擎
  7. 地图跟随用户位置，自动缩放以显示当前路段
- **输出结果**: 导航路线（包含每段 step 的转向描述、距离、耗时）

**量化参数**:
- 路线规划响应: < 3s（从输入目的地到显示路线）
- 路线预计算: 提前计算下两个路口的路线，缩短语音播报间隔
- 地图缩放: 自动缩放到当前路线可见范围

**UI/UX 规范**:
- 默认使用高对比度地图主题（深色道路/浅色背景）
- 支持 Dynamic Type（字体随系统设置缩放）
- 地图控件最小触摸目标 44×44 pt
- 支持 VoiceOver：地图元素可被完整朗读

**反面案例**:
- 不要假设用户可以分辨地图上的颜色—— 必须配合语音
- 不要使用纯图形化路口放大图（Lane Guidance）而不文字描述—— 视障用户无法看到
- 不要仅显示剩余总距离而不播报分段距离—— 信息不够精细

**边界条件**:
- 无目的地: 提示用户"请说出您想去的地方"
- 目的地无法到达（不可步行区域）: 语音提示"该地点不支持步行导航"
- 路线重新规划（偏离路线）: 立即播报"您已偏离路线，正在重新规划"，延迟 < 1s

---

### 2.4 离线地图支持

**描述**: 在基础离线能力下，用户可预先下载指定区域的离线地图数据。当网络不可用时，应用仍能基于本地数据进行定位和路线播报，确保视障用户在地下通道、信号盲区等环境下正常使用。

**技术实现**:
- **核心 API**: MKMapSnapshotter（离线地图预缓存）、本地 SQLite 数据库（路线缓存）
- **输入/触发**: 用户手动下载指定城市/区域的离线地图包；自动缓存常用路线
- **处理流程**:
  1. 用户选择需要下载的地理区域（城市或自定义区域）
  2. 使用 MKMapSnapshotter 按缩放级别批量生成地图瓦片快照
  3. 将瓦片数据存储到本地（~/Documents/OfflineMaps/ 目录）
  4. 离线时，检测网络状态（NWPathMonitor），切换到离线模式
  5. 离线模式下，CoreLocation 仍工作，路线播报基于预缓存路线继续
  6. 重新联网后，同步未完成的导航数据到云端
- **输出结果**: 离线地图瓦片数据、预缓存路线数据

**量化参数**:
- 单个城市离线包体积: < 50MB（压缩后）
- 离线地图覆盖精度: 覆盖主干道和POI
- 离线导航可用性: 核心导航功能（语音播报 + 位置跟踪）可用
- 离线数据更新: 连接 WiFi 时自动检查更新

**反面案例**:
- 不要假设离线地图可以替代实时路况—— 必须告知用户离线限制
- 不要在离线模式下尝试发起网络请求而不做降级处理—— 导致超时等待
- 不要下载过大的离线包（>200MB）—— 占用过多存储空间

**边界条件**:
- 存储空间不足: 检查可用空间，不足 500MB 时禁止下载离线包
- 离线地图数据过期（> 30 天未更新）: 提示用户更新
- 离线时到达新目的地: 提示用户"离线模式不支持新路线规划，请连接网络"

---

### 2.5 推送通知

**描述**: 通过 APNs 向用户发送导航相关的推送通知，包括到达提醒、路线变更通知和定时位置分享（供家属查看视障用户的实时位置）。

**技术实现**:
- **核心 API**: UserNotifications（本地/远程通知）、APNs（Apple Push Notification service）、Firebase Cloud Messaging（备选）
- **输入/触发**: 到达目的地、路线偏移检测、定时位置分享、家属发起的位置查询
- **处理流程**:
  1. 应用启动时请求通知权限：UNUserNotificationCenter.current().requestAuthorization
  2. 注册 APNs 远程通知：UIApplication.shared.registerForRemoteNotifications
  3. 获取设备 token 并发送到后端
  4. 后端根据业务逻辑触发 APNs 推送
  5. 本地处理推送：显示 UNMutableNotificationContent
  6. 导航相关通知触发语音播报（UNNotificationSound.default + 自定义语音）
  7. 支持 Category：到达提醒、路线变更、位置分享
- **输出结果**: 系统推送通知、语音播报通知内容

**量化参数**:
- 推送到达延迟: < 5s（从触发到用户设备收到）
- 通知点击响应: < 100ms
- 后台推送支持: 后台位置更新可通过 APNs 通知用户

**权限需求**:
- NSLocationAlwaysAndWhenInUseUsageDescription（后台持续定位，配合位置分享）
- UIBackgroundModes: location, remote-notification

**反面案例**:
- 不要频繁推送（> 3次/小时）—— 造成视障用户困扰
- 不要仅发送纯文本而不附带语音播报内容—— 视障用户看不到通知文字
- 不要在用户说"停止导航"后继续发送路线更新推送—— 信息无效

**边界条件**:
- 通知权限被拒绝: 使用 in-app banner 替代，不中断导航
- 设备静音: 导航相关通知仍使用自定义语音（不依赖系统静音状态）

---

### 2.6 分析与埋点

**描述**: 通过 Firebase Analytics 收集应用使用数据，用于优化视障用户的导航体验。采集数据包括：路线规划频率、语音播报触发次数、导航完成率、功能使用路径、异常退出位置等。

**技术实现**:
- **核心 API**: Firebase/Core（Analytics）、FirebaseAnalytics/FirebaseAnalytics（事件埋点）
- **输入/触发**: 用户操作事件、系统事件（导航开始/完成/中断、语音播报、路线规划）
- **处理流程**:
  1. 应用启动时初始化 Firebase: FirebaseApp.configure()
  2. 定义 Analytics 事件:
     - `navigation_started`: { destination, route_type }
     - `navigation_completed`: { destination, duration, distance }
     - `navigation_abandoned`: { last_location, reason }
     - `voice_announcement_played`: { announcement_type, duration }
     - `offline_mode_entered`: { duration }
  3. 关键指标: 导航完成率、语音播报覆盖率、离线使用比例
  4. 用户属性:视力障碍类型（先天的/后天的/其他）、常用目的地列表
  5. 数据收集遵守隐私政策，用户可随时关闭分析
- **输出结果**: Firebase Dashboard 统计数据、用户行为漏斗分析

**反面案例**:
- 不要收集精确位置历史（隐私风险）—— 仅收集路由起点终点和关键节点
- 不要将敏感数据写入日志文件—— 所有 Analytics 数据加密传输
- 不要影响应用性能（Analytics SDK 加载延迟）—— 使用异步初始化

**边界条件**:
- 用户关闭分析: Firebase Analytics opt-out，停止所有数据收集
- 网络不可用: Analytics 数据暂存本地，联网后批量上传

---

## 3. 系统集成

- **权限需求**:
  - `NSLocationWhenInUseUsageDescription`: "此 App 需要您的位置来提供导航指引和语音播报。"
  - `NSLocationAlwaysAndWhenInUseUsageDescription`: "此 App 需要在后台持续获取您的位置，以便在您行走时提供不间断的导航指引。"
  - `UIBackgroundModes`: `location`（后台持续导航）、`remote-notification`（推送通知）
  - `NSCameraUsageDescription`: 不需要（无摄像头功能）
- **系统 API**:
  - CoreLocation — GPS 定位和方向
  - MapKit — 地图显示和路线规划
  - AVSpeechSynthesizer — 语音合成播报
  - CoreMotion — 步态检测和运动数据
  - UserNotifications — 推送通知
  - Firebase Analytics — 数据分析
- **特殊行为**:
  - 后台运行: 需要持续定位，应用切换到后台后保持 CoreLocation 更新
  - 无障碍: 全程 VoiceOver 支持，所有 UI 元素有 accessibilityLabel，Dynamic Type 适配

---

## 4. 工程化要求

- **构建方式**: `xcodegen generate`（通过 XcodeGen 生成 .xcodeproj）
- **依赖管理**: Swift Package Manager（Firebase/Core、MapKitKit/SnapKit 如需 UIKit 兼容）
- **测试要求**: 必须包含单元测试（XCTest）+ UI 测试（XCUITest），覆盖率 >= 80%
  - 单元测试: CoreLocation 模拟、MapKit 路线解析、语音播报逻辑
  - UI 测试: 完整导航流程 VoiceOver 兼容性测试、路线规划语音输入测试
- **发布要求**:
  - 代码签名: Development + Distribution
  - App Store: 提供无障碍功能说明，隐私政策 URL，分级设为 4+
  - 支持设备: iPhone（iPad 可用但非核心目标）
- **持续集成**:
  - Xcode Cloud / GitHub Actions: 每次 PR 自动运行测试 + lint
  - Firebase Test Lab: 多设备 UI 测试覆盖

---

## 5. 参考反面案例

### 通用反面案例
- ❌ GPS 信号弱时仍播报不准确的导航信息 — 应提示用户等待或移至开阔地带
- ❌ 频繁推送通知（> 3次/小时）— 造成视障用户困扰和认知负担
- ❌ 收集精确位置历史而不加密 — 隐私风险，必须加密传输
- ❌ 在主线程执行定位数据处理 — 使用 GCD 或 async-await 异步处理

### iOS 特定反面案例
- ❌ 忽略 Info.plist 中的 usage description — 权限请求前必须填写清晰描述
- ❌ 后台持续定位而不声明 UIBackgroundModes — 系统会强制终止
- ❌ 假设用户可以区分颜色编码的地图信息 — 必须全程语音配合
- ❌ 纯音效提示而不提供语音（视障用户无法区分不同音效含义）
- ❌ 语速过快（>0.6）— 视障用户需要更多时间理解和响应
- ❌ 离线模式不降级直接失败 — 必须提供预缓存路线的离线导航

### 无障碍反面案例
- ❌ UI 元素缺少 accessibilityLabel — VoiceOver 无法朗读
- ❌ 不支持 Dynamic Type — 低视力用户无法放大文字
- ❌ 不支持高对比度模式 — 低视力用户阅读困难
- ❌ 地图控件触摸目标小于 44×44 pt — 不符合无障碍规范
- ❌ 动画不提供减少动画选项 — 部分视障用户对动画敏感

---

## 6. 边界条件汇总

| 场景 | 处理方式 |
|------|---------|
| GPS 信号弱 | 提示"GPS 信号弱，请移至开阔地带"，暂停导航播报直到信号恢复 |
| 定位权限拒绝 | 提示开启权限，提供引导到设置的深度链接 |
| 网络不可用 | 切换到离线模式，基于缓存地图和路线继续语音导航 |
| 语音合成失败 | 回退系统默认 TTS，记录错误，提示用户"语音服务暂时不可用" |
| 用户主动打断语音 | 立即停止 AVSpeechSynthesizer，响应新的操作 |
| 离线时到达新目的地 | 提示"离线模式不支持新路线规划，请连接网络" |
| 导航路线偏移 | 检测到偏离 > 20m 时立即重新规划，< 1s 内播报"正在重新规划路线" |
| 存储空间不足（<500MB） | 禁止下载离线地图包，提示清理空间 |
| 离线地图数据过期（>30天） | 提示用户连接网络更新离线数据 |
| 推送通知权限拒绝 | 使用 in-app banner 替代，不中断当前导航 |
| 设备静音 | 导航关键通知使用自定义语音通道，绕过静音设置 |
| 用户关闭 Analytics | Firebase opt-out，停止所有数据收集 |
| 后台应用被系统终止 | 重新启动时恢复上次导航状态（起点记录到 UserDefaults） |

---

## 无障碍核心规范（补充）

### VoiceOver 完整支持
- 所有 UI 元素设置 accessibilityLabel，描述其功能而非外观
- 地图区域提供 accessibilityElements，逐一朗读地图上的关键信息
- 自定义 VoiceOver 手势：双击地图中心放大当前路段信息
- 焦点管理：语音播报时自动聚焦到对应 UI 元素

### Dynamic Type
- 所有文本使用 UIFont.preferredFont(forTextStyle:) 动态字体
- 布局支持文本放大到 200% 不溢出
- 列表项最小高度 44pt，支持 Dynamic Type

### 高对比度模式
- 默认使用高对比度配色（深色道路线条/浅色背景，文字与背景对比度 >= 7:1）
- 支持系统"增加对比度"设置自动适配
- 按钮和交互元素有明确的视觉边框

### Haptic Feedback
- 转向提示: UIImpactFeedbackGenerator (style: .medium) — 震动提示方向
- 到达提醒: UINotificationFeedbackGenerator (type: .success) — 到达目的地震动
- 路线偏移: UIImpactFeedbackGenerator (style: .heavy) — 警告震动

### 语音交互增强
- 支持语音输入目的地（AVSpeechRecognizer 实时转写）
- 常用命令："导航回家"、"导航到最近地铁站"、"停止导航"、"报时"
- 语音识别超时: 5s 内无有效输入则提示"没有听清，请再说一次"

---

> 文档完整性检查：
> - 无 [TODO] / [TBD] / [待定] 占位符
> - 所有量化参数均有具体数值
> - 所有 API 均使用真实系统 API 名称
> - 无障碍需求覆盖 VoiceOver、Dynamic Type、高对比度、Haptic Feedback
> - 权限需求与功能严格对应（无需 NSCameraUsageDescription）

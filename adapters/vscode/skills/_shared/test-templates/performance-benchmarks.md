# 性能基准指标表

> 来源: expanded-macos-voice-input-prd.md / ios-accessible-navigation-prd.md
> 用途: 为跨平台应用提供可量化的性能指标参考，包含目标值和测试方法

---

## 1. 启动时间指标

### 1.1 macOS

| 指标 | 目标值 | 测试方法 | 备注 |
|------|--------|----------|------|
| 冷启动时间 (应用完全可用) | < 2s | `mach_absolute_time()` 从 `main()` 到菜单栏图标出现 | 首次安装后或退出后重启 |
| 热启动时间 (从 Dock 恢复) | < 500ms | 从点击 Dock 图标到浮窗可响应 | 用户点击后快速恢复 |
| 设置面板打开时间 | < 500ms | 从点击菜单栏图标到 Popover 可见 | 参考 PRD 量化参数 |
| CGEventTap 注册时间 | < 100ms | 从 `main()` 到 Fn 键可响应 | 启动期间的事件监听初始化 |

### 1.2 iOS

| 指标 | 目标值 | 测试方法 | 备注 |
|------|--------|----------|------|
| 冷启动时间 (应用完全可用) | < 1.5s | 从点击图标到首屏渲染完成 | 测试设备: iPhone 14 或同等性能 |
| 热启动时间 (从后台恢复) | < 500ms | 从双击 Home 键选择应用到恢复 | iOS 冻结进程恢复 |
| 首屏渲染 (SwiftUI) | < 1s | 从 `body` 渲染完成到 NavigationStack 就绪 | 离线数据预加载不阻塞 |

### 1.3 Android

| 指标 | 目标值 | 测试方法 | 备注 |
|------|--------|----------|------|
| 冷启动时间 (Cold Start) | < 2s | 从点击图标到 First Frame | 包括 Application.onCreate |
| 热启动时间 (Warm Start) | < 500ms | 从 Activity resume 到首帧 | Activity 已创建 |
| 冷启动 (包含 Splash) | < 3s | 从图标到主功能可用 | SplashScreen API |

### 1.4 Web

| 指标 | 目标值 | 测试方法 | 备注 |
|------|--------|----------|------|
| First Contentful Paint (FCP) | < 1.8s | Lighthouse / Performance API | 首次内容绘制 |
| Time to Interactive (TTI) | < 3.8s | Lighthouse / custom measurement | 可交互时间 |
| Largest Contentful Paint (LCP) | < 2.5s | Lighthouse | 最大内容绘制 |
| Total Bundle Size (gzipped) | < 500KB | webpack-bundle-analyzer | 首屏 JS bundle |

---

## 2. 内存占用指标

### 2.1 macOS

| 指标 | 目标值 | 测试方法 | 备注 |
|------|--------|----------|------|
| 空闲时内存占用 | < 50MB | Instruments > Allocations, 静置 30s | 主要为 CGEventTap 监听模块 |
| Fn 键事件监听模块 | < 30MB | Instruments 单独测量该模块 | PRD 量化参数 |
| 录音识别峰值内存 | < 120MB | Instruments 峰值测量 | PRD 量化参数 |
| 浮窗模块内存 | < 10MB | Instruments > Allocations | NSPanel + 波形视图 |
| 内存泄漏检测 | 0 泄漏 | Leaks Instrument, 10 次录音循环 | 无未释放对象 |

### 2.2 iOS

| 指标 | 目标值 | 测试方法 | 备注 |
|------|--------|----------|------|
| 空闲时内存占用 | < 30MB | Xcode Memory Debugger, 静置 | 应用在前台但无操作 |
| 导航时峰值内存 | < 100MB | Instruments > Allocations, 导航中 | 包含 MapKit 地图渲染 |
| 后台定位内存 | < 20MB | Instruments, 后台模式 | CoreLocation 运行 |
| 离线地图包内存加载 | < 50MB | Instruments, 下载并加载离线包 | 单个城市离线包 |
| 低内存警告阈值 | 不触发 | Memory Warning Simulator | 留 20% 余量 |

### 2.3 Android

| 指标 | 目标值 | 测试方法 | 备注 |
|------|--------|----------|------|
| 空闲时内存占用 | < 60MB | Android Profiler, 静置 | 含后台 Service |
| 导航时峰值内存 | < 150MB | Android Profiler, 导航中 | 地图 + 定位 |
| 后台 Service 内存 | < 20MB | Android Profiler, 后台 | Foreground Service |

---

## 3. CPU 占用指标

### 3.1 macOS

| 指标 | 目标值 | 测试方法 | 备注 |
|------|--------|----------|------|
| 空闲时 CPU 占用 | < 0.1% | Instruments > Time Profiler, 静置 10s | PRD 量化参数 |
| Fn 键按下到浮窗出现 | < 100ms | 计时器测量，Fn 按下到通知触发 | PRD 量化参数 |
| 波形动画 CPU | < 5% | Instruments, 录音时 | CADisplayLink 驱动 |
| 语音识别时 CPU | < 15% | Instruments, 录音识别中 | SFSpeechRecognizer |

### 3.2 iOS

| 指标 | 目标值 | 测试方法 | 备注 |
|------|--------|----------|------|
| 空闲时 CPU 占用 | < 1% | Instruments, 前台静置 | 含 CoreLocation 基础监听 |
| 语音合成 CPU | < 10% | Instruments, 语音播报时 | AVSpeechSynthesizer |
| 导航时平均 CPU | < 20% | Instruments, 步行导航中 | 定位 + MapKit + 语音 |
| 后台定位 CPU | < 5% | Instruments, 后台 | CoreLocation 持续更新 |

### 3.3 Android

| 指标 | 目标值 | 测试方法 | 备注 |
|------|--------|----------|------|
| 空闲时 CPU 占用 | < 1% | Android Profiler, 前台静置 | 含后台 Service |
| 导航时平均 CPU | < 25% | Android Profiler, 导航中 | 定位 + 地图 + TTS |

---

## 4. 响应延迟指标

### 4.1 macOS

| 指标 | 目标值 | 测试方法 | 备注 |
|------|--------|----------|------|
| CGEventTap 事件传递延迟 | < 10ms | `mach_absolute_time()` 测量 tap → callback | PRD 量化参数 |
| Fn 键按下到浮窗出现 | < 100ms | 计时测量 | PRD 量化参数 |
| 录音启动到首次识别回调 | < 300ms | 从 AVAudioEngine start 到 SFSpeechRecognizer 首次回调 | PRD 量化参数 |
| 单句语音识别延迟 | < 500ms | 从说话结束到文字出现 | PRD 量化参数 |
| 文本注入延迟 | < 200ms | 从识别完成到文字出现在目标应用 | PRD 量化参数 |
| Cmd+V 模拟总耗时 | < 50ms | 计时测量 keyDown → keyUp → 注入完成 | PRD 量化参数 |

### 4.2 iOS

| 指标 | 目标值 | 测试方法 | 备注 |
|------|--------|----------|------|
| 语音合成延迟 | < 200ms | 从位置更新到语音开始 | PRD 量化参数 |
| 位置更新到语音触发 | < 100ms | CLLocationManager delegate 到 AVSpeechSynthesizer.speak() | PRD 量化参数 |
| 路线规划响应 | < 3s | 从输入目的地到显示路线 | PRD 量化参数 |
| 路线重新规划 | < 1s | 检测到偏离 > 20m 到播报"正在重新规划" | PRD 量化参数 |
| 通知点击响应 | < 100ms | 从点击通知到进入应用详情 | PRD 量化参数 |
| 推送到达延迟 | < 5s | 从触发到设备收到 | PRD 量化参数 |

---

## 5. 包体积指标

### 5.1 各平台目标值

| 平台 | 指标 | 目标值 | 测试方法 | 备注 |
|------|------|--------|----------|------|
| macOS App Bundle | .app 大小 | < 30MB | `du -sh VoiceInput.app` | 纯 Swift，无外部依赖 |
| macOS 分发包 (.zip) | 压缩后大小 | < 15MB | `zip -9 VoiceInput.zip VoiceInput.app` | |
| iOS IPA (App Store) | 压缩后大小 | < 20MB | `xcodebuild -exportArchive` | 不含离线地图 |
| iOS 离线地图包 | 单个城市 | < 50MB | 压缩后测量 | PRD 量化参数 |
| Android APK (release) | 大小 | < 15MB | `./gradlew assembleRelease` | ProGuard 启用 |
| Android + 离线数据 | 总大小 | < 100MB | 安装后 `du` | 含离线地图数据 |
| Web JS Bundle | gzipped | < 500KB | webpack-bundle-analyzer | 首屏必需 |
| Web Total | gzipped | < 1MB | Lighthouse | 包含 Service Worker 缓存 |

---

## 6. 电量影响指标

### 6.1 iOS

| 场景 | 指标 | 测试方法 | 备注 |
|------|------|----------|------|
| 前台导航 30 分钟 | < 10% 电量消耗 | Battery Life 或实测 | 含地图渲染 |
| 后台导航 1 小时 | < 5% 电量消耗 | 实测，对比基准 | 后台定位为主 |
| 连续语音输入 10 分钟 | < 2% 电量消耗 | 实测 | AVAudioEngine + SFSpeechRecognizer |
| 静置 (前台) 10 分钟 | < 1% 电量消耗 | 实测 | 基础监听 |

### 6.2 Android

| 场景 | 指标 | 测试方法 | 备注 |
|------|------|----------|------|
| 前台导航 30 分钟 | < 15% 电量消耗 | Battery Historian | 含地图渲染 |
| 后台导航 1 小时 | < 8% 电量消耗 | Battery Historian | Foreground Service |
| GPS 使用占比 | < 5% 总电量 | Battery Historian | 后台导航 1 小时测量 |

---

## 7. 帧率指标

### 7.1 macOS

| 指标 | 目标值 | 测试方法 | 备注 |
|------|--------|----------|------|
| 波形动画帧率 | 与屏幕刷新率同步 (60Hz/120Hz) | CADisplayLink linkDuration | ProMotion 设备上应达到 120fps |
| 浮窗动画流畅度 | 无掉帧 | Instruments > Core Animation | 淡入淡出期间 |
| 设置面板列表滚动 | >= 60fps | Instruments > Core Animation | SwiftUI List |

### 7.2 iOS

| 指标 | 目标值 | 测试方法 | 备注 |
|------|--------|----------|------|
| 地图滚动帧率 | >= 60fps | Instruments > Core Animation | MapKit 地图滑动 |
| 语音播报时 UI 响应 | 无卡顿 | 手动测试，播报时操作 UI | 主线程不被阻塞 |
| 导航时地图更新 | >= 30fps | Instruments > Core Animation | 位置移动时的地图跟随 |
| 列表滚动帧率 | >= 60fps | Instruments > Core Animation | 目的地列表 |

---

## 8. 网络相关指标

| 指标 | 目标值 | 测试方法 | 备注 |
|------|--------|----------|------|
| API 延迟 (正常网络) | < 200ms | 计时测量 API 请求到响应 | 路线规划 API |
| API 超时阈值 | 10s | 模拟慢网络 | 超时后使用离线数据 |
| 离线检测响应 | < 1s | 断网到切换离线模式 | NWPathMonitor |
| 语音识别离线降级 | < 500ms | 检测到断网到切换离线识别 | SFSpeechRecognizer |
| 推送通知到达 (网络正常) | < 5s | 从服务端发送到设备收到 | PRD 量化参数 |
| 离线数据同步 (重新联网) | < 30s | 检测到联网到完成同步 | 批量上传未完成的导航数据 |
| Firebase Analytics 上传 | 异步，不阻塞主流程 | 实测 | 异步初始化 |

---

## 9. 性能测试工具汇总

| 平台 | 工具 | 用途 |
|------|------|------|
| macOS/iOS | Instruments (Xcode) | Allocations, Leaks, Time Profiler, Core Animation |
| macOS/iOS | XCTest (Measure) | 启动时间等定量测试 |
| iOS | Memory Debugger | 内存泄漏检测 |
| iOS | Battery Life / Energy Log | 电量消耗分析 |
| Android | Android Profiler | CPU, Memory, Network |
| Android | Battery Historian | 电量历史分析 |
| Android | Perfetto | 系统级性能跟踪 |
| Web | Lighthouse | FCP, TTI, LCP, Bundle Size |
| Web | WebPageTest | 详细网络时序 |
| Web | Chrome DevTools Performance | 帧率、内存、CPU |
| Cross-platform | Firebase Test Lab | 多设备自动化测试 |
| Cross-platform | GitHub Actions | CI 中集成性能回归检测 |

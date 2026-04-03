# iOS 性能剖析工具指南

## Instruments 工具套件

### 启动方式
- **菜单**: Xcode → Product → Profile（快捷键 Cmd+I）
- **真机**: Instruments 支持连接 iPhone 直接测试真机性能
- **快捷键**: Cmd+I 在 Xcode 中直接打开 Instruments

### Time Profiler — CPU 热点分析

iOS 上的 Time Profiler 与 macOS 基本一致，但需要注意以下差异：

**真机 vs 模拟器的关键区别:**
- 模拟器上的 CPU 测量反映的是 Mac 硬件能力，不代表真机
- 真机上录制时勾选 "Record wait state information" 可捕获线程等待事件
- 热点函数定位后，优先在真机上复现确认

**iOS 特定采样设置:**
```swift
// 在 iOS 中使用 os_signpost 进行细粒度标记
import os.log

let logger = os.Logger(subsystem: "com.example.app", category: "performance")

func processAudioFrame() {
    let signpostID = OSSignpostID(log: logger, name: "audioProcessing")
    os_signpost(.begin, log: logger, signpostID: signpostID)
    // ... 处理逻辑 ...
    os_signpost(.end, log: logger, signpostID: signpostID)
}
```

**Instruments Points of Interest 模板:**
- 配合 os_signpost 使用，可将自定义标记显示在时间轴上
- 方便在长时间录制中快速定位特定事件

### Allocations 与 Leaks

**iOS 内存管理背景:**
- iOS 使用 ARC（Automatic Reference Counting）管理内存
- 循环引用（strong reference cycle）是内存泄漏的主要原因
- `weak` 和 `unowned` 关键字用于打破强引用环

**iOS 常见泄漏模式:**
```swift
// 典型泄漏 1: 闭包中的 self 强引用
class VideoPlayerViewController: UIViewController {
    private var dataTask: URLSessionDataTask?

    override func viewDidLoad() {
        super.viewDidLoad()
        dataTask = URLSession.shared.dataTask(with: url) { [weak self] data in
            // 正确：使用 [weak self]
            self?.handleData(data)
        }
    }
}

// 典型泄漏 2: Delegate 未设为 weak
protocol DataSourceDelegate: AnyObject { // 使用 AnyObject 强制 class constraint
    func didReceiveData(_ data: Data)
}

// 正确：delegate 应为 weak
class DataSource {
    weak var delegate: DataSourceDelegate?
}

// 典型泄漏 3: NSTimer 强引用
class MyViewController: UIViewController {
    private var timer: Timer? // Timer 强引用 target (self)

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTime()
        }
    }
}
```

** Instruments 中的操作建议:**
1. 使用 Leaks 模板时，选择真机而非模拟器（内存行为差异显著）
2. 在低内存设备（如 iPhone 8）上测试，能更快暴露内存问题
3. 在 Instruments 中模拟内存压力: Debug → Simulate Memory Warning

### Core Animation — 帧率与渲染分析

**iOS 渲染架构简述:**
- UIKit 最终将视图转换为 CALayer 树提交给 Core Animation
- Core Animation 在独立渲染进程中执行绘制
- GPU 负责最终的合成和光栅化

**Core Animation 模板的 iOS 特有视图:**
| 选项 | 说明 |
|------|------|
| Color Blended Layers | 检测透明图层混合开销 |
| Color Hits Green and Red | 缓存命中/未命中的图层 |
| Color Copious Writing | 检测频繁重绘的区域 |
| Slow Animations | 将动画速度降至 10%，便于肉眼观察 |

**UIKit 性能优化策略:**
```swift
// 1. 避免透明度 < 1.0 的视图（触发混合）
view.backgroundColor = UIColor.white // 而非 white.withAlphaComponent(0.99)

// 2. 光栅化复杂视图
layer.shouldRasterize = true
layer.rasterizationScale = UIScreen.main.scale

// 3. 异步绘制
// draw(_ rect:) 中避免耗时操作
// 使用 CATexture 或提前准备离屏位图

// 4. 预排版高度缓存
// UITableView/UICollectionView 的高度计算必须缓存
```

### MetricKit — 生产环境性能数据收集

MetricKit 是 Apple 推荐的线上性能监控方案，可在用户设备上收集性能指标并汇总上报。

**支持的指标类别:**
| 类别 | 包含指标 |
|------|---------|
| Launch | 冷启动时间、热启动时间、total launch duration |
| Memory | 峰值内存、内存增长趋势 |
| CPU | CPU 使用时长分布 |
| Network | 请求次数、耗时分布 |
| Disk | 写入量、读取量 |
| Crash | 崩溃率（非性能但常一起分析）|

**集成配置:**
```swift
// AppDelegate.swift 或 SceneDelegate.swift
import MetricKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions ...) -> Bool {
        MXMetricManager.shared.add(self)
        return true
    }
}

extension AppDelegate: MXMetricManagerSubscriber {
    func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            // 上报到自己的服务器
            uploadMetrics(payload)
        }
    }

    func didReceive(_ payloads: [MXDiagnosticPayload]) {
        for payload in payloads {
            // 上报诊断数据（卡顿、崩溃等）
            uploadDiagnostics(payload)
        }
    }
}
```

**Info.plist 配置:**
```xml
<!-- 启用 MetricKit -->
<key>NSMetricKitUsageDescription</key>
<string>收集性能数据以改进应用体验</string>
```

### 启动性能 — XCTest 测量

```swift
import XCTest

class LaunchPerformanceTests: XCTestCase {
    func testColdLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    func testWarmLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launchArguments = ["--warm-start"]
            XCUIApplication().launch()
        }
    }
}
```

**启动时间分解:**
- **dSYMs**: 符号化启动堆栈，定位耗时模块
- **Time Profiler**: 在启动期间采样，定位初始化热点
- 常见耗时操作: Realm/SQLite 初始化、字体加载、网络请求（应避免）

### watchOS 特别注意事项

watchOS 的性能约束比 iOS 更严格，设备资源极为有限。

**watchOS 能耗特点:**
- 屏幕常亮时 GPU 和背光是主要耗电源
- 后台模式下 CPU 被大幅限制
- 蓝牙通信会显著影响电池

**watchOS 性能优化策略:**
```swift
// 1. 使用 WKApplicationRouter 懒加载路由
// 2. 避免在 didAppear 中执行网络请求
// 3. 使用 GCD 延迟非关键任务
DispatchQueue.global(qos: .utility).async {
    // 耗时处理
}

// 4. 动画使用 SpriteKit 而非 Core Animation（更高效的 GPU 利用）
```

### Instruments 自动化集成

```bash
# 命令行运行 Instruments（无 GUI）
instruments \
    -t "Time Profiler" \
    -w "iPhone 15 Pro" \
    -D ./trace.traceset \
    -l 10000 \
    /path/to/MyApp.app

# 解析 trace 文件提取数据
xcrun traceutil export \
    --input ./trace.traceset \
    --format json \
    --output ./trace.json
```

### Instruments 与真机设备配置

**Profile 测试前的设备准备:**
1. 确保设备未进入低电量模式（设置 → 电池 → 低电量模式关闭）
2. 确保设备未开启 Performance Mode 限制
3. 关闭其他后台应用
4. 使用 Release 配置测试（Debug 配置包含额外调试代码，影响性能）

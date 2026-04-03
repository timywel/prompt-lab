# macOS 性能剖析工具指南

## Instruments 工具套件

### 启动方式
- **菜单**: Xcode → Product → Profile（快捷键 Cmd+I）
- **命令行**: `open -a Instruments`
- 从 Xcode 的 Report Navigator 中选择 "Profile in Instruments"

### Time Profiler — CPU 热点分析

Time Profiler 是定位 CPU 性能问题的首选工具。它以固定间隔（默认 1ms）对所有线程进行采样，统计每个函数被采到的次数，从而推算 CPU 占用比例。

**关键配置:**
- **Sampling Interval**: 默认 1ms，低于 0.5ms 会产生过多开销，不建议调整
- **Thread States**: 启用 "Show Separate Thread States" 可区分运行、空闲、等待状态
- **Invert Call Tree**: 从叶子节点向上显示，方便快速定位热点
- **Hide System Libraries**: 只显示应用代码，快速定位自研模块问题

**典型工作流:**
1. 选择 Time Profiler 模板，点击 Record
2. 执行待测操作（启动、滚动、计算等）
3. 停止录制，使用时间过滤器定位关键时段
4. 在 Call Tree 中展开热点函数，记录占用 > 5% 的函数

```swift
// 使用 os_signpost 标记关键代码段（配合 Instruments 的 Points of Interest 模板）
import os.log

let subsystem = OSLog(subsystem: "com.example.app", category: "performance")
let signpostID = OSSignpostID(log: subsystem, name: "imageProcessing")

os_signpost(.begin, log: subsystem, signpostID: signpostID, "开始图像处理")
// ... 处理逻辑 ...
os_signpost(.end, log: subsystem, signpostID: signpostID, "图像处理完成")
```

**解读指标:**
- **Weight (%)**: 该函数及所有子函数消耗的 CPU 时间占总采样时间的百分比
- **Self Weight (%)**: 仅该函数自身（不含子调用）的 CPU 时间占比
- **Sample Count**: 被采样的次数，值越高说明执行频率越高或单次执行越慢

### Allocations — 内存分配跟踪

Allocations 追踪所有堆对象的分配与释放，是内存优化和泄漏检测的基础工具。

**两种追踪模式:**
- **All Heap Allocations**: 记录所有分配，包括临时对象（会产生大量数据）
- **All VM Allocations**: 仅记录虚拟内存层面的分配（如 mmap、大块内存）

**关键操作:**
- **Generation Snapshots**: 点击 "Mark Generation" 按钮在两个时间点之间创建快照，Instruments 会计算两次快照之间的净分配量
- **Heap Growth**: 关注 "Heap" 列的增长趋势，正常情况下操作完成后堆应回落到基线附近
- **Search & Filter**: 输入类名或分配来源（如 `Malloc`/`NSObject`/`Swift`）快速过滤

**内存泄漏检测工作流:**
1. 录制一段较长时间的操作（5-10 分钟模拟用户使用）
2. 反复执行同一操作多次
3. 观察 Allocations 计数是否持续增长
4. 增长部分通过 Call Tree 定位来源

### Leaks — 内存泄漏检测

Leaks 专门检测无法回收的内存块。在 ARC 环境下，循环引用（强引用环）是内存泄漏的主要原因。

**常见循环引用模式:**
```swift
// 典型循环引用示例
class MyViewController: NSViewController {
    var timer: Timer? // timer 持有 self，self 持有 timer → 泄漏

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateUI() // 正确：使用 [weak self]
        }
    }
}
```

**解读指标:**
- **Leaks**: 无法释放的内存对象数量，应始终为 0
- **Abandoned**: 已释放但引用仍存在的对象（通常无害，但表示设计问题）

### Core Animation — 帧率与掉帧分析

Core Animation 模板是图形性能优化的核心工具。

**显示选项:**
| 选项 | 作用 |
|------|------|
| Color Blended Layers | 用红/绿显示混合层，红色越多开销越大 |
| Color Hits Green | 标记被缓存为位图的图层 |
| Color Misaligned Images | 标记像素不对齐的图像 |
| Color Offscreen-Rendered Yellow | 标记触发离屏渲染的图层 |

**FPS 读数:**
- Instruments 底部状态栏显示实时 FPS
- 正常应保持在 60 FPS（16.67ms/帧）
- FPS 骤降或掉帧用红色标记

**常见优化手段:**
- 减少 CALayer 透明混合层（使用不透明背景）
- 避免圆角 + 阴影的组合（触发离屏渲染）
- 使用 `layer.shouldRasterize` 缓存复杂图层
- 避免在主线程执行图像解码（使用 `vImage` 或后台队列）

### Energy Impact — 能耗分析

Energy Impact 模板以时间轴形式展示 CPU、网络、GPU、 Location、蓝牙等子系统的能耗贡献。

**能耗等级:**
- **Low (绿色)**: 几乎不影响电池续航
- **Medium (黄色)**: 持续使用会有一定影响
- **High (红色)**: 持续高消耗，会明显影响续航

**低功耗模式测试:**
- 在 System Preferences → Battery → Low Power Mode 下测试
- 对比正常模式和低功耗模式下的能耗曲线

### App Nap 检测与处理

App Nap 是 macOS 对后台应用自动降低优先级的机制，可能导致计时器延迟、网络请求放缓、动画卡顿。

**触发条件:**
- 应用窗口全部不可见
- 应用未在前台
- 系统进入低功耗状态

**影响范围:**
- `DispatchSourceTimer` 精度下降（可能延迟数秒）
- `CADisplayLink` 停止触发
- 网络请求被挂起

**防止 App Nap:**
```swift
// 方法 1: 使用 beginActivity
let reason = "保持后台音频播放"
let options: NSProcessInfo.ActivityOptions = [.userInitiated, .idleSystemSleepDisabled]
ProcessInfo.processInfo.beginActivity(options: options, reason: reason)
// ... 执行任务 ...
ProcessInfo.processInfo.endActivity(activity)

// 方法 2: 配置 Info.plist
// 添加 "App Nap is disabled" 到 entitlements
```

### 启动性能优化

**测量方法 — XCTest:**
```swift
import XCTest

class LaunchPerformanceTests: XCTestCase {
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
```

**优化策略 — 框架懒加载:**
```swift
// AppDelegate 中使用 lazy var 延迟初始化非核心模块
class AppDelegate: NSObject, NSApplicationDelegate {
    // 核心模块立即加载
    private let windowManager = WindowManager()

    // 非核心模块延迟加载
    private lazy var analyticsModule = AnalyticsModule()
    private lazy var crashReporter = CrashReporter()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 只做必要的初始化
    }

    func applicationWillBecomeActive(_ notification: Notification) {
        // 在首次需要时才初始化非核心模块
        _ = analyticsModule
    }
}
```

**优化策略 — @main 优化:**
```swift
// 避免在 @main 入口做耗时操作
// 将启动任务分散到后续帧中
@main
struct MyApp {
    static func main() {
        // 只做最小初始化
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate

        // 将次要任务调度到主线程空闲时执行
        DispatchQueue.main.async {
            delegate.initializeSecondaryComponents()
        }

        app.run()
    }
}
```

### 集成到 CI

```bash
# 使用 xcodebuild 配合自定义性能基准测试
xcodebuild test \
    -scheme MyApp \
    -destination 'platform=macOS' \
    -only-testing:PerformanceTests \
    -resultBundlePath build/PerformanceResults.xcresult

# 提取性能指标
xcrun xcresulttool get-metrics \
    --format json \
    --path build/PerformanceResults.xcresult
```

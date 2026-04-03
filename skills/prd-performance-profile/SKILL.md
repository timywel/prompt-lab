---
name: prd-performance-profile
description: "PRD 性能剖析扩展：为 PRD 自动补充性能测试计划、平台性能剖析工具指南、基准指标、回归检测等性能分析章节。自动触发：PRD 涉及实时/音视频/游戏/高性能需求时。"
version: "1.0.0"
compatibility: "Claude Code"
metadata:
  triggers:
    - prd-performance-profile
    - 性能剖析PRD
    - PRD性能
    - 性能分析
    - 性能测试
  author: Claude Code Agent
---

## 技能激活
当 prd-orchestrator 检测到以下关键词时自动激活，或用户明确请求时激活：
- 实时/Real-time/流式
- 音视频/语音/视频播放
- 游戏/Game
- 高性能/Latency-sensitive
- < 100ms / < 1s / < 2s（具体性能指标）
- 启动时间/响应延迟
- Instruments/Profiler/Lighthouse
- 帧率/FPS/GPU

激活后：读取 PRD 内容 → 识别性能关键模块 → 生成性能剖析章节

## 性能剖析流程

### 第一步：识别性能关键路径

扫描 PRD 中对性能敏感的功能，生成性能关键模块矩阵：

| 功能类型 | 性能敏感度 | 关键指标 | 测量方法 |
|---------|-----------|---------|---------|
| 冷启动 | 极高 | TTID（首次输入延迟）| XCTest / Espresso |
| 语音识别 | 极高 | 端到端延迟 < 500ms | 基准测试 |
| 视频播放 | 高 | 帧率 60fps，卡顿 < 2帧/秒 | Instruments |
| 列表滚动 | 高 | FPS 保持 60，掉帧率 < 5% | Instruments |
| 网络请求 | 中 | 首字节时间 TTFB < 200ms | 基准测试 |
| 图像处理 | 中 | 单帧处理 < 16ms | 基准测试 |
| 数据库查询 | 中 | 查询时间 < 50ms | 基准测试 |
| 动画/波形 | 极高 | 帧率 >= 55fps | CADisplayLink 测量 |
| 文件 I/O | 低 | 不阻塞主线程即可 | Instruments |

### 第二步：性能测试计划

根据识别的关键路径，生成完整的性能测试计划：

#### 2.1 启动性能测试

```yaml
启动性能测试:
  冷启动定义: "从点击图标到首帧渲染完成"
  热启动定义: "从后台切换到前台"

  测试场景:
    - 首次安装后启动（冷启动）
    - 应用退出后重启（热启动）
    - 从通知启动
    - 从 URL Scheme 启动

  目标指标:
    | 场景 | 目标 | 警告阈值 | 严重阈值 |
    |------|------|---------|---------|
    | 冷启动 | < 2s | 2-3s | > 3s |
    | 热启动 | < 500ms | 500-800ms | > 800ms |
    | 通知启动 | < 1s | 1-2s | > 2s |

  测试方法:
    macOS/iOS: XCTest 的 `measure(metrics: [XCTApplicationLaunchMetric()])`
    Android: `Android Profiler` 的 `App start up`
    Web: `Lighthouse` 的 `First Contentful Paint` + `Time to Interactive`

  回归基准: "相比上一版本，冷启动增幅不得超过 10%"
```

#### 2.2 响应延迟测试

```yaml
响应延迟测试:
  定义: "用户操作到系统完成响应的时间"

  关键操作延迟目标:
    | 操作 | 目标 | 用户感知 |
    |------|------|---------|
    | 按钮点击反馈 | < 50ms | 即时响应 |
    | 页面切换 | < 300ms | 流畅无感知 |
    | 网络请求（缓存）| < 100ms | 几乎即时 |
    | 网络请求（无缓存）| < 500ms | 可接受等待 |
    | 语音识别结果 | < 500ms | 自然对话节奏 |
    | 视频加载缓冲 | < 1s | 无明显卡顿 |

  测试方法:
    - 每小时自动化测试关键路径
    - 生产环境 RUM（Real User Monitoring）
    - 告警: P95 延迟超过目标 150% 时触发

  回归基准: "P95 延迟增幅不得超过 15%"
```

#### 2.3 内存使用测试

```yaml
内存使用测试:
  测试场景:
    - 空闲状态（无操作）
    - 正常使用（10分钟模拟操作）
    - 峰值场景（大量数据处理）
    - 内存压力（系统低内存警告）

  目标指标:
    | 场景 | 移动端目标 | 桌面端目标 |
    |------|-----------|-----------|
    | 空闲状态 | < 50MB | < 100MB |
    | 正常使用 | < 100MB | < 200MB |
    | 峰值场景 | < 150MB | < 300MB |
    | 内存泄漏 | 增长 < 10MB/小时 | 增长 < 20MB/小时 |

  测试方法:
    macOS/iOS: `Instruments` 的 `Allocations` + `Leaks`
    Android: `Android Profiler` 的 `Memory Profiler`
    Web: `Chrome DevTools` Memory 面板

  回归基准: "峰值内存不得超过上一版本的 120%"
```

#### 2.4 CPU 使用测试

```yaml
CPU使用测试:
  测试场景:
    - 空闲状态（无操作）
    - 录音/播放状态
    - 语音识别处理
    - 复杂动画

  目标指标:
    | 场景 | 移动端 | 桌面端 |
    |------|-------|-------|
    | 空闲状态 | < 1% | < 1% |
    | 录音中 | < 10% | < 5% |
    | 语音识别 | < 30% | < 15% |
    | 复杂动画 | < 20% | < 10% |

  电池影响:
    | 场景 | 每小时消耗 |
    |------|---------|
    | 录音 + 识别 | < 10% |
    | 实时音频处理 | < 15% |
    | 后台录音 | < 5%/小时 |

  测试方法:
    macOS/iOS: `Instruments` 的 `Time Profiler`
    Android: `Android Profiler` 的 `CPU Profiler`
    Web: `Performance` API

  回归基准: "平均 CPU 增幅不得超过 20%"
```

#### 2.5 帧率测试

```yaml
帧率测试:
  适用场景: 动画/波形/视频/游戏

  目标指标:
    | 场景 | 目标帧率 | 掉帧容忍 |
    |------|---------|---------|
    | 标准动画 | 60 FPS | < 5% 掉帧 |
    | 语音波形 | >= 55 FPS | < 2% 掉帧 |
    | 视频播放 | 30/60 FPS | 0 卡顿 |
    | 游戏 | 60 FPS | < 1% 掉帧 |

  测试方法:
    macOS/iOS: `CADisplayLink` 测量实际帧间隔，或 `Instruments` GPU 调试
    Android: `Choreographer` 测量帧率
    Web: `requestAnimationFrame` + `Performance.now()`

  回归基准: "平均帧率不得低于目标 90%"
```

#### 2.6 包体积测试

```yaml
包体积测试:
  目标指标:
    | 平台 | Debug 构建 | Release 构建 | App Store/分发 |
    |------|-----------|------------|----------------|
    | macOS | 无限制 | < 100MB | < 100MB |
    | iOS | 无限制 | < 50MB | < 50MB |
    | Android | 无限制 | < 30MB | < 30MB (APK) |
    | Web | 无限制 | < 500KB (JS) | gzip |

  测试方法:
    macOS/iOS: `xcodebuild -showBuildSettings` 或 `ls -la`
    Android: `du -h app/build/outputs/apk/*.apk`
    Web: `npm run build && ls -lh dist/`

  回归基准: "相比上一版本，体积增幅不得超过 10%"
```

### 第三步：平台性能剖析工具指南

#### macOS/iOS — Instruments

```yaml
Instruments工具指南:
  启动方式: "Xcode → Product → Profile（或 Cmd+I）"

  常用模板:
    | 模板 | 用途 | 关键指标 |
    |------|------|---------|
    | Time Profiler | CPU 热点分析 | 函数占用 % |
    | Allocations | 内存分配跟踪 | 堆大小、泄漏 |
    | Leaks | 内存泄漏检测 | 0 泄漏目标 |
    | Core Animation | 帧率/掉帧分析 | FPS 曲线 |
    | Network | 网络请求耗时 | 请求/响应时间 |

  关键操作:
    - 时间过滤器: 只看指定时间段的性能数据
    - Call Tree: 展开查看调用栈，定位热点函数
    - 标记（Markers）: `os_signpost()` 在代码中埋点

  自动化集成:
    ```bash
    # 使用 metrickit 收集线上性能数据
    # 配置: 项目 → Signing & Capabilities → Background Modes → MetricKit
    ```
```

#### Android — Android Profiler

```yaml
AndroidProfiler指南:
  启动方式: "Android Studio → View → Tool Windows → Profiler"

  常用功能:
    | 功能 | 用途 | 关键指标 |
    |------|------|---------|
    | CPU Profiler | CPU 热点分析 | 方法耗时 |
    | Memory Profiler | 内存分配/泄漏 | 堆大小 |
    | Network Profiler | 网络请求分析 | 请求/响应大小 |
    | Energy Profiler | 电量消耗 | 能量影响 |

  关键操作:
    - 录制: 手动录制性能数据
    - 系统追踪: 低级系统调用分析
    - Heap Dump: 内存快照分析

  自动化集成:
    # 在 CI 中使用 GMD (Gradle Mission Dispatcher)
    # 收集 ANR、启动时间、内存基线
    ```
```

#### Web — Lighthouse / DevTools

```yaml
Web性能工具指南:
  Lighthouse:
    启动: "Chrome DevTools → Lighthouse 面板"
    关键指标:
      | 指标 | 优秀 | 良好 | 需改进 |
      |------|------|------|-------|
      | Performance | 90-100 | 50-89 | 0-49 |
      | First Contentful Paint | < 1.8s | 1.8-3s | > 3s |
      | Largest Contentful Paint | < 2.5s | 2.5-4s | > 4s |
      | Time to Interactive | < 3.8s | 3.8-7.3s | > 7.3s |
      | Cumulative Layout Shift | < 0.1 | 0.1-0.25 | > 0.25 |
      | Total Blocking Time | < 200ms | 200-600ms | > 600ms |

  Chrome DevTools Performance 面板:
    - 录制用户操作
    - 分析火焰图（Flame Chart）
    - 识别长任务（Long Tasks > 50ms）
    - 网络瀑布图分析

  自动化集成:
    # Lighthouse CI 在 CI 中运行
    lhci autorun --collect.url=https://example.com
```

### 第四步：性能回归检测配置

```yaml
性能回归检测:
  CI集成:
    macOS/iOS:
      - 使用 Fastlane 的 `benchmark` 插件
      - 或使用 `xcodebuild test -only-testing` 配合自定义性能基准测试
    Android:
      - 使用 `Gradle Performance Plugin`
      - 或 `Android Benchmark` 库
    Web:
      - 使用 `Lighthouse CI`
      - 或 `WebPageTest`

  基准管理:
    - 基准值存储: 版本号 + 指标名 + 基准值
    - 格式: JSON/YAML 文件提交到仓库
    - 示例:
      ```yaml
      # .performance-baseline.yaml
      v1.2.0:
        cold-start: 1.8s
        hot-start: 320ms
        memory-idle: 45MB
        memory-peak: 95MB
        p95-latency: 420ms
        frame-rate: 58fps
      ```

  告警配置:
    - 增幅 > 10%: 警告（Warning）
    - 增幅 > 20%: 严重（Critical）
    - 增幅 > 50%: 阻断（Block CI）
```

### 第五步：性能优化策略库

根据 PRD 识别的性能瓶颈类型，生成对应的优化策略：

| 瓶颈类型 | macOS | iOS | Android | Web |
|---------|-------|-----|---------|-----|
| 启动慢 | 懒加载框架 + 优化 `@main` | 同左 + 预热 | App Startup Library | Code Splitting |
| 内存泄漏 | Instruments/Leaks | 同左 | LeakCanary | Chrome DevTools |
| 动画掉帧 | CADisplayLink + Metal | 同左 | Choreographer | requestAnimationFrame |
| 网络慢 | URLSession 缓存 | 同左 | OkHttp 缓存 | Service Worker |
| 大图加载 | ImageIO 懒加载 | 同左 | Glide/Coil | IntersectionObserver |
| 数据库慢 | SQLite.swift 索引 | 同左 | Room 索引 | IndexedDB 索引 |
| 布局慢 | 避免 Auto Layout 深度嵌套 | 同左 | 避免过深 View 层级 | CSS Containment |

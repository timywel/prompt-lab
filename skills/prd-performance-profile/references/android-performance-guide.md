# Android 性能剖析工具指南

## Android Profiler

### 启动方式
- **菜单**: View → Tool Windows → Profiler
- **快捷键**: Cmd+Shift+A → 输入 "Profile"
- **独立工具**: 打开 Android Studio 后，点击 Profiler 标签页

Android Profiler 支持连接真机和模拟器，提供实时 CPU、内存、网络、能源的监控。

### CPU Profiler — CPU 热点分析

**录制模式选择:**
| 模式 | 描述 | 适用场景 |
|------|------|---------|
| Sampled | 每帧采样一次，精度 1ms | 长时间录制，通用分析 |
| Instrumented | 在方法入口/出口插入插桩 | 精确调用计数 |
| Ring Buffer | 固定大小循环缓冲区 | 短时精准录制 |

**关键操作:**
1. **选择进程**: 从下拉菜单选择目标应用进程
2. **点击 Record**: 开始录制操作
3. **执行待测操作**: 如启动应用、滑动列表、播放视频
4. **点击 Stop**: 停止录制
5. **分析调用栈**: 在 Flame Chart 或 Top Down 视图中定位热点

**Java/Kotlin 热点定位示例:**
```kotlin
// 在 Kotlin 中使用 Trace API 标记代码段
import android.os.Trace

class AudioProcessor {
    fun processFrame(audioData: ByteArray) {
        Trace.beginSection("processAudioFrame")
        try {
            // ... 处理逻辑 ...
        } finally {
            Trace.endSection()
        }
    }
}
```

**AsyncTrace 监控协程:**
```kotlin
// 使用 Kotlin 协程时，配合 Choreographer 检测帧耗时
class FrameMonitor {
    private val choreographer = Choreographer.getInstance()

    fun startMonitoring() {
        choreographer.postFrameCallback {
            val frameTime = System.nanoTime()
            // 计算帧间隔，判断是否掉帧
            processFrame()
            startMonitoring()
        }
    }
}
```

### Memory Profiler — 内存分析

**实时内存视图:**
- **Java/Kotlin**: 显示应用堆内存的实时使用量
- **Native**: 显示 native 内存分配（不含 Java 堆）
- **Graphics**: OpenGL/Vulkan 纹理和顶点缓冲区内存
- **Stack**: 线程栈内存
- **Code**: DEX 代码、JIT 编译缓存等
- **Other**: 系统分配、mmap 文件等
- **System**: 系统内存使用（不受应用控制）

**捕获 Heap Dump:**
1. 点击 "Dump Java heap" 按钮
2. 等待生成快照（大型应用可能需要数十秒）
3. 在左侧 Instance View 中按包名或类名搜索对象
4. 选择实例，查看 Reference Tree 定位持有者

**内存泄漏检测 — LeakCanary:**
```groovy
// build.gradle (app)
debugImplementation 'com.squareup.leakcanary:leakcanary-android:2.12'
// LeakCanary 2.x 无需额外配置，自动检测 Activity/Fragment/View 泄漏
```

**LeakCanary 自动检测的对象:**
- 已销毁但仍被引用的 Activity
- 已销毁但仍被引用的 Fragment
- 已销毁但仍被引用的 View
- 已回收但仍被引用的对象（监听器、回调等）

**Memory Profiler 中的泄漏识别:**
- 运行一段时间后，堆大小持续增长不回落
- 点击 "Analyze" 让 Android Studio 自动标记泄漏对象
- 使用 "Compare with previous heap dump" 对比两个时刻的快照

### Network Profiler — 网络分析

**功能特点:**
- 按时间轴显示所有网络请求
- 支持 OkHttp、HttpURLConnection、Volley 自动检测
- 显示请求/响应大小、耗时、状态码

**使用步骤:**
1. 点击 "Network" 标签切换到网络视图
2. 点击 Record 开始录制
3. 执行网络操作
4. 点击请求条目查看详细信息（Headers、Response、Stack Trace）

**OkHttp 拦截器集成（用于细粒度监控）:**
```kotlin
class PerformanceInterceptor : Interceptor {
    override fun intercept(chain: Interceptor.Chain): Response {
        val request = chain.request()
        val startTime = System.nanoTime()

        val response = chain.proceed(request)

        val durationMs = (System.nanoTime() - startTime) / 1_000_000.0
        val contentLength = response.body?.contentLength() ?: 0L

        // 上报到性能监控系统
        reportNetworkMetrics(
            url = request.url.toString(),
            method = request.method,
            durationMs = durationMs,
            responseSize = contentLength
        )

        return response
    }
}
```

### Energy Profiler — 能耗分析

Energy Profiler 显示应用对设备电池的影响，包括 Wake Lock、JobScheduler、网络请求等高能耗操作的频率。

**高能耗操作标记:**
- **Wake Lock**: 阻止 CPU 进入休眠，会显著增加耗电
- **JobScheduler**: 批处理任务，调度器会自动合并任务降低能耗
- **Alarm**: 精确闹钟，不当使用会导致频繁唤醒
- **Network**: 网络请求是电池的主要消耗者

**查看 Energy Impact:**
1. 在 Timeline 中找到高 Energy Impact 区域
2. 展开 Call Stack，定位导致高能耗的代码
3. 检查 Wake Lock 是否被正确释放（配对 begin 和 end）
4. 评估 JobScheduler 任务是否可合并

### Systrace — 系统级追踪

Systrace 提供从 Linux kernel 到应用层级的完整追踪，覆盖系统调度、CPU 频率、磁盘 I/O、显示子系统等。

**命令行录制:**
```bash
# 录制 10 秒的 Systrace 数据
python $ANDROID_HOME/platform-tools/systrace/systrace.py \
    --time=10 \
    -o ./trace.html \
    gfx input view webview wm am audio video camera \
    --app=com.example.myapp

# 参数说明:
# gfx: 图形子系统
# input: 输入事件
# view: View 系统
# am: Activity Manager
# audio/video/camera: 多媒体子系统
# --app: 指定应用包名（需要添加 Trace.beginSection()）
```

**在代码中添加追踪点:**
```kotlin
import android.os.Trace

class VideoPlayer {
    fun prepare() {
        Trace.beginSection("VideoPlayer.prepare")
        try {
            // ... 初始化逻辑 ...
        } finally {
            Trace.endSection()
        }
    }
}
```

**Systrace HTML 报告解读:**
- **Alerts**: 黄色三角标记的性能警告（如掉帧、CPU 调度延迟）
- **Frame Rendering**: 垂直列显示每帧的渲染状态
  - 绿色: 正常（< 16ms）
  - 黄色: 轻微延迟（16-33ms）
  - 红色: 严重掉帧（> 33ms）
- **SurfaceFlinger**: 显示帧缓冲区交换周期

### Perfetto — 下一代追踪工具

Perfetto 是 Google 推出的新一代系统追踪工具，功能比 Systrace 更强大，支持 SQL 查询。

**录制方式:**
```bash
# 使用 Perfetto CLI 录制
perfetto \
    -c - \
    --txt \
    -o /tmp/trace.perfetto \
    <<EOF
buffers: {
    size_kb: 8960
    fill_policy: RING_BUFFER
}
data_sources: {
    config {
        name: "linux.ftrace"
        ftrace_config {
            ftrace_events: "sched/sched_switch"
            ftrace_events: "power/cpu_frequency"
            ftrace_events: "power/cpu_idle"
        }
    }
}
data_sources: {
    config {
        name: "android.surfaceflinger.frametimeline"
    }
}
duration_ms: 10000
EOF
```

**SQL 查询示例:**
```sql
-- 查询掉帧事件
SELECT
    dur,
    name
FROM slice
WHERE name LIKE '%frame%'
  AND dur > 16667000  -- 超过 1 帧时间 (ns)
ORDER BY ts;
```

### Startup Optimization — 启动性能

**使用 Android Profiler 测量启动时间:**
1. 在 Profiler 中选择应用进程
2. 点击 "Start recording startup profiling"
3. 启动应用（冷启动）
4. 等待应用首帧渲染完成
5. 停止录制

**App Startup Library — 优化初始化:**
```kotlin
// 1. 创建 Initializer
class DatabaseInitializer : Initializer<Database> {
    override fun create(context: Context): Database {
        return Room.databaseBuilder(
            context.applicationContext,
            AppDatabase::class.java,
            "app-db"
        ).build()
    }

    override fun dependencies(): List<Class<out Initializer<*>>> {
        return emptyList() // 无依赖
    }
}

// 2. 在 AndroidManifest.xml 中注册
// <provider
//     android:name="androidx.startup.InitializationProvider"
//     android:authorities="${applicationId}.androidx-startup"
//     android:exported="false"
//     tools:node="merge">
//     <meta-data
//         android:name="com.example.myapp.DatabaseInitializer"
//         android:value="androidx.startup" />
// </provider>

// 3. 配置依赖链（控制初始化顺序）
// AppInitializer.getInstance(context).initializeComponent(NetworkInitializer::class.java)
```

### 集成到 CI — Gradle + Benchmark

```kotlin
// app/build.gradle.kts
android {
    defaultConfig {
        // 启用基准测试构建类型
        isDefaultBenchmarkTestCompilationEnabled = true
    }
}

// 使用 Macrobenchmark 进行性能测试
@RunWith(AndroidJUnit4::class)
class StartupBenchmark {
    @Rule
    @JvmField
    val benchmarkRule = MacrobenchmarkRule()

    @Test
    fun startup() = benchmarkRule.measureRepeated(
        packageName = "com.example.myapp",
        metrics = listOf(StartupTimingMetric()),
        iterations = 10,
        startupMode = StartupMode.COLD
    ) {
        pressHome()
        startActivityAndWait()
    }
}
```

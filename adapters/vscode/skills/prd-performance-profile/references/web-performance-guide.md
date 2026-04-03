# Web 性能剖析工具指南

## Lighthouse

Lighthouse 是 Google 推出的开源自动化工具，用于衡量网页性能、质量和最佳实践。它集成在 Chrome DevTools、命令行和 CI 管道中。

### 启动方式

| 方式 | 操作 |
|------|------|
| Chrome DevTools | F12 → Lighthouse 面板 → Generate report |
| Chrome 扩展 | Chrome Web Store 安装 "Lighthouse" 扩展 |
| CLI | `npm install -g lighthouse` → `lighthouse <url>` |
| Node API | 在脚本中调用 Lighthouse API |

### CLI 用法

```bash
# 基础用法 — 生成 HTML 报告
lighthouse https://example.com --output html --output-path ./report.html

# 生成 JSON 格式报告（便于程序解析）
lighthouse https://example.com --output json --output-path ./report.json

# 模拟移动设备（Moto G4）
lighthouse https://example.com --preset mobile --output html

# 只运行性能审计
lighthouse https://example.com --only-categories=performance

# 限制带宽和 CPU（模拟 4G）
lighthouse https://example.com --throttling-method=simulate \
    --throttling.rttMs=40 \
    --throttling.downloadThroughputKbps=10240 \
    --throttling.uploadThroughputKbps=10240

# 跳过无障碍审计（加快速度）
lighthouse https://example.com --skip-audits=uses-http2,uses-passive-event-listeners
```

### 核心指标详解

#### Core Web Vitals

**LCP — Largest Contentful Paint（最大内容绘制）**
- 定义: 视口中最大图片或文本块的渲染时间
- 目标: < 2.5s（优秀）/ 2.5s-4s（需改进）/ > 4s（差）
- 常见优化:
  ```html
  <!-- 使用 preload 预加载 LCP 图片 -->
  <link rel="preload" as="image" href="hero-image.webp">
  ```

**FID / INP — First Input Delay / Interaction to Next Paint**
- FID: 首次交互到浏览器响应的时间
- INP: 任意交互到响应的最长延迟（推荐指标，2024 年取代 FID）
- 目标: < 200ms（优秀）/ 200-500ms（需改进）/ > 500ms（差）
- 优化方法:
  ```javascript
  // 将耗时任务拆分，避免阻塞主线程
  function processLargeData() {
    const chunkSize = 1000;
    let offset = 0;

    function processChunk() {
      // 处理当前 chunk
      processBatch(data, offset, chunkSize);

      offset += chunkSize;
      if (offset < data.length) {
        // 让出主线程，下一帧继续
        requestIdleCallback(processChunk, { timeout: 1000 });
      }
    }

    processChunk();
  }
  ```

**CLS — Cumulative Layout Shift（累积布局偏移）**
- 定义: 页面生命周期中所有意外布局偏移的总分
- 目标: < 0.1（优秀）/ 0.1-0.25（需改进）/ > 0.25（差）
- 优化方法:
  ```css
  /* 为图片和视频预留空间 */
  img, video {
    width: 100%;
    height: auto;
    aspect-ratio: 16 / 9; /* 预留空间，防止 CLS */
  }

  /* 为动态内容预留空间 */
  .ad-container {
    min-height: 250px; /* 固定高度，防止广告加载后偏移 */
  }
  ```

#### 其他关键指标

| 指标 | 含义 | 优秀 | 需改进 |
|------|------|------|-------|
| FCP | 首屏内容绘制时间 | < 1.8s | > 3s |
| TTFB | 首字节到达时间 | < 800ms | > 1800ms |
| TBT | 总阻塞时间 | < 200ms | > 600ms |
| SI | 速度指数 | < 3.4s | > 5.8s |

### Lighthouse CI — 集成到 CI

```bash
# 安装 Lighthouse CI
npm install -D @lhci/cli

# 创建配置文件 lighthouserc.json
# {
#   "ci": {
#     "collect": {
#       "url": ["https://staging.example.com/"],
#       "numberOfRuns": 3
#     },
#     "assert": {
#       "assertions": {
#         "categories:performance": ["error", { "minScore": 0.8 }],
#         "first-contentful-paint": ["warn", { "maxNumericValue": 2000 }],
#         "largest-contentful-paint": ["error", { "maxNumericValue": 4000 }],
#         "total-blocking-time": ["error", { "maxNumericValue": 500 }]
#       }
#     }
#   }
# }

# 在 CI 中运行
lhci autorun
```

**GitHub Actions 集成示例:**
```yaml
# .github/workflows/lighthouse.yml
name: Lighthouse CI
on: [push, pull_request]
jobs:
  lighthouse:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: npm ci
      - run: npm install -g @lhci/cli
      - run: lhci autorun
        env:
          LHCI_GITHUB_APP_TOKEN: ${{ secrets.LHCI_GITHUB_APP_TOKEN }}
```

## Chrome DevTools — Performance 面板

Performance 面板提供比 Lighthouse 更细粒度的性能分析，适合深入诊断特定性能问题。

### 录制与分析

**录制操作:**
1. 打开 DevTools（F12）→ Performance 面板
2. 点击圆点录制按钮（或 Ctrl+E）
3. 执行待测操作（页面加载、点击、滚动等）
4. 停止录制

**主要视图:**
| 视图 | 用途 |
|------|------|
| Network | 网络请求时间轴瀑布图 |
| Frames | 每帧的渲染时间，掉帧用红色标记 |
| Main | 主线程调用栈火焰图 |
| Raster | 光栅化线程（绘制操作）|
| GPU | GPU 任务时间轴 |
| Worker | Web Worker 和 Service Worker |

**识别长任务（Long Task）:**
- 执行时间超过 50ms 的任务被标记为 "Long Task"（红色三角警告）
- 长任务会阻塞主线程，导致输入延迟和掉帧
- 在火焰图中寻找 > 50ms 的堆栈片段

**优化长任务:**
```javascript
// 1. 使用 requestIdleCallback 拆分任务
requestIdleCallback(() => {
  heavyComputation();
}, { timeout: 2000 });

// 2. 使用 Web Worker 将计算移出主线程
const worker = new Worker('compute-worker.js');
worker.postMessage({ data: largeArray });
worker.onmessage = (e) => {
  useResult(e.data);
};

// 3. 使用 scheduler.yield() 让出主线程（实验性 API）
async function processInChunks(data) {
  for (let i = 0; i < data.length; i++) {
    processItem(data[i]);
    // 每处理 N 项后让出主线程
    if (i % 100 === 0) {
      await scheduler.yield();
    }
  }
}
```

## 内存分析 — Memory 面板

**内存快照:**
1. Memory 面板 → Heap Snapshot → Take Snapshot
2. 选择配置文件类型（堆快照、分配时间线、分配采样）
3. 分析对象数量和内存占用

**内存泄漏检测:**
- 使用 Allocation Timeline 录制
- 在时间轴中寻找蓝色（未释放）标记
- 从未释放对象向上追溯引用链

```javascript
// 使用 console.memory 查看内存状态（Chrome 特有）
console.memory; // { jsHeapSizeLimit, totalJSHeapSize, usedJSHeapSize }

// 在代码中埋点监控内存
function checkMemory() {
  const used = performance.memory.usedJSHeapSize / 1024 / 1024;
  console.log(`JS Heap: ${used.toFixed(2)} MB`);
  if (used > 50) {
    console.warn('内存使用超过 50MB，请检查是否存在泄漏');
  }
}

// 定期检查
setInterval(checkMemory, 30000);
```

## WebPageTest — 高级性能测试

WebPageTest (webpagetest.org) 提供比 Lighthouse 更详细的性能测试，支持：
- 全球多地点测试
- 真实浏览器（Chrome、Firefox、Safari）
- 薄膜带宽模拟
- 逐帧视频回放
- TCP 层面的性能分析

**API 用法:**
```bash
# 运行测试
curl -s "https://www.webpagetest.org/runtest.php" \
    -d "url=https://example.com" \
    -d "location=Virginia:Chrome.4G" \
    -d "runs=3" \
    -d "f=json" | jq '.data.jsonUrl'

# 获取结果
curl -s "https://www.webpagetest.org/result/<test-id>/"
```

## RUM — 真实用户监控

RUM 在生产环境中持续收集真实用户的性能数据，是 Lighthouse 等实验室工具的必要补充。

**使用 Performance Observer:**
```javascript
// 收集 Core Web Vitals
const observer = new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    console.log(`${entry.name}: ${entry.value}`);

    // 上报到分析服务
    sendToAnalytics({
      metric: entry.name,
      value: entry.value,
      rating: getRating(entry.name, entry.value),
      page: location.pathname,
      timestamp: Date.now()
    });
  }
});

observer.observe({
  types: ['largest-contentful-paint', 'first-input', 'layout-shift', 'navigation'],
  buffered: true
});

function getRating(metric, value) {
  if (metric === 'largest-contentful-paint') {
    return value < 2500 ? 'good' : value < 4000 ? 'needs-improvement' : 'poor';
  }
  if (metric === 'layout-shift') {
    return value < 0.1 ? 'good' : value < 0.25 ? 'needs-improvement' : 'poor';
  }
  // ...
}
```

**使用 web-vitals 库:**
```bash
npm install web-vitals
```
```javascript
import { onLCP, onFID, onCLS } from 'web-vitals';

onLCP((metric) => sendToAnalytics({ name: 'LCP', value: metric.value }));
onFID((metric) => sendToAnalytics({ name: 'FID', value: metric.value }));
onCLS((metric) => sendToAnalytics({ name: 'CLS', value: metric.delta }));
```

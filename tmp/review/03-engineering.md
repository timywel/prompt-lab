# 工程化评审报告

> 评审日期: 2026-04-03
> 评审维度: 构建系统（25%）、依赖管理（25%）、CI/CD 完整性（25%）、部署策略（25%）
> 评分标准: 1-10 分（1=完全缺失，10=行业最佳实践）

---

## 评审维度说明

| 维度 | 权重 | 评审要点 |
|------|------|---------|
| **构建系统** | 25% | 是否有具体构建命令、Makefile、构建脚本、自动化构建入口 |
| **依赖管理** | 25% | 是否明确依赖管理工具、依赖列表、版本锁定策略 |
| **CI/CD 完整性** | 25% | 是否有完整的持续集成/持续部署流程（lint、test、build、scan、release） |
| **部署策略** | 25% | 是否有明确的部署渠道、发布流程、分发策略 |

---

## 各方案详细评分

### 方案 A: macOS 菜单栏语音输入 App PRD（基础版）

**文件**: `/home/timywel/AI_Product/prompt-lab/tmp/prd-outputs/macos-voice-input-prd.md`

#### 构建系统 — 5/10
- 明确了使用 XcodeGen（`xcodegen generate`）生成项目
- 明确了 Swift Package Manager 进行依赖管理
- 提供了打包命令: `xcodebuild -scheme VoiceInput -configuration Release archive`
- **缺失**: 无 Makefile，所有构建命令散落在描述文本中，无标准化构建入口
- **不足**: 未提供 Debug/Release 分离的构建命令对照表

#### 依赖管理 — 6/10
- 明确使用 Swift Package Manager（SPM）
- 明确指出"无外部 C/C++ 依赖"
- 可选包 `swift-openai` 用于 LLM 增强功能
- **缺失**: 无 `Package.swift` 或 `project.yml` 中的依赖声明示例
- **不足**: 依赖声明未具体化（未列出 swift-openai 的版本约束）

#### CI/CD 完整性 — 3/10
- 仅一句话提及: "Xcode Cloud / GitHub Actions: 每次 PR 自动运行测试 + lint"
- **严重缺失**: 无任何 CI/CD 配置文件（.yml/.yaml）
- **不足**: 无 lint 配置、无 test 配置、无 build 配置、无 security scan、无 release 流程

#### 部署策略 — 5/10
- 明确了代码签名方式: Developer ID Application
- 明确了公证（Notarization）流程
- 明确了分发方式: `.zip` 下载分发，绕过 App Store
- **不足**: 无部署渠道表格、无版本发布策略、无多渠道分发规划

**方案 A 综合得分: 4.75 / 10**

| 维度 | 得分 | 权重分 |
|------|------|--------|
| 构建系统 | 5 | 1.25 |
| 依赖管理 | 6 | 1.50 |
| CI/CD 完整性 | 3 | 0.75 |
| 部署策略 | 5 | 1.25 |
| **加权总分** | | **4.75** |

---

### 方案 B: 视障人士 iOS 导航 App PRD

**文件**: `/home/timywel/AI_Product/prompt-lab/tmp/prd-outputs/ios-accessible-navigation-prd.md`

#### 构建系统 — 5/10
- 明确了使用 XcodeGen + Swift Package Manager
- 提及了测试覆盖率目标: >= 80%
- **缺失**: 无具体构建命令表、无 Makefile、无构建脚本
- **不足**: 构建命令散落在各功能模块描述中，没有统一的构建入口文档

#### 依赖管理 — 6/10
- 明确使用 Swift Package Manager
- 依赖列表相对完整: Firebase/Core、FirebaseAnalytics、MapKit、AVSpeechSynthesizer、CoreMotion、CoreLocation、UserNotifications
- **不足**: 无具体版本约束说明、无 Package.swift 示例、依赖声明分散在技术栈描述中

#### CI/CD 完整性 — 3/10
- 同样仅一句话提及: "Xcode Cloud / GitHub Actions: 每次 PR 自动运行测试 + lint"
- Firebase Test Lab 用于多设备 UI 测试覆盖（作为方向性提及）
- **严重缺失**: 无任何 CI/CD 配置文件（.yml/.yaml）
- **不足**: 仅有方向性描述，无具体实现规划，与方案 A 雷同

#### 部署策略 — 4/10
- 明确 App Store 分发
- 代码签名: Development + Distribution
- App Store 需提供无障碍功能说明、隐私政策 URL，App 分级: 4+
- **不足**: 无版本管理策略、无灰度发布（如 TestFlight）描述、无发布操作手册

**方案 B 综合得分: 4.50 / 10**

| 维度 | 得分 | 权重分 |
|------|------|--------|
| 构建系统 | 5 | 1.25 |
| 依赖管理 | 6 | 1.50 |
| CI/CD 完整性 | 3 | 0.75 |
| 部署策略 | 4 | 1.00 |
| **加权总分** | | **4.50** |

---

### 方案 C: macOS 菜单栏语音输入 App PRD（深度扩展版）

**文件**: `/home/timywel/AI_Product/prompt-lab/tmp/prd-outputs/expanded-macos-voice-input-prd.md`

#### 构建系统 — 9/10
- 提供完整的构建命令表格（5 种工具命令）
- 提供完整的 Makefile 模板，包含 13 个 target:
  - `lint`, `test`, `build`, `release`, `run`, `archive`
  - `sign-dev`, `sign-dist`, `notarize`, `dist`
  - `clean`, `install-local`, `install-launchagent`
- 明确变量定义（APP_NAME, BUNDLE_ID, SIGN_ID 等）
- 包含 LaunchAgent plist 生成逻辑
- **不足**: Makefile 为模板形式（SIGN_ID 等占位符需填写），但已非常接近可执行状态

#### 依赖管理 — 7/10
- 明确 Swift Package Manager 作为唯一依赖管理工具
- 明确"无外部 C/C++ 依赖"，完全使用 Apple 系统框架
- 可选依赖 swift-openai 用于 LLM 增强（通过 project.yml 或 Package.swift 集成）
- **不足**: 未提供 `project.yml` 中 SPM 依赖的具体配置片段，依赖声明的工程化落地细节略弱

#### CI/CD 完整性 — 9/10
- 提供完整的 GitHub Actions CI/CD 配置文件（.yaml），包含 5 个 job:
  - `lint`: SwiftLint 代码质量检查
  - `test`: 单元测试 + 集成测试，含代码覆盖率（`-enableCodeCoverage YES`）
  - `build`: Release 构建 + artifact 上传（7 天保留）
  - `security_scan`: Swift 依赖安全审计
  - `release`: 代码签名 + 公证 + Stapler + GitHub Release 创建
- 触发条件覆盖: push（main/develop/feature/**）、pull_request、release
- 包含 `xcrun notarytool` 完整公证流程
- 包含 `xcrun stapler staple` 签名锚定
- 环境变量明确（DEVELOPER_DIR, SWIFT_VERSION）
- **不足**: 缺少 matrix strategy（多 macOS 版本、多 Swift 版本测试），security_scan 较浅（仅 `swift package dump-package`）

#### 部署策略 — 8/10
- 提供多渠道部署策略表格（4 种渠道）:
  1. 直接分发（.zip）: 主要分发方式
  2. Homebrew Cask: 开发者/技术用户，自动更新
  3. Mac App Store: 少数场景（但有 CGEventTap 限制，文档已说明）
  4. LaunchAgent: 开机自启
- 提供完整的公证（Notarization）流程
- 提供版本检查机制（GitHub Releases API）
- 提供数据迁移策略（v1.0 -> v2.0 版本兼容方案）
- **不足**: Homebrew Cask 和 Mac App Store 仅列为选项，无具体接入指南；升级策略中的强制升级实现较为简单

**方案 C 综合得分: 8.25 / 10**

| 维度 | 得分 | 权重分 |
|------|------|--------|
| 构建系统 | 9 | 2.25 |
| 依赖管理 | 7 | 1.75 |
| CI/CD 完整性 | 9 | 2.25 |
| 部署策略 | 8 | 2.00 |
| **加权总分** | | **8.25** |

---

## 对比表格

### 综合得分汇总

| 评审维度 | 权重 | 方案 A (macOS 基础) | 方案 B (iOS 导航) | 方案 C (macOS 扩展) |
|---------|------|:------------------:|:-----------------:|:-------------------:|
| 构建系统 | 25% | 5 | 5 | **9** |
| 依赖管理 | 25% | 6 | 6 | **7** |
| CI/CD 完整性 | 25% | 3 | 3 | **9** |
| 部署策略 | 25% | 5 | 4 | **8** |
| **加权总分** | 100% | **4.75** | **4.50** | **8.25** |
| **排名** | | 第 2 名 | 第 3 名 | **第 1 名** |

### 分项对比

| 分项指标 | 方案 A | 方案 B | 方案 C |
|---------|--------|--------|--------|
| 构建命令具体化 | 有分散命令 | 有分散命令 | 有命令表 + Makefile |
| Makefile | 无 | 无 | 有（13 个 target） |
| 依赖工具声明 | SPM | SPM | SPM |
| 外部依赖清单 | 提及（无） | 提及（Firebase 等） | 提及（无）+ 可选 |
| CI/CD 配置文件 | 无 | 无 | 有（5 jobs） |
| lint 流程 | 提及 | 提及 | 具体配置 |
| test 流程 | 提及 | 提及 | 含覆盖率配置 |
| build 流程 | 提及 | 提及 | 含 artifact |
| security scan | 无 | 无 | 有（浅） |
| release 流程 | 提及 | 提及 | 完整（含 notarize） |
| 部署渠道 | 1 种（.zip） | 1 种（App Store） | 4 种（含 Homebrew） |
| 版本管理 | 无 | 无 | 有（GitHub Releases API） |
| 数据迁移 | 无 | 无 | 有（v1->v2 策略） |

---

## 评审结论

### 方案 C（macOS 语音输入深度扩展版）综合最优

方案 C 在所有四个工程化维度上均显著领先，综合得分 **8.25/10**，比方案 A 和方案 B 高出约 3.5 分。其核心优势在于:

1. **构建系统**: 提供完整的 Makefile 模板（13 个 target），覆盖从开发到发布的全生命周期，比方案 A/B 的零散命令表述强 80%
2. **CI/CD 完整性**: 提供了可直接使用的 GitHub Actions 配置文件（5 个 job、完整触发条件），而方案 A/B 均仅停留在"提及 Xcode Cloud/GitHub Actions"的文字描述层面
3. **部署策略**: 覆盖 4 种分发渠道、完整的公证流程和版本管理策略，而方案 A/B 均仅考虑单一分发方式

### 方案 A 与方案 B 水平相当，两者均存在工程化深度不足的问题

- 方案 A 和方案 B 的综合得分接近（4.75 vs 4.50）
- 两者在 CI/CD 维度上完全雷同（均为一句话提及），均未提供任何 CI/CD 配置文件
- 方案 B 的部署策略得分略低（4 vs 5），因为 iOS App Store 分发流程相对复杂，但文档中对 TestFlight 灰度发布等关键环节未作说明

### 关键差距分析

| 差距点 | 方案 A/B 的不足 | 方案 C 的实现 |
|--------|----------------|---------------|
| 构建入口 | 只有命令，无组织 | Makefile 标准化 |
| CI/CD | 零配置（纯文字描述） | 完整 .yaml（5 jobs） |
| 测试覆盖率 | 提及但无配置 | 含 `-enableCodeCoverage YES` |
| 发布签名 | 仅提命令 | 含 notarize + staple 完整链 |
| 多渠道分发 | 单渠道 | 4 渠道策略 |
| 运维支持 | 无 | 含日志规范 + 版本迁移 |

### 改进建议

**对方案 A/B**:
1. 至少应提供 CI/CD 配置文件的草案（哪怕是简化版）
2. 应补充 Makefile 或构建脚本作为标准构建入口
3. CI/CD 部分应从"提及"升级为"具体规划"

**对方案 C**:
1. 可增加 matrix strategy 支持多 macOS 版本并行测试
2. security_scan job 建议引入 `snyk` 或 `owasp-dependency-check` 等专业安全扫描工具
3. Homebrew Cask 和 Mac App Store 渠道建议补充具体的接入配置片段

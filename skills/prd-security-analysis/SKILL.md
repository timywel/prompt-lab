---
name: prd-security-analysis
description: "PRD 安全分析扩展：为 PRD 自动补充威胁建模、隐私合规、数据加密、API 鉴权、安全测试等安全章节。自动触发：PRD 涉及登录/支付/用户数据/加密等功能时。"
version: "1.0.0"
compatibility: "Claude Code"
metadata:
  triggers:
    - prd-security-analysis
    - 安全分析PRD
    - PRD安全
    - 安全审查
    - 隐私合规
  author: timywel
---

# PRD 安全分析扩展技能

## 技能激活

当 prd-orchestrator 检测到以下关键词时自动激活，或用户明确请求时激活：

- 登录/注册/认证/鉴权
- 支付/内购/购买
- 用户数据/个人信息/隐私
- 加密/解密/密钥
- API/后端/服务端
- 传输/网络/HTTPS

激活后：读取 PRD 内容 -> 识别涉及安全的模块 -> 生成对应安全章节

### 与 prd-orchestrator 的集成

prd-security-analysis 作为扩展技能，在 PRD 生成流程中可被以下方式调用：

| 触发方式 | 调用时机 | 说明 |
|---------|---------|------|
| prd-orchestrator 自动检测 | PRD 包含安全敏感关键词时 | 协调层在方案完成后自动追加安全章节 |
| 用户明确请求 | 用户说"安全分析这个PRD" | 作为独立扩展运行 |
| 动态增强注入 | prd-orchestrator 的动态增强阶段 | 自动检查并注入缺失的安全内容 |

**集成位置**：在 prd-orchestrator 的动态增强规则中，当检测到安全相关功能时，自动调用本技能补充安全章节。

---

## 安全分析流程

### 第一步：识别安全相关模块

扫描 PRD 中涉及安全的功能，生成安全敏感模块列表：

| 功能类型 | 安全风险等级 | 典型风险 |
|---------|------------|---------|
| 用户认证 | 高 | 密码泄露、会话劫持、暴力破解 |
| 支付/内购 | 极高 | 支付欺诈、价格篡改、签名绕过 |
| 数据存储 | 高 | 数据泄露、未授权访问、备份泄露 |
| 网络通信 | 高 | 中间人攻击、数据篡改、重放攻击 |
| 敏感信息 | 中 | 日志泄露、调试信息、错误消息 |
| 权限请求 | 中 | 过度权限、权限滥用 |

---

### 第二步：威胁建模（STRIDE/LINDDUN）

根据识别的模块，为每个高风险功能生成 STRIDE 威胁分析：

```markdown
### 功能：[功能名称]

| 威胁类型 | 威胁描述 | 攻击向量 | 缓解措施 | 优先级 |
|---------|---------|---------|---------|--------|
| Spoofing（假冒）| 攻击者假冒合法用户身份 | [具体攻击方式] | [缓解方案] | [P0/P1/P2] |
| Tampering（篡改）| 修改传输中或存储的数据 | [具体攻击方式] | [缓解方案] | [P0/P1/P2] |
| Repudiation（抵赖）| 用户否认执行过某操作 | [具体攻击方式] | [缓解方案] | [P0/P1/P2] |
| Information Disclosure（信息泄露）| 敏感信息被未授权方获取 | [具体攻击方式] | [缓解方案] | [P0/P1/P2] |
| Denial of Service（拒绝服务）| 服务不可用 | [具体攻击方式] | [缓解方案] | [P0/P1/P2] |
| Elevation of Privilege（权限提升）| 获得超出应有权限的访问 | [具体攻击方式] | [缓解方案] | [P0/P1/P2] |
```

**STRIDE 各威胁类型的通用缓解措施**：

| 威胁类型 | 核心缓解措施 |
|---------|------------|
| Spoofing | 强身份认证（MFA/生物识别）、会话令牌绑定 IP+UA |
| Tampering | TLS 传输加密、数据签名（HMAC）、完整性校验 |
| Repudiation | 操作日志审计、数字签名、不可篡改日志 |
| Information Disclosure | 最小权限原则、敏感数据加密、日志脱敏 |
| Denial of Service | Rate Limiting、流量清洗、冗余架构 |
| Elevation of Privilege | RBAC/ABAC 权限模型、最小权限原则、输入校验 |

---

### 第三步：隐私合规检查

根据目标平台和功能类型，自动映射对应法规要求：

| 法规 | 适用场景 | 核心要求 |
|------|---------|---------|
| GDPR（欧盟）| 处理欧盟用户数据 | 知情同意、数据最小化、删除权 |
| CCPA（加州）| 加州居民个人信息 | 选择退出、数据披露权 |
| APP（国内）| 中国用户个人信息 | 告知同意、明确目的、最小必要 |
| COPPA（美国）| 13岁以下儿童 | 父母知情、Verifiable Consent |
| PCI DSS | 支付卡数据 | 安全存储、传输加密、访问控制 |

**平台特定隐私要求**：

| 平台 | 权限说明要求 | 禁止行为 |
|------|------------|---------|
| iOS App Store | 隐私政策 URL 必填 | 不收集未声明的数据 |
| Google Play | 数据安全表单必填 | 不使用非必要权限 |
| macOS App Store | 隐私合规声明 | 不共享用户数据给第三方 |
| Web | Cookie 同意横幅 | 不使用追踪 Cookie 除非同意 |

---

### 第四步：数据加密方案

根据数据类型和场景，推荐加密方案：

| 数据类型 | 存储加密 | 传输加密 | 密钥管理 |
|---------|---------|---------|---------|
| 密码 | bcrypt/Argon2（不可逆哈希）| TLS 1.3 | 服务端盐值 |
| 敏感令牌 | AES-256-GCM | TLS 1.3 | Keychain (iOS/macOS) |
| 用户个人信息 | AES-256 | TLS 1.3 | Keychain / EncryptedSharedPreferences |
| 支付信息 | 令牌化（不存储原始卡号）| TLS 1.3 | PCI DSS 合规存储 |
| 本地缓存 | AES-256 | N/A | 本地密钥 + 生物识别 |
| API 密钥 | 不存储 | TLS 1.3 | 环境变量 / CI Secrets |

**平台具体实现**：

macOS:
- 密码哈希: `CryptoKit` 的 `SHA256` + 盐值，优先使用 `Security.framework` 的 `SecKeychain`
- 敏感数据: `Keychain Services` 存储，带 `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`
- 文件加密: `Data Protection` API，使用 `.complete` 保护级别
- 详细参考: `references/macos-security-guide.md`

iOS:
- 密码哈希: `CryptoKit` 或第三方库（如 `CryptoSwift`）
- 敏感数据: `Keychain` 存储，带 `kSecAttrAccessibleWhenUnlocked`
- 生物识别: `LocalAuthentication.framework`，`context.evaluatePolicy()`
- 文件加密: `Data Protection` API
- 详细参考: `references/ios-security-guide.md`

Android:
- 密码哈希: `BCrypt` 或 `Argon2`
- 敏感数据: `EncryptedSharedPreferences`，或 `android.security.keystore`
- 生物识别: `BiometricPrompt` API
- 文件加密: `EncryptedFile` (Java/Kotlin)
- 详细参考: `references/android-security-guide.md`

Web:
- 密码哈希: 永远不在前端哈希（服务端做）
- 敏感数据: 不在前端存储，使用 `httpOnly` + `secure` Cookie
- HTTPS: 强制使用 TLS 1.3，配置 HSTS
- 详细参考: `references/web-security-guide.md`

---

### 第五步：API 鉴权方案

根据 PRD 识别的 API 类型，推荐鉴权方案：

| API 类型 | 推荐方案 | 令牌位置 | 刷新策略 |
|---------|---------|---------|---------|
| 用户认证 API | JWT Bearer Token | `Authorization` Header | Refresh Token 自动刷新 |
| 内部服务 API | API Key | `X-API-Key` Header | 定期轮换 |
| 第三方 API | OAuth 2.0 | `Authorization` Header | 访问令牌 + 刷新令牌 |
| Webhook | HMAC 签名 | `X-Signature` Header | 验证签名有效性 |
| 公开 API | 无鉴权 / Rate Limiting | N/A | IP 限流 |

**JWT 安全配置**：

```yaml
JWT配置:
  算法: RS256（优先）/ HS256（简单场景）
  过期时间: access_token: 15分钟, refresh_token: 7天
  存储: httpOnly Cookie（Web）/ Keychain（移动）
  安全标志: secure=true, sameSite=strict
  黑名单: refresh_token 使用一次即作废
```

**OAuth 2.0 安全注意点**：

- Authorization Code + PKCE（移动端必须）
- 不使用 Implicit Grant（已被废弃）
- 刷新令牌存放在服务端，不在客户端持久化
- Scope 遵循最小权限原则

---

### 第六步：敏感信息处理

为每个涉及敏感数据的模块，补充处理规范：

```markdown
### 功能：[功能名称]

**敏感数据识别：**
- [具体敏感字段，如密码、信用卡号、身份证号]

**日志处理：**
- 禁止：`logger.info("password: \(password)")`
- 正确：`logger.info("password: [REDACTED]")`
- 脱敏规则：手机号脱敏为 `138****5678`，邮箱脱敏为 `a***@example.com`

**错误消息：**
- 禁止：`"密码错误，用户不存在"`
- 正确：`"用户名或密码错误"`
- 原因：防止用户名枚举攻击

**调试信息：**
- 禁止：在生产环境暴露堆栈跟踪
- 正确：使用错误码，日志记录详情供运维排查
```

**敏感信息脱敏规则表**：

| 数据类型 | 原始示例 | 脱敏后 | 脱敏规则 |
|---------|---------|-------|---------|
| 手机号 | 13812345678 | 138****5678 | 显示前3后4，中间4位替换为* |
| 邮箱 | user@example.com | u***@example.com | 用户名只保留首字符 |
| 身份证 | 110101199001011234 | 110101**********1234 | 显示前6后4 |
| 银行卡 | 6222021234567890 | 622202******7890 | 显示前6后4 |
| 密码 | anyPassword | [REDACTED] | 统一替换为 [REDACTED] |
| JWT Token | eyJhbGciOi... | eyJhbG*** | 仅显示类型前缀 |

---

### 第七步：安全测试场景

生成与 PRD 功能对应的安全测试用例：

| # | 测试场景 | 攻击手法 | 预期结果 | 优先级 |
|---|---------|---------|---------|--------|
| 1 | 暴力破解登录 | 10000次/秒连续尝试 | 5次失败后账户锁定30分钟 | P0 |
| 2 | SQL 注入 | `' OR '1'='1` | 返回 403，参数化查询生效 | P0 |
| 3 | XSS 存储型 | `<script>alert(1)</script>` | 脚本被转义，不执行 | P0 |
| 4 | CSRF 攻击 | 诱导点击 POST 请求 | 无有效 CSRF Token，请求被拒绝 | P0 |
| 5 | 会话劫持 | 窃取 Session Token | Token 绑定 IP + UA，异常访问被拒绝 | P1 |
| 6 | 敏感数据泄露 | 访问 /api/user/me | 不返回明文密码或完整 token | P0 |
| 7 | 权限绕过 | 直接访问 /api/admin/* | 无 admin 角色返回 403 | P0 |
| 8 | API 限流绕过 | 改变 IP 或 Header | 正常限流生效 | P1 |
| 9 | 中间人攻击 | 抓包查看明文传输 | 所有传输使用 TLS，不接受自签名证书 | P0 |
| 10 | 密码强度检查 | 尝试 `123456` | 注册/修改密码被拒绝，提示强度要求 | P1 |

**安全测试优先级说明**：

| 优先级 | 含义 | 处理时限 |
|-------|------|---------|
| P0 | 高危，必须修复才能上线 | 阻塞 |
| P1 | 中危，发布前应修复 | Sprint 内 |
| P2 | 低危，可安排后续迭代 | Backlog |

---

## 输出格式

生成的 PRD 安全章节格式如下：

```markdown
## X. 安全分析

> 由 prd-security-analysis 技能自动生成

### X.1 安全敏感模块识别

| 功能类型 | 安全风险等级 | 涉及模块 |
|---------|------------|---------|
| [功能类型] | [高/中/极高] | [具体模块名称] |

### X.2 威胁建模

[每个高风险功能的 STRIDE 分析表]

### X.3 隐私合规

[适用的法规清单和平台要求]

### X.4 数据加密方案

[数据类型 -> 加密方案映射表]

### X.5 API 鉴权方案

[API 类型 -> 鉴权方案映射表]

### X.6 敏感信息处理规范

[每个涉及敏感数据的模块的处理规范]

### X.7 安全测试场景

[安全测试用例表]
```

---

## 与其他技能的协作

### 与 prd-orchestrator 的协作

- **调用时机**：在动态增强阶段，当检测到安全敏感功能时自动调用
- **输入**：已生成的 PRD 文本或文件路径
- **输出**：追加安全章节后的完整 PRD
- **触发关键词**：`登录`、`支付`、`用户数据`、`加密`、`鉴权`、`隐私`

### 与 prd-deep-expand 的协作

- **调用方式**：在六维度扩展中，如用户需要可在扩展前先运行安全分析
- **推荐顺序**：架构设计 -> 安全分析 -> UI/UX -> 工程化 -> 测试 -> 运维
- **章节引用**：在安全分析完成后，可在测试策略中引用安全测试场景

### 与 prd-review-panel 的协作

- **评审维度**：安全分析可作为第7个评审维度加入
- **评审重点**：威胁建模完整性、隐私合规性、加密方案合理性
- **安全评分项**：OWASP Top 10 覆盖、加密算法强度、鉴权机制完善性

---

## 自检机制

生成安全章节后，必须通过以下检查：

### 检查1：功能覆盖检查

确认每个安全敏感功能都有对应的安全分析：

- 用户认证模块 -> 威胁建模 + 密码哈希方案 + 防暴力破解
- 支付/内购模块 -> 威胁建模 + PCI DSS 合规 + 令牌化存储
- 数据存储模块 -> 加密方案 + 密钥管理
- API 模块 -> 鉴权方案 + 限流策略

### 检查2：合规性检查

确认满足目标平台的安全要求：

- iOS: App Transport Security (ATS) 默认开启，不允许 http
- macOS: Hardened Runtime + App Sandbox
- Android: 网络安全配置 (network security config)
- Web: HTTPS 强制，HSTS 头配置

### 检查3：实际性检查

确认加密方案和密钥管理具有可执行性：

- 不使用不安全的算法（如 MD5、SHA1 用于密码哈希）
- 不在前端存储敏感信息
- API 密钥不在代码中硬编码
- JWT 配置符合安全最佳实践

---

## 执行伪代码

当用户说 "安全分析这个PRD" 或 orchestrator 自动触发时，按以下流程执行：

```
1. input = PRD 内容（文本或文件路径）
2. if input 是文件路径:
   - 读取文件内容
3. modules = identifySecurityModules(input)
   // 扫描关键词，返回 { type, riskLevel, description }
4. if modules.length == 0:
   - 输出："未检测到需要安全分析的功能模块"
   - 退出
5. stride = []
6. for module in modules where module.riskLevel >= 高:
   - s = generateSTRIDE(module)
   - stride.append(s)
7. privacy = mapPrivacyCompliance(input)
   // 根据平台映射法规要求
8. encryption = generateEncryptionSchemes(modules)
   // 为每个敏感数据类型生成加密方案
9. auth = generateAuthSchemes(input)
   // 识别 API 类型，生成鉴权方案
10. sensitive = generateSensitiveDataRules(modules)
    // 为每个模块生成敏感信息处理规范
11. tests = generateSecurityTests(modules)
    // 基于模块生成安全测试用例
12. chapter = assembleChapter(stride, privacy, encryption, auth, sensitive, tests)
13. if 用户是文件输入:
    - 追加章节到原文件
    - 输出文件路径
14. else:
    - 直接输出章节内容
15. selfCheck(chapter)
```

---

## 平台特定安全参考

详细的安全实现指导请参考以下文档：

- **macOS**: `references/macos-security-guide.md`
  - Keychain Services、Code Signing、Hardened Runtime、App Sandbox、公证
- **iOS**: `references/ios-security-guide.md`
  - Keychain、Biometrics、Data Protection、App Transport Security
- **Android**: `references/android-security-guide.md`
  - EncryptedSharedPreferences、Keystore、BiometricPrompt、ProGuard/R8
- **Web**: `references/web-security-guide.md`
  - HTTPS、CSP、CORS、XSS、CSRF、OWASP Top 10

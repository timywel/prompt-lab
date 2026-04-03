# prd-security-analysis

PRD 安全分析扩展技能，自动为 PRD 补充威胁建模、隐私合规、数据加密、API 鉴权、安全测试等安全章节。

## 功能

- **威胁建模**：基于 STRIDE 模型为每个安全敏感功能生成威胁分析
- **隐私合规**：映射 GDPR、CCPA、APP、COPPA 等法规要求
- **数据加密**：根据数据类型和平台推荐加密方案（密码哈希、AES、JWT 等）
- **API 鉴权**：推荐 JWT、OAuth 2.0、API Key 等鉴权方案
- **敏感信息处理**：日志脱敏、错误消息防枚举、调试信息保护
- **安全测试**：生成与功能对应的安全测试用例（P0/P1/P2）

## 触发关键词

- `prd-security-analysis`
- `安全分析PRD`
- `PRD安全`
- `安全审查`
- `隐私合规`

## 与 PRD 生态系统的集成

| 触发方式 | 调用时机 |
|---------|---------|
| prd-orchestrator 自动检测 | PRD 包含登录/支付/用户数据/加密等安全敏感关键词时 |
| 用户明确请求 | 用户说"安全分析这个PRD" |
| 动态增强注入 | prd-orchestrator 的动态增强阶段 |

### 技能协作关系

```
prd-orchestrator（协调层）
  └── 动态增强阶段
        └── prd-security-analysis（安全扩展）
              ├── references/macos-security-guide.md
              ├── references/ios-security-guide.md
              ├── references/android-security-guide.md
              └── references/web-security-guide.md
```

## 平台覆盖

- macOS 桌面应用
- iOS App
- Android App
- Web 应用
- 跨平台应用

## 参考文档

- `references/macos-security-guide.md` — macOS 平台安全实现指南
- `references/ios-security-guide.md` — iOS 平台安全实现指南
- `references/android-security-guide.md` — Android 平台安全实现指南
- `references/web-security-guide.md` — Web 平台安全实现指南

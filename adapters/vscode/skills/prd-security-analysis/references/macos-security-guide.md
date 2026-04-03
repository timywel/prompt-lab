# macOS 安全实现指南

本指南提供 macOS 平台的安全实现参考，涵盖 Keychain、Code Signing、Hardened Runtime、App Sandbox 和公证等核心安全机制。

---

## 1. Keychain Services

macOS 使用 Keychain 作为核心安全存储，用于安全存储密码、密钥、证书等敏感数据。

### 1.1 基础存储操作

```swift
import Security

// 存储到 Keychain
func saveToKeychain(account: String, password: String) -> Bool {
    let passwordData = password.data(using: .utf8)!

    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: account,
        kSecValueData as String: passwordData,
        kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    ]

    // 先删除已存在的项
    SecItemDelete(query as CFDictionary)

    let status = SecItemAdd(query as CFDictionary, nil)
    return status == errSecSuccess
}

// 从 Keychain 读取
func readFromKeychain(account: String) -> String? {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: account,
        kSecReturnData as String: true,
        kSecMatchLimit as String: kSecMatchLimitOne
    ]

    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)

    guard status == errSecSuccess,
          let data = result as? Data,
          let password = String(data: data, encoding: .utf8) else {
        return nil
    }

    return password
}
```

### 1.2 访问控制级别

| 访问级别 | 常量 | 适用场景 |
|---------|------|---------|
| 无限制 | `kSecAttrAccessibleAlways` | 不推荐，数据在锁屏时也可用 |
| 登录后可用 | `kSecAttrAccessibleAfterFirstUnlock` | 用户登录后可访问 |
| 当前解锁可用 | `kSecAttrAccessibleWhenUnlocked` | 推荐，大多数场景 |
| 当前设备仅解锁可用 | `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` | 最高安全级别，不备份到其他设备 |
| 生物识别解锁 | `kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly` | 配合 Face ID/Touch ID 使用 |

### 1.3 配合生物识别使用

```swift
import LocalAuthentication

func saveWithBiometric(account: String, password: String) -> Bool {
    guard let passwordData = password.data(using: .utf8) else { return false }

    var accessError: Unmanaged<CFError>?
    guard let accessControl = SecAccessControlCreateWithFlags(
        kCFAllocatorDefault,
        kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        .biometryCurrentSet,
        &accessError
    ) else { return false }

    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: account,
        kSecValueData as String: passwordData,
        kSecAttrAccessControl as String: accessControl
    ]

    SecItemDelete(query as CFDictionary)
    return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
}
```

---

## 2. Code Signing（代码签名）

代码签名是 macOS 安全的基础，确保应用来自已知开发者且未被篡改。

### 2.1 签名要求

```bash
# 开发签名
codesign --force --sign "Developer ID Application: Your Name" \
  --options runtime \
  --entitlements YourApp.entitlements \
  YourApp.app

# 分发签名（不含公证）
codesign --force --sign "Developer ID Application: Your Name" \
  --options runtime,hard \
  --entitlements YourApp.entitlements \
  YourApp.app

# 验证签名
codesign --verify --verbose=2 YourApp.app
spctl --assess --verbose=2 --type exec YourApp.app
```

### 2.2 Entitlements 文件

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- App Sandbox（沙盒）-->
    <key>com.apple.security.app-sandbox</key>
    <true/>

    <!-- 网络访问 -->
    <key>com.apple.security.network.client</key>
    <true/>

    <!-- 文件访问（用户选择）-->
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>

    <!-- 辅助功能（全局事件监听）-->
    <key>com.apple.security.automation.apple-events</key>
    <true/>

    <!-- 麦克风权限 -->
    <key>com.apple.security.device.microphone</key>
    <true/>

    <!-- 下载文件夹 -->
    <key>com.apple.security.files.downloads.read-write</key>
    <true/>
</dict>
</plist>
```

### 2.3 常见签名错误处理

| 错误信息 | 原因 | 解决方案 |
|---------|------|---------|
| `invalid signature` | 二进制被修改或使用了错误的证书 | 重新签名，确保 entitlements 正确 |
| `code object is not signed at all` | 缺少签名 | 使用 --deep 标志进行深度签名 |
| `entitlements do not match` | entitlements 文件与签名不匹配 | 检查 entitlements 中的 App ID 与签名证书一致 |
| `expired certificate` | 证书过期 | 续期或重新生成证书 |

---

## 3. Hardened Runtime（强化运行时）

Hardened Runtime 是 macOS 10.14.5+ 强制启用的安全机制，用于防止代码注入和运行时攻击。

### 3.1 启用强化运行时

```xml
<!-- Entitlements 中启用 -->
<key>com.apple.security.hardened-runtime</key>
<true/>
```

### 3.2 JIT 编译器例外（如果需要）

某些应用（如浏览器、游戏引擎）需要 JIT 编译，需要申请例外：

```xml
<key>com.apple.security.cs.allow-jit</key>
<true/>

<key>com.apple.security.cs.allow-unsigned-executable-memory</key>
<true/>
```

### 3.3 禁用库验证（仅开发用）

```xml
<!-- 禁止在生产环境使用！仅调试用 -->
<key>com.apple.security.cs.disable-library-validation</key>
<true/>
```

---

## 4. App Sandbox（应用沙盒）

App Sandbox 限制应用对系统资源的访问，防止恶意软件造成损害。

### 4.1 沙盒能力

| 能力 | Entitlements 键 | 说明 |
|------|-----------------|------|
| 网络客户端 | `com.apple.security.network.client` | 允许创建 outgoing 网络连接 |
| 网络服务器 | `com.apple.security.network.server` | 允许监听端口 |
| 文件读取（用户选择）| `com.apple.security.files.user-selected.read-only` | 用户选择的文件只读 |
| 文件读写（用户选择）| `com.apple.security.files.user-selected.read-write` | 用户选择的文件读写 |
| 下载文件夹 | `com.apple.security.files.downloads.read-write` | 下载目录读写 |
| Apple Events | `com.apple.security.automation.apple-events` | 允许发送 Apple Events 到其他应用 |

### 4.2 沙盒限制

- **无法访问**：`/usr/bin`、`/bin`、`/sbin`、`/System` 等系统目录
- **受限访问**：用户主目录（需声明特定路径）
- **完全隔离**：只能通过声明的能力访问受保护资源

### 4.3 沙盒与全局事件的冲突

当使用 `CGEventTap` 进行全局键盘/鼠标监听时：

- **方案A**：关闭 App Sandbox（失去 Mac App Store 上架资格）
- **方案B**：保持沙盒开启，通过 Accessibility API 申请辅助功能权限

```swift
// 检查辅助功能权限
func checkAccessibilityPermission() -> Bool {
    let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
    return AXIsProcessTrustedWithOptions(options)
}
```

---

## 5. Notarization（公证）

公证是 macOS 10.15+ 必须的安全步骤，确保应用通过 Apple 的自动化安全检查。

### 5.1 公证流程

```bash
# 1. 签名应用
codesign --force --sign "Developer ID Application: Your Name" \
  --options runtime --deep YourApp.app

# 2. 打包为 ZIP
cd build
zip -r YourApp.zip YourApp.app
cd ..

# 3. 提交公证
xcrun notarytool submit YourApp.zip \
  --apple-id "$APPLE_ID" \
  --team-id "$TEAM_ID" \
  --password "$APPLE_APP_PASSWORD" \
  --wait

# 4. 附加票据（Staple）
xcrun stapler staple YourApp.app

# 5. 验证
xcrun stapler validate YourApp.app
spctl --assess --verbose=4 --type exec YourApp.app
```

### 5.2 常见公证错误

| 错误 | 原因 | 解决方案 |
|------|------|---------|
| `The file is not signed with a valid Apple Developer certificate` | 签名无效或过期 | 更新签名证书 |
| `The executable(s) are not signed with a valid Apple Developer certificate` | 二进制未签名 | 使用 --deep 重新签名 |
| `Could not find the signing identity` | 证书不可用 | 检查钥匙串访问，导出正确证书 |
| `Archive contains invalid paths` | 包含无效路径 | 检查包内容，移除敏感文件 |

### 5.3 自动构建中的公证

```yaml
# GitHub Actions 中的公证配置
- name: Notarize
  run: |
    xcrun notarytool submit build/${{ env.APP_NAME }}.zip \
      --apple-id "${{ secrets.APPLE_ID }}" \
      --team-id "${{ secrets.APPLE_TEAM_ID }}" \
      --password "${{ secrets.APPLE_APP_PASSWORD }}" \
      --wait
  env:
    APPLE_ID: ${{ secrets.APPLE_ID }}
    APPLE_TEAM_ID: ${{ secrets.APPLE_TEAM_ID }}
    APPLE_APP_PASSWORD: ${{ secrets.APPLE_APP_PASSWORD }}
```

---

## 6. CryptoKit 加密实践

### 6.1 密码哈希

```swift
import CryptoKit
import Foundation

// 使用 Argon2 或 PBKDF2 进行密码哈希
// macOS 12+ 推荐使用 CryptoKit

struct PasswordHasher {
    // 推荐：使用 PBKDF2 + 随机盐值
    static func hash(password: String, salt: Data) -> Data {
        let passwordData = Data(password.utf8)

        // 使用 HKDF 的 HMAC 作为 PBKDF2 的替代（需要多轮迭代）
        var result = Data()
        var block = Data()
        block.append(contentsOf: [0, 0, 0, 1]) // 块索引
        block.append(salt)

        for _ in 0..<100_000 { // 迭代次数
            block = Data(HMAC<SHA256>.authenticationCode(for: block, using: SymmetricKey(data: passwordData)))
            result.append(contentsOf: block)
        }

        return Data(result.prefix(32))
    }

    // 生成随机盐值
    static func generateSalt() -> Data {
        var salt = Data(count: 32)
        _ = salt.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, 32, $0.baseAddress!) }
        return salt
    }

    // 验证密码
    static func verify(password: String, salt: Data, hash: Data) -> Bool {
        let computed = hash(password: password, salt: salt)
        return computed == hash
    }
}
```

### 6.2 对称加密（AES-GCM）

```swift
import CryptoKit

struct AESEncryptor {
    // AES-256-GCM 加密
    static func encrypt(data: Data, key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: key)
        guard let combined = sealedBox.combined else {
            throw CryptoError.encryptionFailed
        }
        return combined
    }

    // AES-256-GCM 解密
    static func decrypt(data: Data, key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: key)
    }

    // 从密码派生密钥
    static func deriveKey(from password: String, salt: Data) -> SymmetricKey {
        let passwordData = Data(password.utf8)
        let derivedKey = HKDF<SHA256>.deriveKey(
            inputKeyMaterial: SymmetricKey(data: passwordData),
            salt: salt,
            info: Data("AES-Encryption".utf8),
            outputByteCount: 32
        )
        return derivedKey
    }
}
```

### 6.3 文件加密（Data Protection）

```swift
import Foundation

// 使用 macOS Data Protection API 加密文件
struct SecureFileStorage {
    static func saveSecure(data: Data, to url: URL) throws {
        // 设置文件保护级别
        try data.write(to: url, options: [.completeFileProtection])
    }

    static func loadSecure(from url: URL) throws -> Data {
        return try Data(contentsOf: url)
    }

    static func isProtected(url: URL) -> Bool {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let protection = attributes[.protectionKey] as? FileProtectionType {
                return protection == .complete
            }
        } catch {}
        return false
    }
}
```

---

## 7. 安全最佳实践清单

| # | 检查项 | 说明 |
|---|-------|------|
| 1 | Keychain 访问级别 | 敏感数据使用 `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` |
| 2 | App Sandbox | 启用沙盒，仅声明必要的沙盒能力 |
| 3 | Hardened Runtime | 启用强化运行时，不使用 `.disable-library-validation` |
| 4 | 公证 | 所有分发的应用必须通过公证 |
| 5 | Entitlements | 定期审查 entitlements，移除未使用的权限 |
| 6 | 加密算法 | 不使用 MD5/SHA1/RC4 等不安全算法 |
| 7 | 网络安全 | App Transport Security 默认拒绝 http |
| 8 | 调试日志 | 生产环境不输出敏感数据 |
| 9 | 错误处理 | 不在错误消息中暴露系统路径或内部结构 |
| 10 | 依赖更新 | 定期更新依赖，修复已知安全漏洞 |

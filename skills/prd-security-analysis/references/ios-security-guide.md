# iOS 安全实现指南

本指南提供 iOS 平台的安全实现参考，涵盖 Keychain、生物识别、Data Protection、App Transport Security 等核心安全机制。

---

## 1. Keychain Services

iOS Keychain 提供安全存储，适用于密码、令牌、密钥等敏感数据。

### 1.1 基础存储操作

```swift
import Security

struct KeychainManager {
    static let service = "com.example.app"

    // 存储
    static func save(key: String, data: Data) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    // 读取
    static func read(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    // 删除
    static func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
```

### 1.2 Keychain 访问级别

| 访问级别 | 常量 | 适用场景 |
|---------|------|---------|
| 解锁后可用 | `kSecAttrAccessibleWhenUnlocked` | 默认，大多数场景 |
| 解锁后首次使用前 | `kSecAttrAccessibleAfterFirstUnlock` | App 重启后首次访问前 |
| 设备解锁时 | `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` | 最高安全级别，不备份 |
| 设备已设置密码 | `kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly` | 需要配合生物识别 |

### 1.3 配合生物识别

```swift
import LocalAuthentication

struct BiometricKeychainManager {
    static let service = "com.example.app"

    // 带生物识别保护的存储
    static func saveWithBiometric(key: String, data: Data) -> Bool {
        var error: Unmanaged<CFError>?

        guard let accessControl = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            .biometryCurrentSet,
            &error
        ) else { return false }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessControl as String: accessControl
        ]

        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }

    // 使用生物识别读取
    static func readWithBiometric(key: String, completion: @escaping (Data?) -> Void) {
        let context = LAContext()
        context.localizedReason = "访问您的敏感数据"

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecUseAuthenticationContext as String: context
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        DispatchQueue.main.async {
            completion(status == errSecSuccess ? result as? Data : nil)
        }
    }

    // 检查生物识别可用性
    static func canUseBiometrics() -> (available: Bool, type: LABiometryType) {
        let context = LAContext()
        var error: NSError?

        let available = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        return (available, context.biometryType)
    }
}
```

---

## 2. LocalAuthentication（生物识别）

### 2.1 Face ID / Touch ID 集成

```swift
import LocalAuthentication

struct BiometricAuthenticator {
    enum BiometricType {
        case none
        case touchID
        case faceID
    }

    static var biometricType: BiometricType {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }

        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        case .opticID:
            return .none
        @unknown default:
            return .none
        }
    }

    // 评估生物识别
    static func authenticate(reason: String, completion: @escaping (Bool, Error?) -> Void) {
        let context = LAContext()
        context.localizedFallbackTitle = "使用密码"
        context.localizedCancelTitle = "取消"

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            completion(false, error)
            return
        }

        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: reason
        ) { success, authError in
            DispatchQueue.main.async {
                completion(success, authError)
            }
        }
    }

    // 带设备密码回退的认证
    static func authenticateWithPasscodeFallback(
        reason: String,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        let context = LAContext()

        context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: reason
        ) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
}
```

---

## 3. Data Protection（数据保护）

iOS 文件系统提供基于硬件加密的数据保护。

### 3.1 文件保护级别

```swift
import Foundation

struct SecureFileManager {
    // Complete Protection（最高）：设备解锁前不可访问
    static func saveCompleteProtection(data: Data, to url: URL) throws {
        try data.write(to: url, options: .completeFileProtection)
    }

    // Complete Unless Open：文件打开后可被其他进程访问
    static func saveCompleteUnlessOpen(data: Data, to url: URL) throws {
        try data.write(to: url, options: .completeFileProtectionUnlessOpen)
    }

    // Complete Until First User Authentication：首次解锁前不可访问
    static func saveCompleteUntilFirstAuth(data: Data, to url: URL) throws {
        try data.write(to: url, options: .completeFileProtectionUntilFirstUserAuthentication)
    }

    // 检查文件保护级别
    static func protectionLevel(of url: URL) -> FileProtectionType? {
        do {
            let attrs = try FileManager.default.attributesOfItem(atPath: url.path)
            return attrs[.protectionKey] as? FileProtectionType
        } catch {
            return nil
        }
    }
}
```

### 3.2 SQLite 数据库保护

```swift
import SQLite3

struct SecureDatabase {
    static func openSecure(path: String) -> OpaquePointer? {
        var db: OpaquePointer?

        // 打开数据库
        guard sqlite3_open(path, &db) == SQLITE_OK else { return nil }

        // 设置文件保护级别（iOS 特定）
        let query = "PRAGMA file_protection = complete"
        sqlite3_exec(db, query, nil, nil, nil)

        // 启用 WAL 模式
        let walQuery = "PRAGMA journal_mode = WAL"
        sqlite3_exec(db, walQuery, nil, nil, nil)

        return db
    }
}
```

---

## 4. App Transport Security (ATS)

ATS 默认强制所有网络连接使用 HTTPS，阻止明文传输。

### 4.1 Info.plist 配置

```xml
<!-- 默认强制 HTTPS（不需要额外配置）-->

<!-- 允许加载 HTTP 图片资源 -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoadsInWebContent</key>
    <false/>
    <key>NSAllowsLocalNetworking</key>
    <true/>
    <!-- 谨慎使用，仅在明确需要时启用 -->
    <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>
```

### 4.2 证书固定（Certificate Pinning）

```swift
import Security
import CryptoKit

struct CertificatePinning {
    // 方式1：使用 URLSessionDelegate 进行证书固定
    class PinnedURLSessionDelegate: NSObject, URLSessionDelegate {
        private let trustedHashes: Set<String> = [
            "sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
            "sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB="
        ]

        func urlSession(
            _ session: URLSession,
            didReceive challenge: URLAuthenticationChallenge,
            completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
        ) {
            guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
                  let serverTrust = challenge.protectionSpace.serverTrust else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }

            let credential = URLCredential(trust: serverTrust)

            // 验证证书
            if validateCertificate(serverTrust) {
                completionHandler(.useCredential, credential)
            } else {
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
        }

        private func validateCertificate(_ serverTrust: SecTrust) -> Bool {
            var error: CFError?
            guard SecTrustEvaluateWithError(serverTrust, &error) else { return false }

            guard let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
                return false
            }

            let serverCertificateData = SecCertificateCopyData(serverCertificate) as Data
            let serverHash = "sha256/\(serverCertificateData.base64EncodedString())"

            return trustedHashes.contains(serverHash)
        }
    }
}
```

---

## 5. CryptoKit 加密实践

### 5.1 密码哈希

```swift
import CryptoKit
import Foundation

struct PasswordHasher {
    // PBKDF2 实现（使用 HMAC-SHA256，100000 次迭代）
    static func hash(password: String, salt: Data) -> Data {
        let passwordData = Data(password.utf8)
        let iterations = 100_000
        let derivedKeyLength = 32

        var derivedKey = Data(count: derivedKeyLength)
        let derivedCount = derivedKey.count

        derivedKey.withUnsafeMutableBytes { derivedKeyBytes in
            salt.withUnsafeBytes { saltBytes in
                passwordData.withUnsafeBytes { passwordBytes in
                    CCKeyDerivationPBKDF(
                        CCPBKDFAlgorithm(kCCPBKDF2),
                        passwordBytes.baseAddress?.assumingMemoryBound(to: Int8.self),
                        passwordData.count,
                        saltBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                        salt.count,
                        CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                        UInt32(iterations),
                        derivedKeyBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                        derivedCount
                    )
                }
            }
        }

        return derivedKey
    }

    // 生成随机盐值
    static func generateSalt() -> Data {
        var salt = Data(count: 32)
        _ = salt.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, 32, $0.baseAddress!) }
        return salt
    }
}
```

### 5.2 AES-GCM 加密

```swift
import CryptoKit

struct AESCryptor {
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

    // 生成随机密钥
    static func generateKey() -> SymmetricKey {
        return SymmetricKey(size: .bits256)
    }
}
```

---

## 6. 安全存储最佳实践

| # | 检查项 | 说明 |
|---|-------|------|
| 1 | 敏感数据存 Keychain | 密码、token、密钥必须存 Keychain，不使用 UserDefaults |
| 2 | Keychain 访问级别 | 高敏感数据使用 `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` |
| 3 | 生物识别保护 | 配合 `.biometryCurrentSet` 防止生物识别数据被重置后滥用 |
| 4 | 文件保护级别 | 使用 `.completeFileProtection` 保护敏感文件 |
| 5 | ATS 配置 | 保持默认强制 HTTPS，不使用 `NSAllowsArbitraryLoads` |
| 6 | 证书固定 | 对高安全性 API 启用证书固定 |
| 7 | 加密算法 | 使用 AES-256-GCM、ChaCha20-Poly1305，不使用不推荐算法 |
| 8 | 日志脱敏 | 生产环境不打印敏感数据（密码、token、信用卡号） |
| 9 | 截图保护 | 敏感界面使用 `.isSecureTextEntry` 或禁止截屏 |
| 10 | 后台数据保护 | 应用进入后台时使用 `scenePhase` 隐藏敏感内容 |

---

## 7. 常见安全漏洞与修复

| 漏洞类型 | 错误做法 | 正确做法 |
|---------|---------|---------|
| 敏感数据存储 | `UserDefaults.standard.set(password, forKey: "password")` | 使用 Keychain 存储 |
| 证书验证 | `allowInvalidCertificates = true` | 使用证书固定或默认验证 |
| 会话管理 | 不设置过期时间 | JWT 设置 15 分钟过期，refresh token 7 天 |
| 隐私权限 | 不提供权限说明 | 在 Info.plist 中填写清晰的 `NSXXXUsageDescription` |
| 调试信息 | `print("Password: \(password)")` | 使用 `os_log("Password: [REDACTED]")` |
| 密码传输 | HTTP 传输密码 | 强制 HTTPS，使用 TLS 1.3 |

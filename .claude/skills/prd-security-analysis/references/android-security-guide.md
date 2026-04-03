# Android 安全实现指南

本指南提供 Android 平台的安全实现参考，涵盖 EncryptedSharedPreferences、Keystore、BiometricPrompt、ProGuard/R8 等核心安全机制。

---

## 1. EncryptedSharedPreferences

EncryptedSharedPreferences 使用 Android Keystore 生成的密钥来加密数据，提供安全的持久化存储。

### 1.1 基础使用

```kotlin
// build.gradle 依赖
// implementation "androidx.security:security-crypto:1.1.0-alpha06"

// 主密钥生成（基于 Keystore）
val masterKey = MasterKey.Builder(context)
    .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
    .setKeyGenParameterSpec(
        KeyGenParameterSpec.Builder(
            MasterKey.DEFAULT_MASTER_KEY_ALIAS,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
        )
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setKeySize(256)
            .setUserAuthenticationRequired(false) // 可设为 true 要求生物识别
            .build()
    )
    .build()

// 创建 EncryptedSharedPreferences
val sharedPreferences = EncryptedSharedPreferences.create(
    context,
    "secure_prefs",
    masterKey,
    EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
    EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
)

// 使用方式与普通 SharedPreferences 相同
sharedPreferences.edit().putString("token", "jwt_token_value").apply()
val token = sharedPreferences.getString("token", null)
```

### 1.2 配合生物识别使用

```kotlin
// build.gradle 依赖
// implementation "androidx.biometric:biometric:1.1.0"

class SecurePreferencesManager(private val context: Context) {

    private val masterKey: MasterKey by lazy {
        MasterKey.Builder(context)
            .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
            .setUserAuthenticationRequired(true) // 关键：要求生物识别
            .setUserAuthenticationParameters(
                30, // 认证有效期（秒）
                KeyProperties.AUTH_BIOMETRIC_STRONG // 仅生物识别
            )
            .build()
    }

    private val encryptedPrefs by lazy {
        EncryptedSharedPreferences.create(
            context,
            "secure_biometric_prefs",
            masterKey,
            EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
            EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
        )
    }

    fun saveWithBiometric(key: String, value: String) {
        encryptedPrefs.edit().putString(key, value).apply()
    }

    fun getWithBiometric(
        key: String,
        onSuccess: (String?) -> Unit,
        onBiometricRequired: () -> Unit
    ) {
        val promptInfo = BiometricPrompt.PromptInfo.Builder()
            .setTitle("身份验证")
            .setSubtitle("验证身份以访问敏感数据")
            .setNegativeButtonText("取消")
            .setAllowedAuthenticators(BIOMETRIC_STRONG)
            .build()

        val biometricPrompt = BiometricPrompt(
            context as FragmentActivity,
            ContextCompat.getMainExecutor(context),
            object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationSucceeded(result: AuthenticationResult) {
                    super.onAuthenticationSucceeded(result)
                    onSuccess(encryptedPrefs.getString(key, null))
                }

                override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                    super.onAuthenticationError(errorCode, errString)
                    if (errorCode == BiometricPrompt.ERROR_NEGATIVE_BUTTON ||
                        errorCode == BiometricPrompt.ERROR_USER_CANCELED) {
                        onBiometricRequired()
                    }
                }
            }
        )

        biometricPrompt.authenticate(promptInfo)
    }
}
```

---

## 2. Android Keystore

Android Keystore 提供硬件支持的安全密钥存储，密钥永远不会暴露给应用代码。

### 2.1 生成密钥

```kotlin
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import java.security.KeyStore
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey

object KeystoreManager {

    private const val KEYSTORE_PROVIDER = "AndroidKeyStore"
    private const val KEY_ALIAS = "MyAppSecretKey"

    fun generateKey(): SecretKey {
        val keyGenerator = KeyGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_AES,
            KEYSTORE_PROVIDER
        )

        val keyGenSpec = KeyGenParameterSpec.Builder(
            KEY_ALIAS,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
        )
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setKeySize(256)
            .setUserAuthenticationRequired(false) // 或 true 配合生物识别
            .setRandomizedEncryptionRequired(true) // 强制随机 IV
            .build()

        keyGenerator.init(keyGenSpec)
        return keyGenerator.generateKey()
    }

    fun getKey(): SecretKey {
        val keyStore = KeyStore.getInstance(KEYSTORE_PROVIDER)
        keyStore.load(null)
        return keyStore.getKey(KEY_ALIAS, null) as SecretKey
    }

    fun deleteKey() {
        val keyStore = KeyStore.getInstance(KEYSTORE_PROVIDER)
        keyStore.load(null)
        keyStore.deleteEntry(KEY_ALIAS)
    }
}
```

### 2.2 加密和解密

```kotlin
import javax.crypto.Cipher
import javax.crypto.spec.GCMParameterSpec
import android.util.Base64

object CryptoManager {

    private const val ALGORITHM = "AES/GCM/NoPadding"
    private const val IV_SIZE = 12 // GCM 推荐 12 字节 IV
    private const val TAG_SIZE = 128 // 认证标签大小

    fun encrypt(data: ByteArray, secretKey: SecretKey): String {
        val cipher = Cipher.getInstance(ALGORITHM)
        cipher.init(Cipher.ENCRYPT_MODE, secretKey)

        val iv = cipher.iv
        val encryptedData = cipher.doFinal(data)

        // 合并 IV 和加密数据
        val combined = ByteArray(iv.size + encryptedData.size)
        System.arraycopy(iv, 0, combined, 0, iv.size)
        System.arraycopy(encryptedData, 0, combined, iv.size, encryptedData.size)

        return Base64.encodeToString(combined, Base64.NO_WRAP)
    }

    fun decrypt(encryptedString: String, secretKey: SecretKey): ByteArray {
        val combined = Base64.decode(encryptedString, Base64.NO_WRAP)

        // 分离 IV 和加密数据
        val iv = ByteArray(IV_SIZE)
        val encryptedData = ByteArray(combined.size - IV_SIZE)
        System.arraycopy(combined, 0, iv, 0, IV_SIZE)
        System.arraycopy(combined, IV_SIZE, encryptedData, 0, encryptedData.size)

        val cipher = Cipher.getInstance(ALGORITHM)
        val spec = GCMParameterSpec(TAG_SIZE, iv)
        cipher.init(Cipher.DECRYPT_MODE, secretKey, spec)

        return cipher.doFinal(encryptedData)
    }
}
```

---

## 3. BiometricPrompt API

BiometricPrompt 提供统一的生物识别认证接口，支持指纹、人脸、虹膜等。

### 3.1 基础使用

```kotlin
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity

class BiometricHelper(private val activity: FragmentActivity) {

    private val executor = ContextCompat.getMainExecutor(activity)

    fun canAuthenticate(): Int {
        val biometricManager = BiometricManager.from(activity)
        return biometricManager.canAuthenticate(
            BiometricManager.Authenticators.BIOMETRIC_STRONG
        )
    }

    fun authenticate(
        title: String = "身份验证",
        subtitle: String = "验证您的身份",
        negativeButtonText: String = "取消",
        onSuccess: () -> Unit,
        onError: (Int, String) -> Unit,
        onFailed: () -> Unit
    ) {
        val callback = object : BiometricPrompt.AuthenticationCallback() {
            override fun onAuthenticationSucceeded(result: AuthenticationResult) {
                super.onAuthenticationSucceeded(result)
                onSuccess()
            }

            override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                super.onAuthenticationError(errorCode, errString)
                onError(errorCode, errString.toString())
            }

            override fun onAuthenticationFailed() {
                super.onAuthenticationFailed()
                onFailed()
            }
        }

        val biometricPrompt = BiometricPrompt(activity, executor, callback)

        val promptInfo = BiometricPrompt.PromptInfo.Builder()
            .setTitle(title)
            .setSubtitle(subtitle)
            .setNegativeButtonText(negativeButtonText)
            .setAllowedAuthenticators(BiometricManager.Authenticators.BIOMETRIC_STRONG)
            // 或 .setDeviceCredentialAllowed(true) 允许设备凭证（PIN/图案/密码）
            .build()

        biometricPrompt.authenticate(promptInfo)
    }
}
```

### 3.2 可用性检查

```kotlin
val biometricManager = BiometricManager.from(context)

when (biometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG)) {
    BiometricManager.BIOMETRIC_SUCCESS ->
        // 可以使用生物识别
    BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE ->
        // 设备没有生物识别硬件
    BiometricManager.BIOMETRIC_ERROR_HW_UNAVAILABLE ->
        // 生物识别硬件不可用
    BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED ->
        // 用户未设置生物识别
    BiometricManager.BIOMETRIC_ERROR_SECURITY_UPDATE_REQUIRED ->
        // 需要安全更新
}
```

---

## 4. 网络安全配置

### 4.1 network_security_config.xml

```xml
<!-- res/xml/network_security_config.xml -->
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <!-- 默认配置：仅允许 HTTPS -->
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <certificates src="system"/>
        </trust-anchors>
    </base-config>

    <!-- 开发环境允许 HTTP（仅 debug 构建）-->
    <debug-overrides>
        <trust-anchors>
            <certificates src="user"/> <!-- 允许安装调试证书 -->
        </trust-anchors>
    </debug-overrides>

    <!-- 特定域名配置 -->
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">10.0.2.2</domain> <!-- Android 模拟器 localhost -->
        <domain includeSubdomains="true">localhost</domain>
    </domain-config>
</network-security-config>
```

### 4.2 AndroidManifest.xml 中引用

```xml
<application
    android:networkSecurityConfig="@xml/network_security_config"
    android:usesCleartextTraffic="false"
    ... >
</application>
```

### 4.3 OkHttp 证书固定

```kotlin
import okhttp3.CertificatePinner
import okhttp3.OkHttpClient

val certificatePinner = CertificatePinner.Builder()
    .add("api.example.com", "sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=")
    .add("api.example.com", "sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=")
    .build()

val client = OkHttpClient.Builder()
    .certificatePinner(certificatePinner)
    .build()
```

---

## 5. ProGuard / R8 混淆

ProGuard/R8 用于代码压缩、混淆和优化，同时需要正确配置以保护安全相关代码。

### 5.1 proguard-rules.pro

```prolog
# 保持安全相关的类和方法
-keepclassmembers class * implements android.os.Parcelable {
    public static final ** CREATOR;
}

# 保持枚举
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# 保持 R 类
-keepclassmembers class **.R$* {
    public static <fields>;
}

# 保持 Parcelable
-keepclass class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# 保持 Serializable
-keepclass class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# 保持 CryptoKit / security 相关的类
-keep class javax.crypto.** { *; }
-keep class java.security.** { *; }

# 保持 OkHttp（如果使用）
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase

# 保持 Retrofit（如果使用）
-keepattributes Signature, InnerClasses, EnclosingMethod
-keepattributes RuntimeVisibleAnnotations, RuntimeVisibleParameterAnnotations
-keepclassmembers,allowshrinking,allowobfuscation interface * {
    @retrofit2.http.* <methods>;
}
-dontwarn org.codehaus.mojo.animal_sniffer.IgnoreJRERequirement
-dontwarn javax.annotation.**
-dontwarn kotlin.Unit
-dontwarn retrofit2.KotlinExtensions
-dontwarn retrofit2.KotlinExtensions$*

# 保持数据类（用于 JSON 序列化）
-keepclassmembers class com.example.app.data.model.** {
    <fields>;
    <init>(...);
}
```

### 5.2 Debug vs Release 混淆

```gradle
android {
    buildTypes {
        debug {
            minifyEnabled false
            // debug 不混淆，便于调试
        }
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'

            // 签名配置
            signingConfig signingConfigs.release
        }
    }
}
```

---

## 6. Jetpack Security

### 6.1 Security-Crypto 库

```kotlin
// EncryptedFile 用于文件加密
import androidx.security.crypto.EncryptedFile

class SecureFileManager(private val context: Context) {

    private val masterKey: MasterKey by lazy {
        MasterKey.Builder(context)
            .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
            .build()
    }

    // 写入加密文件
    fun writeEncryptedFile(fileName: String, content: String) {
        val file = File(context.filesDir, fileName)
        if (file.exists()) {
            file.delete()
        }

        val encryptedFile = EncryptedFile.Builder(
            context,
            file,
            masterKey,
            EncryptedFile.FileEncryptionScheme.AES256_GCM_HKDF_4KB
        ).build()

        encryptedFile.openFileOutput().use { outputStream ->
            outputStream.write(content.toByteArray())
        }
    }

    // 读取加密文件
    fun readEncryptedFile(fileName: String): String? {
        val file = File(context.filesDir, fileName)
        if (!file.exists()) return null

        val encryptedFile = EncryptedFile.Builder(
            context,
            file,
            masterKey,
            EncryptedFile.FileEncryptionScheme.AES256_GCM_HKDF_4KB
        ).build()

        return encryptedFile.openFileInput().use { inputStream ->
            inputStream.bufferedReader().readText()
        }
    }
}
```

---

## 7. 安全最佳实践清单

| # | 检查项 | 说明 |
|---|-------|------|
| 1 | 敏感数据加密 | 使用 EncryptedSharedPreferences，不使用普通 SharedPreferences 存敏感数据 |
| 2 | Keystore | 加密密钥存于 Android Keystore，设置适当访问控制 |
| 3 | 生物识别 | 使用 BiometricPrompt，不使用不安全的指纹 API |
| 4 | 网络安全 | 设置 `cleartextTrafficPermitted="false"`，强制 HTTPS |
| 5 | 证书固定 | 对高安全性 API 启用证书固定 |
| 6 | ProGuard/R8 | release 构建必须启用混淆，保护敏感类名 |
| 7 | 日志脱敏 | 生产环境使用 Timber 等日志库，自动过滤敏感数据 |
| 8 | WebView 安全 | 禁用 JavaScriptInterface（API 17+），配置 WebSettings |
| 9 | Intent 保护 | 使用 `FLAG_EXCLUDE_STOPPED_PACKAGES`，验证接收方 |
| 10 | 组件导出控制 | 最小化 `exported="true"`，使用 `android:permission` 限制访问 |

---

## 8. 常见安全漏洞与修复

| 漏洞类型 | 错误做法 | 正确做法 |
|---------|---------|---------|
| 敏感数据存储 | `SharedPreferences.edit().putString("token", token)` | 使用 EncryptedSharedPreferences |
| 密码传输 | HTTP POST 传输密码 | 强制 HTTPS，TLS 1.2+ |
| 日志泄露 | `Log.d("TAG", "password: $password")` | 使用 Timber 并配置脱敏 |
| WebView | `webView.settings.javaScriptEnabled = true` | 禁用或严格限制 JavaScript |
| 证书验证 | `TrustManager` 接受所有证书 | 使用默认 CA 验证或证书固定 |
| 内容提供器 | `android:exported="true"` 无权限 | 设置 `android:permission` 或 `android:exported="false"` |
| PendingIntent | 不指定包名 | 使用 `PendingIntent.FLAG_IMMUTABLE` 或 `FLAG_MUTABLE` |

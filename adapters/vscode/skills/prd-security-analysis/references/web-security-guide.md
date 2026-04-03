# Web 安全实现指南

本指南提供 Web 应用的安全实现参考，涵盖 HTTPS、CSP、CORS、XSS、CSRF、OWASP Top 10 等核心安全机制。

---

## 1. HTTPS 和传输层安全

所有 Web 应用必须强制使用 HTTPS，禁止明文传输。

### 1.1 HTTPS 强制启用

**Nginx 配置**：

```nginx
server {
    listen 443 ssl http2;
    server_name example.com;

    ssl_certificate /path/to/fullchain.pem;
    ssl_certificate_key /path/to/privkey.pem;

    # TLS 版本配置（禁用 SSLv3、TLS 1.0、1.1）
    ssl_protocols TLSv1.2 TLSv1.3;

    # 密码套件配置
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers on;

    # OCSP Stapling
    ssl_stapling on;
    ssl_stapling_verify on;

    # HSTS（HTTP Strict Transport Security）
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;

    # 安全头
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # CSP 头（见下文 CSP 部分）
}

# HTTP 重定向到 HTTPS
server {
    listen 80;
    server_name example.com;
    return 301 https://$server_name$request_uri;
}
```

**Apache 配置**（.htaccess）：

```apache
RewriteEngine On
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

# HSTS
Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"

# 安全头
Header always set X-Frame-Options "SAMEORIGIN"
Header always set X-Content-Type-Options "nosniff"
Header always set Referrer-Policy "strict-origin-when-cross-origin"
```

### 1.2 HSTS（HTTP Strict Transport Security）

```
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
```

| 参数 | 说明 | 建议值 |
|------|------|-------|
| max-age | HSTS 有效期 | 31536000（1年）|
| includeSubDomains | 包含子域名 | 确认子域名均支持 HTTPS |
| preload | 申请加入 HSTS preload list | 生产环境推荐 |

### 1.3 安全 Cookie 配置

```javascript
// Node.js / Express
const session = require('express-session');

app.use(session({
  secret: process.env.SESSION_SECRET, // 不少于 32 字符的随机字符串
  name: 'sessionId', // 不要使用默认的 connect.sid
  resave: false,
  saveUninitialized: false,
  cookie: {
    httpOnly: true,    // 禁止 JavaScript 访问（防止 XSS 窃取）
    secure: true,      // 仅在 HTTPS 中传输
    sameSite: 'strict', // CSRF 防护（strict/lax/none）
    maxAge: 15 * 60 * 1000 // 15 分钟过期（access_token）
  }
}));

// JWT Token 存储（使用 httpOnly Cookie）
app.post('/login', (req, res) => {
  const accessToken = jwt.sign({ userId }, process.env.JWT_SECRET, {
    expiresIn: '15m',
    algorithm: 'RS256' // 推荐使用 RS256
  });

  const refreshToken = jwt.sign({ userId }, process.env.REFRESH_SECRET, {
    expiresIn: '7d'
  });

  // Access Token: httpOnly Cookie（JavaScript 无法访问）
  res.cookie('accessToken', accessToken, {
    httpOnly: true,
    secure: true,
    sameSite: 'strict',
    maxAge: 15 * 60 * 1000
  });

  // Refresh Token: httpOnly Cookie
  res.cookie('refreshToken', refreshToken, {
    httpOnly: true,
    secure: true,
    sameSite: 'strict',
    maxAge: 7 * 24 * 60 * 60 * 1000
  });
});
```

---

## 2. Content Security Policy (CSP)

CSP 是防止 XSS 的核心机制，通过白名单控制资源加载来源。

### 2.1 CSP 指令

| 指令 | 说明 |
|------|------|
| `default-src` | 默认加载策略 |
| `script-src` | JavaScript 来源 |
| `style-src` | CSS 样式来源 |
| `img-src` | 图片来源 |
| `connect-src` | AJAX、WebSocket、fetch 来源 |
| `font-src` | 字体来源 |
| `frame-src` | iframe 来源 |
| `report-uri` | 违规报告地址 |

### 2.2 CSP 配置示例

```javascript
// Express 中间件
const csp = require('content-security-policy');

const cspConfig = {
  'default-src': "'self'",
  'script-src': "'self' 'nonce-{NONCE}'", // 使用随机 nonce
  'style-src': "'self' 'nonce-{NONCE}'",
  'img-src': "'self' data: https:",
  'font-src': "'self' https://fonts.gstatic.com",
  'connect-src': "'self' https://api.example.com",
  'frame-ancestors': "'none'", // 禁止被嵌入
  'form-action': "'self'",
  'base-uri': "'self'",
  'object-src': "'none'",
  'upgrade-insecure-requests': ''
};

// 应用 CSP
app.use((req, res, next) => {
  const nonce = crypto.randomBytes(16).toString('base64');
  res.locals.nonce = nonce;

  const cspHeader = Object.entries(cspConfig)
    .map(([key, value]) => `${key} ${value.replace('{NONCE}', nonce)}`)
    .join('; ');

  res.setHeader('Content-Security-Policy', cspHeader);
  next();
});

// 在模板中使用 nonce
// <script nonce="<%= nonce %>">
```

### 2.3 Report-Only 模式

```nginx
# 先使用 Report-Only 模式收集违规报告
add_header Content-Security-Policy-Report-Only "default-src 'self'; report-uri /csp-violation";
```

```javascript
// 收集违规报告的端点
app.post('/csp-violation', express.json(), (req, res) => {
  const report = req.body['csp-report'];
  console.error('CSP Violation:', report);
  // 发送到日志系统
  logger.error({ type: 'csp-violation', report });
  res.sendStatus(204);
});
```

---

## 3. CORS（跨域资源共享）

### 3.1 CORS 配置

```javascript
const corsOptions = {
  origin: function (origin, callback) {
    // 允许的域名白名单
    const allowedOrigins = [
      'https://example.com',
      'https://app.example.com'
    ];

    // 允许没有 Origin 头（服务器间调用）或白名单中的来源
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
  exposedHeaders: ['X-Total-Count'], // 允许客户端读取的头
  credentials: true, // 允许携带 Cookie
  maxAge: 86400 // 预检请求缓存 24 小时
};

app.use(cors(corsOptions));

// 对于敏感的 API，额外的校验
app.delete('/api/admin/users/:id', cors(corsOptions), (req, res) => {
  // 验证管理员权限
  if (!req.user || req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Forbidden' });
  }
  // 处理请求
});
```

### 3.2 常见 CORS 错误

| 错误 | 原因 | 解决方案 |
|------|------|---------|
| `No 'Access-Control-Allow-Origin' header` | 响应缺少 CORS 头 | 配置服务器的 CORS 中间件 |
| `Credentials mode is 'include' but 'Access-Control-Allow-Credentials' is 'true' and 'Access-Control-Allow-Origin' is '*'` | 使用通配符 + credentials | origin 必须指定具体域名 |
| `Missing Allow-Origin` on preflight | 预检请求失败 | 正确处理 OPTIONS 请求 |

---

## 4. XSS（跨站脚本攻击）

### 4.1 预防措施

```javascript
// 1. 输入验证和清理
const DOMPurify = require('dompurify');
const { JSDOM } = require('jsdom');

// 服务端 HTML 清理
function sanitizeInput(input) {
  return DOMPurify.sanitize(input, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a'],
    ALLOWED_ATTR: ['href'],
    FORBID_TAGS: ['style', 'script'],
    FORBID_ATTR: ['style', 'onerror', 'onclick']
  });
}

// 2. 输出编码
function escapeHtml(unsafe) {
  return unsafe
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

// 3. React 自动转义（默认开启，不要使用 dangerouslySetInnerHTML）
// <div>{userContent}</div> // 自动转义

// 4. Vue 自动转义
// {{ userContent }} // 自动转义
// v-html 需要谨慎使用
```

### 4.2 DOM XSS 防护

```javascript
// 避免使用不安全的 DOM 操作
// 禁止：
document.write('<script>alert(1)</script>');
element.innerHTML = untrustedInput;
eval(untrustedCode);

// 推荐：
element.textContent = safeText;
element.setAttribute('href', sanitizeUrl(untrustedUrl));

// URL 清理
function sanitizeUrl(url) {
  const parsed = new URL(url, window.location.origin);
  if (!['http:', 'https:'].includes(parsed.protocol)) {
    return 'about:blank';
  }
  return url;
}

// 使用 textContent 设置文本内容
const userName = document.createElement('span');
userName.textContent = untrustedUserName; // 安全
```

---

## 5. CSRF（跨站请求伪造）

### 5.1 CSRF Token

```javascript
// 1. 生成 CSRF Token
app.get('/csrf-token', (req, res) => {
  // 生成随机 token
  const token = crypto.randomBytes(32).toString('hex');
  // 存储到 session
  req.session.csrfToken = token;
  // 同时设置到 Cookie（用于 Referer 校验失败时的降级）
  res.cookie('csrfToken', token, { httpOnly: true, sameSite: 'strict' });
  res.json({ csrfToken: token });
});

// 2. 验证 CSRF Token（中间件）
function verifyCsrfToken(req, res, next) {
  // 从请求头获取 token
  const headerToken = req.headers['x-csrf-token'];
  // 从请求体获取 token
  const bodyToken = req.body && req.body._csrf;
  // 从自定义 header 获取（推荐）
  const sessionToken = req.session.csrfToken;

  const requestToken = headerToken || bodyToken;

  if (!requestToken || requestToken !== sessionToken) {
    return res.status(403).json({ error: 'Invalid CSRF token' });
  }

  // 重新生成 token（一次性使用）
  req.session.csrfToken = crypto.randomBytes(32).toString('hex');

  next();
}

// 3. 应用到敏感路由
app.post('/api/transfer', verifyCsrfToken, (req, res) => {
  // 处理转账
});
```

### 5.2 SameSite Cookie

```javascript
// 设置 SameSite Cookie
res.cookie('sessionId', sessionId, {
  httpOnly: true,
  secure: true,
  sameSite: 'strict', // 严格模式，最安全
  // 或 'lax'：允许顶级导航的 GET 请求携带 Cookie
  // 不要使用 sameSite: 'none' 除非同时设置 secure: true
});
```

### 5.3 Referer/Origin 检查

```javascript
function verifyReferer(req, res, next) {
  const referer = req.headers.referer;
  const origin = req.headers.origin;

  // 检查 Referer 或 Origin 是否来自信任的域名
  const allowedOrigins = ['https://example.com', 'https://app.example.com'];

  if (origin && !allowedOrigins.includes(origin)) {
    return res.status(403).json({ error: 'Invalid origin' });
  }

  if (referer && !allowedOrigins.some(o => referer.startsWith(o))) {
    return res.status(403).json({ error: 'Invalid referer' });
  }

  next();
}
```

---

## 6. OWASP Top 10 (2021)

### 6.1 A01 - Broken Access Control（访问控制失效）

```javascript
// 1. 最小权限原则
// 每个路由都进行权限检查
app.use('/api/admin', requireAdmin);
app.use('/api/user', requireAuth);

// 2. 禁止目录遍历
function safeFilePath(userInput) {
  const baseDir = '/safe/uploads/';
  const requestedPath = path.resolve(baseDir, userInput);
  if (!requestedPath.startsWith(baseDir)) {
    throw new Error('Invalid path');
  }
  return requestedPath;
}

// 3. IDOR 防护
app.get('/api/documents/:id', requireAuth, async (req, res) => {
  const document = await Document.findById(req.params.id);
  // 验证用户是否有权访问
  if (document.ownerId !== req.user.id && !req.user.isAdmin) {
    return res.status(403).json({ error: 'Access denied' });
  }
  res.json(document);
});
```

### 6.2 A02 - Cryptographic Failures（加密失败）

```javascript
// 1. 不存储敏感数据（密码哈希）
const bcrypt = require('bcrypt');
const hashedPassword = await bcrypt.hash(password, 12);

// 2. 不使用不安全的算法
// 禁止：MD5, SHA1, DES, RC4
// 推荐：bcrypt, Argon2, scrypt, PBKDF2, AES-256-GCM

// 3. 安全随机数
const crypto = require('crypto');
const randomBytes = crypto.randomBytes(32); // 用于密钥、token
const randomInt = crypto.randomInt(0, 100); // 用于随机数
```

### 6.3 A03 - Injection（注入）

```javascript
// 1. 参数化查询（防止 SQL 注入）
const { data } = await db.query(
  'SELECT * FROM users WHERE id = $1',
  [userId]
);

// 2. 输入验证
const Joi = require('joi');
const schema = Joi.object({
  email: Joi.string().email().required(),
  age: Joi.number().integer().min(0).max(150),
  password: Joi.string().min(8).pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
});

const { error, value } = schema.validate(req.body);
if (error) return res.status(400).json({ error: error.details[0].message });
```

### 6.4 A04 - Insecure Design（不安全设计）

```javascript
// 1. 速率限制（防止暴力破解和 API 滥用）
const rateLimit = require('express-rate-limit');

const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 分钟
  max: 100, // 每次 IP 最多 100 请求
  message: 'Too many requests',
  standardHeaders: true,
  legacyHeaders: false
});

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5, // 登录接口更严格的限制
  message: 'Too many login attempts'
});

app.use('/api/', apiLimiter);
app.post('/login', authLimiter, authController.login);

// 2. 账户锁定
const MAX_ATTEMPTS = 5;
const LOCKOUT_DURATION = 30 * 60 * 1000; // 30 分钟

if (user.failedAttempts >= MAX_ATTEMPTS) {
  const lockoutEnd = new Date(user.lastFailedAttempt.getTime() + LOCKOUT_DURATION);
  if (Date.now() < lockoutEnd) {
    return res.status(429).json({ error: 'Account temporarily locked' });
  }
}
```

### 6.5 A05 - Security Misconfiguration（安全配置错误）

```javascript
// 1. 不暴露详细错误
app.use((err, req, res, next) => {
  if (process.env.NODE_ENV === 'production') {
    console.error(err); // 记录到日志
    res.status(500).json({ error: 'Internal server error' });
  } else {
    res.status(500).json({ error: err.message, stack: err.stack });
  }
});

// 2. 安全默认配置
app.disable('x-powered-by'); // 隐藏服务器信息
app.set('trust proxy', 1); // 正确配置代理信任

// 3. 定期安全检查
// - 使用 npm audit 检查依赖漏洞
// - 使用 Snyk 或 Dependabot 自动监控
```

### 6.6 A06 - Vulnerable Components（易受攻击的组件）

```bash
# 定期检查依赖漏洞
npm audit
npm audit fix

# 使用 Snyk
npm install -g snyk
snyk test
```

---

## 7. 安全头总结

| 安全头 | 推荐值 | 防护作用 |
|-------|-------|---------|
| `Strict-Transport-Security` | `max-age=31536000; includeSubDomains` | 强制 HTTPS |
| `X-Frame-Options` | `DENY` 或 `SAMEORIGIN` | 防止点击劫持 |
| `X-Content-Type-Options` | `nosniff` | 防止 MIME 类型嗅探 |
| `X-XSS-Protection` | `1; mode=block` | XSS 过滤（辅助） |
| `Content-Security-Policy` | 详见 CSP 部分 | 防止 XSS、注入 |
| `Referrer-Policy` | `strict-origin-when-cross-origin` | 控制 Referer 泄露 |
| `Permissions-Policy` | `geolocation=(), microphone=()` | 控制浏览器特性 |
| `Cache-Control` | `no-store, private` | 防止敏感数据缓存 |

---

## 8. 常用安全工具

| 工具 | 用途 |
|------|------|
| `npm audit` | 检查 npm 依赖漏洞 |
| `snyk` | 持续监控依赖安全 |
| `OWASP ZAP` | 自动化渗透测试 |
| `Burp Suite` | Web 安全测试 |
| `Helmet.js` | Express 安全头中间件 |
| `DOMPurify` | HTML 清理 |
| `bcrypt` | 密码哈希 |
| `sqlstring` | 参数化 SQL 查询 |

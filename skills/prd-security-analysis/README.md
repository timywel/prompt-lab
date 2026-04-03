# prd-security-analysis

PRD Security Analysis Extension Skill that automatically supplements PRD documents with threat modeling, privacy compliance, data encryption, API authentication, secure coding, and security testing chapters.

## Features

- **Threat Modeling**: Generates threat analysis for each security-sensitive feature based on the STRIDE model
- **Privacy Compliance**: Maps requirements to GDPR, CCPA, APP, COPPA, and other regulatory frameworks
- **Data Encryption**: Recommends encryption schemes (password hashing, AES, JWT, etc.) based on data type and platform
- **API Authentication**: Recommends authentication solutions such as JWT, OAuth 2.0, and API Keys
- **Sensitive Information Handling**: Log redaction, error message enum prevention, debug information protection
- **Security Testing**: Generates security test cases (P0/P1/P2) corresponding to features

## Trigger Keywords

- `prd-security-analysis`
- `安全分析PRD`
- `PRD安全`
- `安全审查`
- `隐私合规`

## Integration with the PRD Ecosystem

| Trigger Method | Timing |
|----------------|--------|
| Auto-detected by prd-orchestrator | When PRD contains security-sensitive keywords such as login/payment/user data/encryption |
| Explicit user request | When user says "安全分析这个PRD" |
| Dynamic enhancement injection | During the dynamic enhancement phase of prd-orchestrator |

### Skill Collaboration Relationships

```
prd-orchestrator (orchestration layer)
  └── Dynamic enhancement phase
        └── prd-security-analysis (security extension)
              ├── references/macos-security-guide.md
              ├── references/ios-security-guide.md
              ├── references/android-security-guide.md
              └── references/web-security-guide.md
```

## Platform Coverage

- macOS Desktop Applications
- iOS Apps
- Android Apps
- Web Applications
- Cross-Platform Applications

## Reference Documents

- `references/macos-security-guide.md` — macOS Platform Security Implementation Guide
- `references/ios-security-guide.md` — iOS Platform Security Implementation Guide
- `references/android-security-guide.md` — Android Platform Security Implementation Guide
- `references/web-security-guide.md` — Web Platform Security Implementation Guide

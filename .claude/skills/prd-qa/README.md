# prd-qa: PRD 质检与修复

## 功能

自动审查 PRD 输出，修复 13 类常见问题，输出质量报告。

## 质检维度（13 项）

| # | 维度 | 说明 |
|---|------|------|
| 1 | 无占位符扫描 | 扫描 [TODO]/[TBD]/[FIXME] 等未填写内容 |
| 2 | Info.plist / Entitlements | 缺失则自动注入平台配置模板 |
| 3 | API 准确性 | 检测平台与 API 不匹配（如 CMPedometer 在 macOS） |
| 4 | 动画时长矛盾 | 同一动画多处出现不同数值 |
| 5 | 量化参数完整性 | 延迟/内存/CPU/帧率等必须有具体数值 |
| 6 | 测试策略完整性 | 缺失则自动注入测试金字塔模板 |
| 7 | CI/CD 语法检查 | 修正 `$${{ secrets }}` 等常见笔误 |
| 8 | 无障碍规范检查 | VoiceOver / Dynamic Type / reduceMotion |
| 9 | 平台一致性检查 | 技术栈与目标平台匹配验证 |
| 10 | 边界条件覆盖度 | 边界条件数量 >= 10 |
| 11 | 自检清单完整性 | 缺失则自动注入自检清单模板 |
| 12 | 技术栈完整性 | 核心 API 全覆盖检查 |
| 13 | 知识库复用检查 | 是否引用 `_shared/` 共享资源 |

## 激活方式

- 说"审查 PRD"、"检查 PRD"或"PRD 质量报告"激活
- 在方案 A / B / C（PRD 生成器）输出后自动调用

## 知识库依赖

本技能依赖 `_shared/` 中的以下模板（如有则自动注入）：

- `_shared/platform-configs/` — 平台配置文件模板（Info.plist / Entitlements / manifest 等）
- `_shared/test-templates/test-pyramid-template.md` — 测试金字塔模板
- `_shared/qa-checks/self-review-checklist.md` — 自检清单模板

## 输出

- 质量报告（含评分 + 问题列表 + 修复记录）
- 自动修复的 diff
- 待用户确认的问题清单

## 版本

- v1.0.0 — 初始版本，13 维度质检

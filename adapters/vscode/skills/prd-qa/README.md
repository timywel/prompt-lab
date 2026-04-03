# prd-qa: PRD Quality Assurance and Repair

## Overview

Automatically reviews PRD output, fixes 13 common categories of issues, and outputs a quality report.

## Quality Dimensions (13 Items)

| # | Dimension | Description |
|---|-----------|-------------|
| 1 | No Placeholder Scanning | Scans for unfilled content such as [TODO]/[TBD]/[FIXME] |
| 2 | Info.plist / Entitlements | Auto-injects platform config templates if missing |
| 3 | API Accuracy | Detects platform/API mismatches (e.g., CMPedometer on macOS) |
| 4 | Animation Duration Conflicts | Same animation appearing with different values in multiple places |
| 5 | Quantitative Parameter Completeness | Delay/memory/CPU/framerate must have specific values |
| 6 | Testing Strategy Completeness | Auto-injects test pyramid template if missing |
| 7 | CI/CD Syntax Check | Fixes common typos like `$${{ secrets }}` |
| 8 | Accessibility Compliance Check | VoiceOver / Dynamic Type / reduceMotion |
| 9 | Platform Consistency Check | Tech stack and target platform match verification |
| 10 | Edge Case Coverage | Edge case count >= 10 |
| 11 | Self-Review Checklist Completeness | Auto-injects self-review checklist template if missing |
| 12 | Tech Stack Completeness | Full coverage check of core APIs |
| 13 | Knowledge Base Reuse Check | Verifies if `_shared/` shared resources are referenced |

## Activation

- Activate by saying "审查 PRD" (review PRD), "检查 PRD" (check PRD), or "PRD 质量报告" (PRD quality report)
- Automatically invoked after Solution A / B / C (PRD generators) output

## Knowledge Base Dependencies

This skill depends on the following templates in `_shared/` (auto-injected if present):

- `_shared/platform-configs/` — Platform config file templates (Info.plist / Entitlements / manifest, etc.)
- `_shared/test-templates/test-pyramid-template.md` — Test pyramid template
- `_shared/qa-checks/self-review-checklist.md` — Self-review checklist template

## Output

- Quality report (with score + issue list + fix log)
- Auto-fixed diffs
- Issue list pending user confirmation

## Version

- v1.0.0 — Initial version, 13-dimension quality inspection

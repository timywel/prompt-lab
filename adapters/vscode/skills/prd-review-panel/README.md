# PRD Review Panel Skill

## Overview

The PRD Review Panel is a standardized multi-dimensional PRD review Skill. Through parallel-scheduled 6 independent review Agents, it performs comprehensive evaluation of the PRD document and outputs a consolidated scoring report.

## Activation

Trigger it in conversation using any of the following:

```
评审PRD
PRD打分
启动评审团
prd-review-panel
```

## Review Dimensions

| # | Dimension | Weight | Review Focus |
|---|-----------|--------|--------------|
| 1 | Technical Architecture | 20% | API specificity / tech stack correctness / module division / technical depth |
| 2 | Product Design | 20% | Feature completeness / requirement clarity / edge cases / user value |
| 3 | Engineering | 15% | Build system / CI-CD / development toolchain / release process |
| 4 | Testing Strategy | 15% | Test pyramid / scenario coverage / performance testing / testability |
| 5 | Executability | 15% | No placeholders / quantitative completeness / knowledge base coverage / self-check mechanism |
| 6 | UI/UX Precision | 15% | Layout precision / component specs / animation specs / accessibility specs |

## Review Process

1. Receive PRD (file path or text)
2. Analyze PRD filename and content to determine solution type
3. Read PRD content
4. Read review templates and platform configs from shared knowledge base (`_shared/`)
5. Execute 6-dimension reviews in parallel (each dimension is an independent Agent)
6. Collect 6 independent review reports
7. Aggregate scores: weighted total + per-dimension ranking + issue summary
8. Generate consolidated report
9. Save to `docs/review/PRD-Review-Panel-Report.md`

## Scoring Criteria

| Score Range | Meaning |
|-------------|---------|
| 9-10 | Production-grade; ready for direct development |
| 7-8 | Near production-grade; a few details need supplementing |
| 5-6 | Basic usability; needs significant supplementation |
| 3-4 | Only describes functional requirements; insufficient precision |
| 1-2 | Almost no specification information |

## Issue Severity Levels

| Level | Marker | Description |
|-------|--------|-------------|
| High | :red_circle: | Will cause feature to be unimplementable or lead to development failure |
| Medium | :yellow_circle: | Affects development efficiency or quality |
| Low | :green_circle: | Best practice suggestions |

## Output File

Upon completion, the consolidated report is saved to:

```
docs/review/PRD-Review-Panel-Report.md
```

## File Structure

```
prd-review-panel/
├── _registry.yaml              # Skill registration config
├── _definition.yaml            # Skill definition metadata
├── _content.md                 # Review framework (core)
├── _templates/
│   ├── review-report-template.md  # Per-dimension review report template
│   └── aggregator-template.md     # Consolidated report aggregation template
└── README.md                   # This file
```

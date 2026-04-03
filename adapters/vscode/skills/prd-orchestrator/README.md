# prd-orchestrator: PRD Generation Orchestration Layer

## Overview

Unified entry point that automatically analyzes input complexity and intelligently routes to the most suitable solution combination.

## Workflow

```
Simple:       Solution A → (optional) Solution C → PRD-QA
Complex:      Solution B → Solution A → Solution C → PRD-QA
Existing PRD: Solution C → PRD-QA
Uncertain:     Solution B (requirement discovery) → Re-evaluation
```

## Solution Mapping

| Solution | Skill Name | Function |
|----------|------------|----------|
| Solution A | prd-autofill | Fully automatic PRD generator that auto-fills technical details from a one-sentence idea |
| Solution B | prd-conversational | Interactive PRD builder with multi-round guided conversation for requirement discovery |
| Solution C | prd-deep-expand | Deep expansion PRD generator covering six dimensions |
| PRD-QA | Built-in QA | Quality inspection of the final output |

## Complexity Assessment

| Type | Characteristics | Route |
|------|----------------|-------|
| Simple | < 100 characters, single feature, common platform | Solution A |
| Existing PRD | Provides preliminary PRD text or file path | Solution C |
| Complex/Innovative | > 200 characters, multiple features, special platform or innovative interaction | Solution B → Solution A → Solution C |
| Uncertain | Vague description, unclear functionality | Solution B (requirement discovery) |

## Usage

Activate by saying "帮我生成PRD" (help me generate a PRD). No solution selection needed. The orchestration layer automatically evaluates and routes.

## Orchestration Layer Responsibilities

1. **Context Propagation**: Chains Solutions B/A/C together, ensuring information continuity
2. **User Decision Points**: Asks the user at each branch point; does not auto-decide
3. **Progress Display**: Shows current progress after each step completes
4. **Interruptible**: User can say "停" (stop) at any time to terminate subsequent steps
5. **Quality Assurance**: Final output must pass PRD-QA inspection

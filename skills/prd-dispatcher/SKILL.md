---
name: prd-dispatcher
description: "PRD generation top-level dispatcher: captures all PRD requests, analyzes complexity, and confirms routing strategy"
version: "1.0.0"
compatibility: "Claude Code"
author: timywel
---

# PRD Dispatcher

Top-level entry point for all PRD generation requests. Analyzes user intent, determines complexity, and confirms the routing strategy before delegating to the appropriate skill.

## When to Activate

Activate when the user says anything related to generating a Product Requirements Document, such as:

- `"帮我生成一个XXX的PRD"`
- `"帮我生成PRD"`
- `"生成PRD"`
- `"帮我写PRD"`
- `"写一个PRD"`
- `"产品需求文档"`

## Dispatcher Flow

```
1. RECEIVE: Preserve the user's original request verbatim
2. ANALYZE: Classify complexity
3. CONFIRM: Show analysis + recommend routing, wait for user confirmation
4. DELEGATE: Call the confirmed skill
5. FOLLOW-UP: Hand off to the called skill for execution
```

### Complexity Classification

| Type | Characteristics | Recommended Route |
|------|----------------|-----------------|
| **Simple** | < 100 chars, single feature, common platform | prd-autofill |
| **Existing PRD** | User provides text or file path | prd-deep-expand |
| **Complex** | > 200 chars, multiple features, special platform | prd-conversational |
| **Uncertain** | Vague description, unclear scope | prd-conversational |

### Confirmation Prompt Template

After analyzing the user's input, show:

```
Analysis:
- Type: [Simple / Existing PRD / Complex / Uncertain]
- Feature count: [N features detected]
- Platform: [Detected platform or "unspecified"]

Recommended route: [Route name]
Reason: [1-sentence explanation]

Options:
A) prd-autofill     - Fast, fully automatic, 1-sentence in, PRD out
B) prd-conversational - Multi-round Q&A, precise clarification
C) prd-deep-expand   - 6-dimension deep expansion (for existing draft)

Which do you prefer? [A / B / C]
```

### Delegation

After user confirms:

```
Based on your choice, I'll invoke [skill-name].
[Invoke the skill with user's original request]
```

**Critical rule**: Never auto-decide. Always confirm the routing with the user first.

## What This Skill Does NOT Do

- Does NOT generate PRD content directly
- Does NOT call prd-qa or prd-review-panel (the called skill handles that)
- Does NOT skip the confirmation step

## Relationship with prd-orchestrator

- prd-dispatcher: Entry point + routing decision (what skill to call)
- prd-orchestrator: Execution orchestrator (chains A→B→C in sequence)

Use prd-dispatcher for routing. Use prd-orchestrator when you need to chain multiple solutions.

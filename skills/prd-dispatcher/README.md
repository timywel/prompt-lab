# PRD Dispatcher

Top-level entry point for all PRD generation requests. Captures user intent, analyzes complexity, and confirms routing strategy before delegating to the appropriate skill.

## Activation

Say any of these to activate the dispatcher:
- `"帮我生成一个XXX的PRD"`
- `"帮我生成PRD"`
- `"生成PRD"`
- `"帮我写PRD"`
- `"写一个PRD"`

## Workflow

```
User Input → Dispatcher (Analyze) → User Confirms Route → Delegated Skill
```

1. **Receive**: Capture the user's original request
2. **Analyze**: Classify as Simple / Existing PRD / Complex / Uncertain
3. **Confirm**: Show analysis + routing recommendation to user
4. **Delegate**: Call the confirmed skill (A/B/C)

## Routing Guide

| Type | When | Route |
|------|------|-------|
| Simple | < 100 chars, common platform | prd-autofill |
| Existing PRD | User provides draft | prd-deep-expand |
| Complex | > 200 chars, multiple features | prd-conversational |
| Uncertain | Vague or unclear | prd-conversational |

## Skills Overview

| Skill | Trigger | Core Value |
|-------|---------|-----------|
| prd-dispatcher | PRD request (any) | Top-level entry, routing |
| prd-autofill | Simple cases | One sentence in, detailed PRD out |
| prd-conversational | Complex/vague | 15-question dialogue, precise |
| prd-deep-expand | Existing draft | 6-dimension deep expansion |
| prd-orchestrator | Chained execution | Route A→B→C in sequence |

## Example

User: `"帮我生成一个三国斗地主的PRD"`

Dispatcher analyzes:
- Type: Complex (multiple features: card system, AI, pixel art, game rules)
- Features detected: 5+
- Platform: Web (inferred from pixel game context)

Dispatcher confirms:
```
Recommended: prd-conversational (Complex)
Reason: Multi-feature pixel card game needs thorough requirement clarification.

Options:
A) prd-autofill    - Fast, automatic
B) prd-conversational - Precise, guided
C) prd-deep-expand   - For existing drafts

Your choice? [B recommended]
```

After user confirms B:
```
Invoking prd-conversational for thorough requirement discovery...
[Hand off to prd-conversational skill]
```

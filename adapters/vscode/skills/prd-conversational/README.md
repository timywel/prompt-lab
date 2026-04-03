# prd-conversational: Interactive PRD Builder

## Overview

Through multi-round guided conversation (15 questions across 4 phases), probes user requirements and outputs a complete PRD with per-module confirmation.

## Usage

In Claude Code, say "开始对话式 PRD" (start conversational PRD) or "对话式产品需求" (conversational product requirements) to activate this skill.

## Conversation Flow

| Phase | Questions | Content |
|------|-----------|---------|
| Phase 0 | 1 | Intent understanding + confirmation |
| Phase 1 | 4 | Platform and basics |
| Phase 2 | 5 | Core features |
| Phase 3 | 2 | Technical preferences |
| Phase 4 | 3 | Quality requirements |
| **Total** | **15** | |

Total of 15 questions (including Q0 initial idea).

## Core Features

| Feature | Description |
|---------|-------------|
| Smart Inference | Automatically flags required APIs and permissions based on answers |
| Progress Visualization | Each question annotated with [Phase X/4] and Question X/Y |
| Skip Mechanism | Each question can be skipped with a default value |
| Resume After Interrupt | Supports interrupt, resume, and restart |
| Confirmation Mechanism | Per-module confirmation with up to 3 rounds of modifications |
| Export Options | Save to file or preview directly in terminal |

## State Management

Conversation state is saved in `tmp/prd-conversational/state.yaml`, supporting:
- Resume after interrupt (say "继续对话" (continue conversation) to resume from last question)
- Modify previously answered questions
- Restart (say "重新开始" (restart) to clear state)

## Default Values

Each question has intelligent defaults; users can press Enter to skip:
- Platform: macOS desktop app
- Version: Last 1-2 versions
- MVP-first
- Balanced performance
- Basic test coverage

## Comparison with Solution A

| | Solution A (Auto) | Solution B (Conversational) |
|--|-----------------|------------------------------|
| User Involvement | Low | High (15 questions) |
| PRD Accuracy | Relies on inference | User-confirmed |
| Generation Speed | Seconds | Minutes |
| Applicable Scenarios | Common app types | Innovative/complex apps |
| Accessibility Requirements | Not proactively asked | Auto-inferred when Q3 asks about target users |
| Resume After Interrupt | Not supported | Supported |

## Version History

- 1.0.0: Initial version, 15 questions, 4-phase conversation, smart inference, confirmation mechanism, resume after interrupt

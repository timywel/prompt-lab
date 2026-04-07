# Cursor Adapter

This adapter symlinks the root `skills/` directory to Cursor's project-level skills directory.

## Installation

### Automatic (Recommended)
```bash
cd prompt-lab
make install-cursor
# or
./adapters/cursor/install.sh
```

### Manual
```bash
mkdir -p .cursor
ln -sfn ../skills .cursor/skills
```

## How It Works

Cursor uses a skill format compatible with Claude Code.
Symlinking the shared `skills/` directory enables cross-platform skill sync.

**Entry Point**: All PRD generation requests are first captured by the
`prd-dispatcher`, which analyzes complexity and confirms the routing strategy
with you before delegating to the appropriate skill.

## Verify Installation

After installation, trigger a skill command in Cursor (e.g., `/prd-autofill`) to verify loading.

## Quick Usage

Say `"帮我生成PRD"` and the dispatcher will guide you through the routing selection.

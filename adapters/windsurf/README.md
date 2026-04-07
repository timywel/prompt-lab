# Windsurf Adapter

This adapter symlinks the root `skills/` directory to Windsurf's project-level skills directory.

## Installation

### Automatic (Recommended)
```bash
cd prompt-lab
make install-windsurf
# or
./adapters/windsurf/install.sh
```

### Manual
```bash
mkdir -p .windsurf
ln -sfn ../skills .windsurf/skills
```

## How It Works

Windsurf uses a skill format compatible with Claude Code.
Symlinking the shared `skills/` directory enables cross-platform skill sync.

**Entry Point**: All PRD generation requests are first captured by the
`prd-dispatcher`, which analyzes complexity and confirms the routing strategy
with you before delegating to the appropriate skill.

## Verify Installation

After installation, trigger a skill command in Windsurf to verify loading.

## Quick Usage

Say `"帮我生成PRD"` and the dispatcher will guide you through the routing selection.

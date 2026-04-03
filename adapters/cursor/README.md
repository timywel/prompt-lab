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

## Verify Installation

After installation, trigger a skill command in Cursor (e.g., `/prd-autofill`) to verify loading.

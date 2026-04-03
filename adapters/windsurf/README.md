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

## Verify Installation

After installation, trigger a skill command in Windsurf to verify loading.

# OpenCode Adapter

This adapter symlinks the skill library to OpenCode's global skills directory.

## Installation

### Automatic (Recommended)
```bash
cd prompt-lab
make install-opencode
# or
./adapters/opencode/install.sh
```

### Manual
```bash
mkdir -p ~/.opencode/skills
ln -sfn "$(pwd)" ~/.opencode/skills/prompt-lab
```

## How It Works

OpenCode uses `~/.opencode/skills/` as its global skills directory.
After installation, skills are available as a skill module named `prompt-lab`.

## Verify Installation

After installation, run `/prompt-lab` in OpenCode or check the skill list to verify.

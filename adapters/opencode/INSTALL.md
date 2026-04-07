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

**Entry Point**: All PRD generation requests are first captured by the
`prd-dispatcher`, which analyzes complexity and confirms the routing strategy
with you before delegating to the appropriate skill.

## Verify Installation

After installation, run `/prompt-lab` in OpenCode or check the skill list to verify.

## Quick Usage

Say `"帮我生成PRD"` and the dispatcher will guide you through the routing selection.

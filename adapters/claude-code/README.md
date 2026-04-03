# Claude Code Adapter

This adapter symlinks the root `skills/` directory to Claude Code's project-level skills directory.

## Installation

### Automatic (Recommended)
```bash
cd prompt-lab
make install-claude
# or
./adapters/claude-code/install.sh
```

### Manual
```bash
mkdir -p .claude
ln -sfn ../skills .claude/skills
```

## How It Works

Claude Code reads skills from the project-level `.claude/skills/` directory.
This adapter maps the shared `skills/` directory to that location via symlink,
enabling single-source maintenance with multi-platform sync.

## Verify Installation

After installation, reload the Claude Code project. Skills should appear
automatically in the `/skills` command.

# VSCode Adapter

This adapter provides a VSCode extension for browsing and viewing the PRD generator skill library.

## Installation

### Option 1: Copy Extension Directory
```bash
cp -r adapters/vscode ~/.vscode/extensions/prompt-lab-prd-generator
```

### Option 2: Package as .vsix and Install
```bash
cd adapters/vscode
npm install -g @vscode/vsce
vsce package
code --install-extension prompt-lab-prd-generator-1.0.0.vsix
```

### Option 3: Use Makefile
```bash
make install-vscode
```

## Usage

1. After installing the extension, reload the VSCode window
2. Press `Ctrl+Shift+P` (or `Cmd+Shift+P`) to open the command palette
3. Type `Show PRD Generator Skill Library` and select it
4. Choose a skill from the list to view

## How It Works

This extension is **content-display focused**, enabling quick skill documentation lookup in VSCode.
Since VSCode does not natively support the Claude Code-style skill system,
this adapter provides skill browsing via WebView command palette.

## Skill Display

The extension reads all skill folders under the `skills/` directory,
extracts the SKILL.md file from each skill, and displays it as a Markdown preview.
